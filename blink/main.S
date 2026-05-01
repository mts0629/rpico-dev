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

    .equ SIO_BASE, 0xd0000000
    .equ GPIO_OUT, (SIO_BASE + 0x10)
    .equ GPIO_OE_SET, (SIO_BASE + 0x38)

    .equ PPB_BASE, 0xe0000000
    .equ VTOR, (PPB_BASE + 0xed08)

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

    .section .text
    .thumb_func
default_handler:
    b .

    .thumb_func
    .global reset_handler
reset_handler:
    /* Set main stack pointer (MSP) */
    ldr r0, =STACK_TOP
    mov sp, r0

    /* Set vector table */
    ldr r0, =VTOR
    ldr r1, =vectors
    str r1, [r0]

    /* Sync */
    dsb /* Data sync barrier */
    isb /* Instruction sync barrier */

    bl main
    b halt

    .thumb_func
halt:
    b .

    .thumb_func
    .global main
main:
    /* Deassert reset of GPIO */
    ldr r0, =RESETS_RESET
    ldr r2, [r0]
    ldr r1, =((1 << 9) | (1 << 6)) /* PADS_BANK0, IO_BANK0 */
    bic r2, r2, r1
    str r2, [r0]
    ldr r0, =RESETS_DONE
wait_reset_done:
    ldr r2, [r0]
    tst r1, r2
    beq wait_reset_done

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
    ldr r1, =(1 << 25)      /* GPIO25 */
    str r1, [r0]

    /* Main loop */
    ldr r0, =GPIO_OUT
loop:
    ldr r1, [r0]        /* Read current GPIO outputs */
    ldr r2, =(1 << 25)
    eor r1, r1, r2      /* Reverse GPIO25 */
    str r1, [r0]
    ldr r2, =10000000   /* Count for wait:
                           w/o configuration, clock source is a ring oscillator (ROSC)
                           and its frequency is ambiguous */
wait:                   /* Wait to keep LED */
    sub r2, #1
    bne wait
    b loop

    bx lr
