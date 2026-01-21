    .cpu cortex-m0plus
    .thumb

    .section .vectors, "a"
    .align 2
    .global vectors
vectors:
    .word 0x20001000 /* Initial stack top */
    .word reset /* Reset handler */
    .word halt  /* NMI handler */
    .word halt  /* Hard fault handler */
    .word halt  /* Mem manage handler */
    .word halt  /* Bus fault handler */
    .word halt  /* Usage fault handler */
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word halt  /* SVCall handler */
    .word halt  /* DebugMon handler */
    .word 0x0
    .word halt  /* PendSV handler */
    .word halt  /* SysTick handler */

    .section .text
    .thumb_func
    .global reset
reset:
    bl main
    b .

    .thumb_func
halt:
    b .
