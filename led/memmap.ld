MEMORY {
    FLASH (rx) : ORIGIN = 0x10000000, LENGTH = 256 - 4
}

SECTIONS {
    .text : {
        *(.text)
    } > FLASH
}
