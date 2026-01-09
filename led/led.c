#include <stdint.h>

void write_reg(volatile uint32_t *addr, const uint32_t value) {
    *(volatile uint32_t*)addr = value;
}

uint32_t read_reg(volatile uint32_t *addr) {
    return *(volatile uint32_t*)addr;
}

int led(void) {
    write_reg(0x4000f000, (1 << 5));

    while (1) {
        if ((read_reg(0x4000c008) & (1 << 5)) != 0) {
            break;
        }
    }

    return 0;
}
