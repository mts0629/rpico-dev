PREFIX = arm-none-eabi-

led.uf2: start.o
	$(PREFIX)ld -nostdlib -T memmap.ld $^ -o led.elf
	../tools/picotool uf2 convert led.elf -t elf $@ -t uf2

%.o: %.S
	$(PREFIX)as -mcpu=cortex-m0plus -mthumb -c $< -o $@
