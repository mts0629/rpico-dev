    .cpu cortex-m0plus
    /*.syntax unified*/
    .thumb

    .section .text
    .thumb_func
    .global main
main:
    /* Set GPIO25 to SIO */
    ldr r0, =0x400280cc
    mov r1, #5
    str r1, [r0]

    /* Enable output */
    ldr r0, =0xd0000020
    ldr r1, [r0]
    ldr r2, =(1 << 25)
    orr r1, r1, r2
    str r1, [r0]

    /* LED on */
    ldr r0, =0xd0000010
    ldr r1, [r0]
    ldr r2, =(1 << 25)
    orr r1, r1, r2
    str r1, [r0]

    b .
