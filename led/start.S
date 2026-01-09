.cpu cortex-m0plus
.thumb

reset:
    ldr r0, =0x20000100
    mov sp, r0
    bl led
    b .
