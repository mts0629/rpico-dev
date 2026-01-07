MEMORY {
    SRAM (rwx) : ORIGIN = 0x20000000, LENGTH = 256K
}

SECTIONS {
    .text : {
        *(.text)
    } > SRAM
}
