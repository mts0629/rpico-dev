    .cpu cortex-m33
    .thumb

    /* Register addresses */
    .equ RESETS_BASE, 0x40020000
    .equ RESETS_RESET, (RESETS_BASE + 0x0)
    .equ RESETS_DONE, (RESETS_BASE + 0x8)

    .equ IO_BANK0_BASE, 0x40028000
    .equ GPIO25_CTRL, (IO_BANK0_BASE + 0xcc)

    .equ PADS_BANK0_BASE, 0x40038000
    .equ GPIO25, (PADS_BANK0_BASE + 0x68)
    .equ ARMED, (PADS_BANK0_BASE + 0x20)

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
    eor r1, r1, r2  /* Reverse GPIO25 */
    str r1, [r0]
    bx lr /* Return */

    .thumb_func
    .global main
main:
    /* Deassert reset of GPIO */
    ldr r0, =RESETS_RESET
    ldr r1, [r0]
    ldr r2, =((1 << 9) | (1 << 6)) /* PADS_BANK0, IO_BANK0 */
    bic r1, r1, r2
    str r1, [r0]
    ldr r0, =RESETS_DONE
wait_reset_done:
    ldr r1, [r0]
    and r1, r1, r2
    cmp r1, r2
    bne wait_reset_done

    /* Disable a pad isolation latch */
    ldr r0, =GPIO25
    ldr r1, [r0]
    ldr r2, =(1 << 8) /* ISO */
    bic r1, r1, r2
    str r1, [r0]

    /* Set SIO (Software I/O) */
    ldr r0, =GPIO25_CTRL
    mov r1, #5  /* FUNCSEL: SIO_25 */
    str r1, [r0]

    /* Enable output */
    ldr r0, =GPIO_OE_SET
    ldr r1, =(1 << 25)
    str r1, [r0]

    /* Setup SysTick */
    ldr r0, =SYST_CSR
    mov r1, #7              /* Source: processsor clock,
                               enable SysTick exception request,
                               enable SysTick counter */
    str r1, [r0]
    ldr r0, =SYST_RVR
    ldr r1, =(1500000 - 1)  /* Interrupt every 1,500,000 clock cycles */
    str r1, [r0]
    ldr r0, =SYST_CVR 
    mov r1, #0              /* Reset current counter value */
    str r1, [r0]

loop:
    b loop

    .thumb_func
default_handler:
    b .
