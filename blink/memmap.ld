MEMORY {
    FLASH (rx) : ORIGIN = 0x10000000, LENGTH = 0x1000
}

SECTIONS {
    .vectors ORIGIN(FLASH) : {
        KEEP(*(.vectors))
    } > FLASH

    .picobin_block : {
        KEEP(*(.picobin_block))
    } > FLASH

    .text : {
        *(.text)
    } > FLASH
}
