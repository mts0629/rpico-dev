.cpu cortex-m0
.thumb

reset:
    ldr r0, =0x20000001
    mov sp, r0
    bl main
    b .

main:
    b .
