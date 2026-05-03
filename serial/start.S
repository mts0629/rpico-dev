    .cpu cortex-m33
    .thumb

    /* Register addresses */
    .equ PPB_BASE, 0xe0000000
    .equ VTOR, (PPB_BASE + 0xed08)

    /* Addresses */
    .equ STACK_TOP, 0x20001000

    .section .vectors, "a"
    .align 2
    .global vectors
vectors:
    /* Vector table */
    .word STACK_TOP /* Initial stack top */
    .word reset     /* Reset handler */
    .word halt      /* NMI handler */
    .word halt      /* Hard fault handler */
    .word halt      /* Mem manage handler */
    .word halt      /* Bus fault handler */
    .word halt      /* Usage fault handler */
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word halt      /* SVCall handler */
    .word halt      /* DebugMon handler */
    .word 0x0
    .word halt      /* PendSV handler */
    .word systick   /* SysTick handler */

    .section .text
    /* Reset handler */
    .thumb_func
    .global reset
reset:
    /* Diable IRQ */
    cpsid i

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
