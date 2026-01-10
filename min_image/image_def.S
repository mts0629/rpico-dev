.cpu cortex-m0plus
.thumb

.section .rodata
/* Minimum valid IMAGE_DEF */
.align 4
.long 0xffffded3    /* PICOBIN_BLOCK_MARKER_START */
.long 0x10210142    /* 0x42     : item_type == PICOBIN_BLOCK_ITEM_1BS_IMAGE_TYPE
                       0x01     : block size 1 is word 
                       0x1021   : (IMAGE_TYPE_EXE |
                                   EXE_SECURITY_S |
                                   EXE_CPU_ARM |
                                   EXE_CHIP_RP2350) */
.long 0x000001ff    /* 0xff     : size_type == 1, item_type == PICOBIN_BLOCK_ITEM_2BS_LAST
                       0x0001   : other item's size is 1 word
                       0x00     : pad 0 */
.long 0x00000000    /* 0x00000000 : relative pointer to next loop */
.long 0xab123579    /* PICOBIN_BLOCK_MARKER_END */
