PREFIX = arm-none-eabi-

.PHONY: clean

led.uf2: led.elf
	../tools/picotool uf2 convert $^ -t elf $@ -t uf2

led.elf: start.o led.o
	$(PREFIX)ld -nostdlib -T memmap.ld $^ -o led.elf

%.o: %.S
	$(PREFIX)as -mcpu=cortex-m0 -mthumb -c $< -o $@

%.o: %.c
	$(PREFIX)gcc -mcpu=cortex-m0 -ffreestanding -nostartfiles -mthumb -c $< -o $@

clean:
	@rm *.o
	@rm *.elf
	@rm *.uf2
