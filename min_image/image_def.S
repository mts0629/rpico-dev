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

    .section .picobin_block, "a"
    /* Minimum valid IMAGE_DEF */
    .align 2
    .word 0xffffded3    /* PICOBIN_BLOCK_MARKER_START */
    .word 0x10210142    /* 0x42     : item_type == PICOBIN_BLOCK_ITEM_1BS_IMAGE_TYPE
                        0x01     : block size 1 is word 
                        0x1021   : (IMAGE_TYPE_EXE |
                                    EXE_SECURITY_S |
                                    EXE_CPU_ARM |
                                    EXE_CHIP_RP2350) */
    .word 0x000001ff    /* 0xff     : size_type == 1, item_type == PICOBIN_BLOCK_ITEM_2BS_LAST
                        0x0001   : other item's size is 1 word
                        0x00     : pad 0 */
    .word 0x00000000    /* 0x00000000 : relative pointer to next loop */
    .word 0xab123579    /* PICOBIN_BLOCK_MARKER_END */

    .section .text
    .thumb_func
    .global reset
reset:
    ldr r0, =0x20001000
    mov sp, r0
    bl halt

    .thumb_func
    .global halt
halt:
    b .
