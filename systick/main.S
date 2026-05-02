    .cpu cortex-m33
    .thumb

    /* Register addresses */
    .equ CLOCKS_BASE, 0x40010000
    .equ CLK_REF_CTRL, (CLOCKS_BASE + 0x30)
    .equ CLK_REF_SELECTED, (CLOCKS_BASE + 0x38)
    .equ CLK_SYS_CTRL, (CLOCKS_BASE + 0x3c)
    .equ CLK_SYS_DIV, (CLOCKS_BASE + 0x40)
    .equ CLK_SYS_SELECTED, (CLOCKS_BASE + 0x44)

    .equ RESETS_BASE, 0x40020000
    .equ RESETS_RESET, (RESETS_BASE + 0x0)
    .equ RESETS_DONE, (RESETS_BASE + 0x8)

    .equ IO_BANK0_BASE, 0x40028000
    .equ GPIO25_CTRL, (IO_BANK0_BASE + 0xcc)

    .equ PADS_BANK0_BASE, 0x40038000
    .equ GPIO25, (PADS_BANK0_BASE + 0x68)

    .equ XOSC_BASE, 0x40048000
    .equ XOSC_CTRL, (XOSC_BASE + 0x0)
    .equ XOSC_STATUS, (XOSC_BASE + 0x4)
    .equ XOSC_STARTUP, (XOSC_BASE + 0xc)

    .equ SIO_BASE, 0xd0000000
    .equ GPIO_OUT, (SIO_BASE + 0x10)
    .equ GPIO_OUT_SET, (SIO_BASE + 0x18)
    .equ GPIO_OUT_CLR, (SIO_BASE + 0x20)
    .equ GPIO_OE_SET, (SIO_BASE + 0x38)

    .equ PPB_BASE, 0xe0000000
    .equ SYST_CSR, (PPB_BASE + 0xe010)
    .equ SYST_RVR, (PPB_BASE + 0xe014)
    .equ SYST_CVR, (PPB_BASE + 0xe018)

    /* SysTick handler */
    .thumb_func
    .global systick
systick:
    ldr r0, =GPIO_OUT
    ldr r1, [r0]        /* Read current GPIO outputs */
    ldr r2, =(1 << 25)
    eor r1, r1, r2      /* Reverse GPIO25 */
    str r1, [r0]
    bx lr

    /* Polling a register (r0: register, r1: expected bit pattern) */
    .thumb_func
    .global poll
poll:
1:
    ldr r2, [r0]
    tst r1, r2
    beq 1b
    bx lr

    .thumb_func
    .global main
main:
    /* Reset to the default configuration:
       set a clock source to the ring oscillator (ROSC)
       (maybe not necessary, for safety) */
    ldr r0, =CLK_REF_CTRL
    mov r1, #0                  /* SRC: ROSC_CLKSRC_PH */
    str r1, [r0] 
    ldr r0, =CLK_REF_SELECTED
    mov r1, #1                  /* ROSC_CLKSRC_PH */
    bl poll
    ldr r0, =CLK_SYS_CTRL
    ldr r1, =((2 << 5) | 1)     /* AUXSRC: ROSC_CLKSRC
                                   SRC: CLKSRC_CLK_SYS_AUX */
    str r1, [r0]
    ldr r0, =CLK_SYS_SELECTED
    mov r1, #(1 << 1)           /* CLKSRC_CLK_SYS_AUX */
    bl poll

    /* Activate an external oscillator (XOSC) */
    ldr r0, =XOSC_STARTUP
    ldr r1, =47                         /* DELAY: 47
                                           -> ((crystal freq.) x (stable time)) / 256
                                           when the stable time is 1[ms]:
                                           (12 x (10^6)) x (10^(-3)) / 256 = 46.875 ~ 47 */
    str r1, [r0]
    ldr r0, =XOSC_CTRL
    ldr r1, =((0xfab << 12) | 0xaa0)    /* ENABLE: enable (0xfab)
                                           FREQ_RANGE: 1_15MHZ
                                           (12 MHz crystal is used) */
    str r1, [r0]
    ldr r0, =XOSC_STATUS
    ldr r1, =0x80000000                 /* STABLE */
    bl poll

    /* Set source of the reference clock */
    ldr r0, =CLK_REF_CTRL
    mov r1, #2                  /* SRC: XOSC_CLKSRC */
    str r1, [r0]
    ldr r0, =CLK_REF_SELECTED
    mov r1, #(1 << 2)           /* XOSC_CLKSRC */
    bl poll

    /* Set source of the system clock */
    ldr r0, =CLK_SYS_CTRL
    ldr r1, [r0]
    mov r2, #1
    bic r1, r1, r2              /* SRC: CLK_REF,
                                   don't change AUXSRC at the same time */
    str r1, [r0]
    ldr r0, =CLK_SYS_SELECTED
    mov r1, #1                  /* CLK_REF */
    bl poll
    ldr r0, =CLK_SYS_DIV
    ldr r1, =(1 << 16)          /* INT=1, FRAC=0: no division */
    str r1, [r0]

    /* Wait to be stable */
    mov r2, #200
1:
    sub r2, r2, #1
    bne 1b

    /* Deassert reset of GPIO */
    ldr r0, =RESETS_RESET
    ldr r2, [r0]
    ldr r1, =((1 << 9) | (1 << 6)) /* PADS_BANK0, IO_BANK0 */
    bic r2, r2, r1
    str r2, [r0]
    ldr r0, =RESETS_DONE
    bl poll

    /* Disable a pad isolation latch */
    ldr r0, =GPIO25
    ldr r1, [r0]
    ldr r2, =(1 << 8) /* ISO */
    bic r1, r1, r2
    str r1, [r0]

    /* Set SIO (Software I/O) */
    ldr r0, =GPIO25_CTRL
    mov r1, #5              /* FUNCSEL: SIO_25 */
    str r1, [r0]

    /* Enable output */
    ldr r0, =GPIO_OE_SET
    ldr r1, =(1 << 25)
    str r1, [r0]

    /* Setup SysTick */
    ldr r0, =SYST_CSR
    mov r1, #7              /* CLKSOURCE: processor clock,
                               TICKINT: assert the SysTick expecption request,
                               ENABLE: counter enabled */
    str r1, [r0]
    ldr r0, =SYST_RVR
    ldr r1, =12000000       /* RELOAD: 12000000,
                               interrupt every 12,000,000 clock cycles
                               (= 1 sec) */
    str r1, [r0]
    ldr r0, =SYST_CVR 
    mov r1, #0              /* Reset the current value of the SysTick counter */
    str r1, [r0]

    /* Enable IRQ */
    cpsie i

    /* Main loop */
loop:
    b loop

    bx lr
