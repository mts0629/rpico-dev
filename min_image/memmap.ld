MEMORY {
    FLASH (rx) : ORIGIN = 0x10000000, LENGTH = 0x14
}

SECTIONS {
    .rodata : {
        *(.rodata)
    } > FLASH
}
