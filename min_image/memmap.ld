MEMORY {
    FLASH (rx) : ORIGIN = 0x10000000, LENGTH = 0x1000
}

SECTIONS {
    .text : {
        *(.vectors)
        *(.picobin_block)
        *(.text)
    } > FLASH
}
