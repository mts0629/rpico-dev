    .cpu cortex-m33
    .thumb

    // Register addresses
    .equ CLOCKS_BASE, 0x40010000
    .equ CLK_REF_CTRL, (CLOCKS_BASE + 0x30)
    .equ CLK_REF_SELECTED, (CLOCKS_BASE + 0x38)
    .equ CLK_SYS_CTRL, (CLOCKS_BASE + 0x3c)
    .equ CLK_SYS_DIV, (CLOCKS_BASE + 0x40)
    .equ CLK_SYS_SELECTED, (CLOCKS_BASE + 0x44)
    .equ CLK_PERI_CTRL, (CLOCKS_BASE + 0x48)

    .equ RESETS_BASE, 0x40020000
    .equ RESETS_RESET, (RESETS_BASE + 0x0)
    .equ RESETS_DONE, (RESETS_BASE + 0x8)

    .equ IO_BANK0_BASE, 0x40028000
    .equ GPIO0_CTRL, (IO_BANK0_BASE + 0x4)
    .equ GPIO25_CTRL, (IO_BANK0_BASE + 0xcc)

    .equ PADS_BANK0_BASE, 0x40038000
    .equ GPIO0, (PADS_BANK0_BASE + 0x4)
    .equ GPIO25, (PADS_BANK0_BASE + 0x68)

    .equ XOSC_BASE, 0x40048000
    .equ XOSC_CTRL, (XOSC_BASE + 0x0)
    .equ XOSC_STATUS, (XOSC_BASE + 0x4)
    .equ XOSC_STARTUP, (XOSC_BASE + 0xc)

    .equ UART0_BASE, 0x40070000
    .equ UART0_UARTDR, (UART0_BASE + 0x0)
    .equ UART0_UARTFR, (UART0_BASE + 0x18)
    .equ UART0_UARTIBRD, (UART0_BASE + 0x24)
    .equ UART0_UARTFBRD, (UART0_BASE + 0x28)
    .equ UART0_UARTLCR_H, (UART0_BASE + 0x2c)
    .equ UART0_UARTCR, (UART0_BASE + 0x30)

    .equ SIO_BASE, 0xd0000000
    .equ GPIO_OUT, (SIO_BASE + 0x10)
    .equ GPIO_OUT_SET, (SIO_BASE + 0x18)
    .equ GPIO_OUT_CLR, (SIO_BASE + 0x20)
    .equ GPIO_OE_SET, (SIO_BASE + 0x38)

    .equ PPB_BASE, 0xe0000000
    .equ SYST_CSR, (PPB_BASE + 0xe010)
    .equ SYST_RVR, (PPB_BASE + 0xe014)
    .equ SYST_CVR, (PPB_BASE + 0xe018)

    .section .rodata
    message: .asciz "Hello\r\n"     // Message string

    .section .text
    // SysTick handler
    .thumb_func
    .global systick
systick:
    push {r4}   // Save r4 (callee-saved register)

    // Blink LED
    ldr r0, =GPIO_OUT
    ldr r1, [r0]        // Read current GPIO outputs
    ldr r2, =(1 << 25)
    eor r1, r1, r2      // Reverse GPIO25
    str r1, [r0]

    // UART data transmission
    ldr r0, =message
1:
    // Load a character
    ldrb r1, [r0]
    cmp r1, #0
    beq 3f                  // Finish transmission on '\0'

    // Check transmit FIFO is empty
    ldr r2, =UART0_UARTFR
    ldr r3, =(1 << 5)       // TXFF
2:
    str r4, [r2]
    tst r3, r4
    bne 2b

    // Send a character
    ldr r2, =UART0_UARTDR
    str r1, [r2]

    // Proceed to the next character
    add r0, r0, #1
    b 1b
3:
    pop {r4}    // Restore r4
    bx lr

    // Polling a register (r0: register, r1: expected bits)
    .thumb_func
poll:
    ldr r2, [r0]
    orr r1, r1, r2
1:
    ldr r2, [r0]
    cmp r1, r2
    bne 1b
    bx lr

    .thumb_func
    .global main
main:
    // Reset to the default configuration (ROSC)
    ldr r0, =CLK_REF_CTRL
    mov r1, #0                  // SRC: ROSC_CLKSRC_PH
    str r1, [r0] 
    ldr r0, =CLK_REF_SELECTED
    mov r1, #1                  // ROSC_CLKSRC_PH
    bl poll
    ldr r0, =CLK_SYS_CTRL
    ldr r1, =((2 << 5) | 1)     // AUXSRC: ROSC_CLKSRC
                                // SRC: CLKSRC_CLK_SYS_AUX
    str r1, [r0]
    ldr r0, =CLK_SYS_SELECTED
    mov r1, #(1 << 1)           // CLKSRC_CLK_SYS_AUX
    bl poll

    // Activate an XOSC
    ldr r0, =XOSC_STARTUP
    ldr r1, =47                         // DELAY: 47
                                        // -> ((crystal freq.) x (stable time)) / 256
                                        // when the stable time is 1[ms]:
                                        // (12 x (10^6)) x (10^(-3)) / 256 = 46.875 ~ 47
    str r1, [r0]
    ldr r0, =XOSC_CTRL
    ldr r1, =((0xfab << 12) | 0xaa0)    // ENABLE: enable (0xfab)
                                        // FREQ_RANGE: 1_15MHZ
                                        // (12 MHz crystal is used)
    str r1, [r0]
    ldr r0, =XOSC_STATUS
    ldr r1, =0x80000000                 // STABLE
    bl poll

    // Set source of the reference clock
    ldr r0, =CLK_REF_CTRL
    mov r1, #2                  // SRC: XOSC_CLKSRC
    str r1, [r0]
    ldr r0, =CLK_REF_SELECTED
    mov r1, #(1 << 2)           // XOSC_CLKSRC
    bl poll

    // Set source of the system clock
    ldr r0, =CLK_SYS_CTRL
    ldr r1, [r0]
    mov r2, #1
    and r1, r1, r2                 // SRC: CLKSRC_CLK_SYS_AUX
    mov r2, #(3 << 5)
    orr r1, r1, r2                 // AUXSRC: XOSC_CLKSRC
    str r1, [r0]
    ldr r0, =CLK_SYS_SELECTED
    mov r1, #(1 << 1)              // CLKSRC_CLK_SYS_AUX
    bl poll
    ldr r0, =CLK_SYS_DIV
    ldr r1, =(1 << 16)             // INT=1, FRAC=0: no division
    str r1, [r0]

    // Enable peripheral clock
    ldr r0, =CLK_PERI_CTRL
    ldr r1, [r0]
    ldr r2, =(1 << 11)  // ENABLE, AUXSRC: CLK_SYS
    orr r1, r1, r2
    str r1, [r0]
    ldr r1, =(1 << 28)  // ENABLED
    bl poll

    // Deassert reset
    ldr r0, =RESETS_RESET
    ldr r2, [r0]
    ldr r1, =((1 << 26) | (1 << 9) | (1 << 6)) // UART0, PADS_BANK0, IO_BANK0
    bic r2, r2, r1
    str r2, [r0]
    ldr r0, =RESETS_DONE
    bl poll

    // Disable a pad isolation latch (ISO)
    ldr r0, =GPIO0
    ldr r1, [r0]
    ldr r2, =(1 << 8)
    bic r1, r1, r2
    str r1, [r0]
    ldr r0, =GPIO25
    ldr r1, [r0]
    ldr r2, =(1 << 8)
    bic r1, r1, r2
    str r1, [r0]

    // Set TX
    ldr r0, =GPIO0_CTRL
    mov r1, #2              // FUNCSEL: UART0_TX
    str r1, [r0]

    // Set SIO (Software I/O)
    ldr r0, =GPIO25_CTRL
    mov r1, #5              // FUNCSEL: SIO_25
    str r1, [r0]

    // Enable output
    ldr r0, =GPIO_OE_SET
    ldr r1, =(1 << 25)
    str r1, [r0]

    ldr r0, =SYST_CSR
    mov r1, #7              // CLKSOURCE: processor clock,
                            // TICKINT: assert the SysTick expecption request,
                            // ENABLE: counter enabled
    str r1, [r0]
    ldr r0, =SYST_RVR
    ldr r1, =12000000       // RELOAD: 12000000,
                            // interrupt every 12,000,000 clock cycles
                            // (= 1 sec)
    str r1, [r0]
    ldr r0, =SYST_CVR 
    mov r1, #0              // Reset the current value of the SysTick counter
    str r1, [r0]

    // Disable UART
    ldr r0, =UART0_UARTCR
    mov r1, #0
    str r1, [r0]

    // Configure UART
    ldr r0, =UART0_UARTIBRD
    mov r1, #78                     // Baudrate: 9600[bps]
    str r1, [r0]
    ldr r0, =UART0_UARTFBRD
    mov r1, #8
    str r1, [r0]
    ldr r0, =UART0_UARTLCR_H
    ldr r1, =(3 << 5) | (1 << 4)    // WLEN: 8, FEN: 1, PEN: 0
    str r1, [r0]

    // Enable UART
    ldr r0, =UART0_UARTCR
    ldr r1, =((1 << 8) | 1) // TXE: 1, UARTEN: 1
    str r1, [r0]

    // Enable IRQ
    cpsie i

    // Main loop
loop:
    b .

    bx lr
