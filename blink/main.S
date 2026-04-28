    .cpu cortex-m33
    .thumb

    /* Register addresses */
    .equ CLOCKS_BASE, 0x40010000
    .equ CLK_REF_CTRL, (CLOCKS_BASE + 0x30)
    .equ CLK_REF_SELECTED, (CLOCKS_BASE + 0x38)
    .equ CLK_SYS_CTRL, (CLOCKS_BASE + 0x3c)
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

    /* Addresses */
    .equ STACK_TOP, 0x20001000

    .section .vectors, "a"
    .align 2
    .global vectors
vectors:
    /* Vector table */
    .word STACK_TOP         /* Initial stack top */
    .word reset_handler     /* Reset handler */
    .word default_handler   /* NMI handler */
    .word default_handler   /* Hard fault handler */
    .word default_handler   /* Mem manage handler */
    .word default_handler   /* Bus fault handler */
    .word default_handler   /* Usage fault handler */
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word default_handler   /* SVCall handler */
    .word default_handler   /* DebugMon handler */
    .word 0x0
    .word default_handler   /* PendSV handler */
    .word systick_handler   /* SysTick handler */

    .section .text
    .thumb_func
    .global reset_handler
reset_handler:
    b main

    .thumb_func
    .global systick_handler
/* SysTick handler */
systick_handler:
    /* Read current GPIO outputs */
    ldr r0, =GPIO_OUT
    ldr r1, [r0]
    ldr r2, =(1 << 25)
    eor r1, r1, r2      /* Reverse GPIO25 */
    str r1, [r0]
    bx lr               /* Return */

    .thumb_func
    .global main
main:
    /* Use an external oscillator (XOSC) */
    ldr r0, =XOSC_CTRL
    ldr r1, =0xaa0          /* FREQ_RANGE: 1_15MHZ
                               (12 MHz crystal is used) */
    str r1, [r0]
    ldr r0, =XOSC_STARTUP
    ldr r1, =47             /* Startup delay: ((crystal freq.) x (stable time)) / 256
                               when the stable time is 1[ms]:
                               (12 x (10^6)) x (10^(-3)) / 256 = 46.875 ~ 47 */
    str r1, [r0]
    ldr r0, =XOSC_STATUS
    ldr r2, =0x80000000     /* b31: STABLE */
wait_xosc_stable:           /* Wait stable */
    ldr r1, [r0]
    tst r1, r2
    bne wait_xosc_stable

    /* Set source of reference clock */
    ldr r0, =CLK_REF_CTRL
    ldr r2, =0x2                /* Source of reference clock: XOSC_CLKSRC */
    str r2, [r0]
    ldr r0, =CLK_REF_SELECTED
wait_clk_ref_stable:            /* Wait stable */
    ldr r1, [r0]
    tst r1, r2
    bne wait_clk_ref_stable

    /* Set source of system clock */
    ldr r0, =CLK_SYS_CTRL
    ldr r2, =0x0                /* Source of system clock: CLK_REF */
    str r2, [r0]
    ldr r0, =CLK_SYS_SELECTED
wait_clk_sys_stable:            /* Wait stable */
    ldr r1, [r0]
    tst r1, r2
    bne wait_clk_sys_stable

    /* Deassert reset of GPIO */
    ldr r0, =RESETS_RESET
    ldr r1, [r0]
    ldr r2, =((1 << 9) | (1 << 6)) /* PADS_BANK0, IO_BANK0 */
    bic r1, r1, r2
    str r1, [r0]
    ldr r0, =RESETS_DONE
wait_reset_done:
    ldr r1, [r0]                    /* Wait stable */
    tst r1, r2
    bne wait_reset_done

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
    mov r1, #7              /* Source: processor clock,
                               enable SysTick exception request,
                               enable SysTick counter */
    str r1, [r0]
    ldr r0, =SYST_RVR
    ldr r1, =(1200000 - 1)  /* Interrupt every 1,200,000 clock cycles
                               (100 ms) */
    str r1, [r0]
    ldr r0, =SYST_CVR 
    mov r1, #0              /* Reset current counter value */
    str r1, [r0]

loop:
    b loop

    .thumb_func
default_handler:
    b .
