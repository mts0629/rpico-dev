    /*.cpu cortex-m0plus*/
    .cpu cortex-m33
    .thumb

    .section .text
    .thumb_func
    .global main
main:
    /* Release IO from reset */
    ldr r0, =0x40020000             /* RESETS_RESET */
    ldr r1, [r0]
    ldr r2, =((1 << 9) | (1 << 6))
    bic r1, r1, r2                  /* PADS_BANK0=IO_BANK0=0 */
    str r1, [r0]
    ldr r0, =0x40020008             /* RESETS_DONE */
wait_reset_done:
    ldr r1, [r0]
    and r1, r1, r2
    cmp r1, r2                      /* Check RESETS_DONE */
    bne wait_reset_done

    /* Set a pad */
    ldr r0, =0x40038068 /* PADS_BANK0 GPIO25 */
    ldr r1, [r0]
    ldr r2, =(1 << 8)
    bic r1, r1, r2      /* ISO=0 */
    str r1, [r0]

    /* Set SIO (Software I/O) */
    ldr r0, =0x400280cc /* GPIO25_CTRL */
    mov r1, #5
    str r1, [r0]        /* FUNCSEL: SIO_25 */

    /* Enable output */
    ldr r0, =0xd0000038 /* GPIO_OE_SET */
    ldr r1, =(1 << 25)
    str r1, [r0]        /* GPIO25=1 */

    /* LED on */
    ldr r0, =0xd0000018 /* GPIO_OUT_SET */
    ldr r1, =(1 << 25)
    str r1, [r0]        /* GPIO25=1 */

    b .
