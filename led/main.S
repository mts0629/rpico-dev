    .cpu cortex-m33
    .thumb

    /* Register addresses */
    .equ RESETS_BASE, 0x40020000
    .equ RESETS_RESET, (RESETS_BASE + 0x0)
    .equ RESETS_DONE, (RESETS_BASE + 0x8)

    .equ PADS_BANK0_BASE, 0x40038000
    .equ GPIO25, (PADS_BANK0_BASE + 0x68)

    .equ IO_BANK0_BASE, 0x40028000
    .equ GPIO25_CTRL, (IO_BANK0_BASE + 0xcc)

    .equ SIO_BASE, 0xd0000000
    .equ GPIO_OUT_SET, (SIO_BASE + 0x18)
    .equ GPIO_OE_SET, (SIO_BASE + 0x38)

    .section .text
    .thumb_func
    .global main
main:
    /* Release I/O from reset */
    ldr r0, =RESETS_RESET
    ldr r1, [r0]
    ldr r2, =((1 << 9) | (1 << 6))
    bic r1, r1, r2                  /* PADS_BANK0=IO_BANK0=0 */
    str r1, [r0]
    ldr r0, =RESETS_DONE
wait_reset_done:
    ldr r1, [r0]
    and r1, r1, r2
    cmp r1, r2
    bne wait_reset_done

    /* Set a pad */
    ldr r0, =GPIO25
    ldr r1, [r0]
    ldr r2, =(1 << 8)
    bic r1, r1, r2                  /* ISO=0 */
    str r1, [r0]

    /* Set SIO (Software I/O) */
    ldr r0, =GPIO25_CTRL
    mov r1, #5
    str r1, [r0]                    /* FUNCSEL: SIO_25 */

    /* Enable output of GPIO25 */
    ldr r0, =GPIO_OE_SET
    ldr r1, =(1 << 25)
    str r1, [r0]                    /* GPIO25=1 */

    /* GPIO25 (LED) on */
    ldr r0, =GPIO_OUT_SET
    ldr r1, =(1 << 25)
    str r1, [r0]                    /* GPIO25=1 */

    b .
