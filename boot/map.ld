MEMORY {
    FLASH (rx) : ORIGIN = 0x10000000, LENGTH = 256K
}

SECTIONS {
    .text : {
        *(.text)
    } > FLASH
}
