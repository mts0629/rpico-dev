    .cpu cortex-m0plus

    .section .picobin_block, "a"
    /* Minimum valid IMAGE_DEF */
image_def:
    .align 2
    .word   0xffffded3  /* PICOBIN_BLOCK_MARKER_START */
    .byte   0x42        /* item_type == PICOBIN_BLOCK_ITEM_1BS_IMAGE_TYPE */
    .byte   0x1         /* 1 word */
    .hword  0x1021      /* 0x1021 : (IMAGE_TYPE_EXE | EXE_SECURITY_S | EXE_CPU_ARM | EXE_CHIP_RP2350) */
    .byte   0xff        /* item_type == PICOBIN_BLOCK_ITEM_2BS_LAST */
    .hword  0x0001      /* Other item's size is 1 word */
    .byte   0x0         /* Padding */
    .word   0x00000000  /* 0x0: relative pointer to next block in loop */
    .word   0xab123579  /* PICOBIN_BLOCK_MARKER_END */
