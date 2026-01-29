PREFIX = arm-none-eabi-
MCPU = -mcpu=cortex-m0plus

.PHONY: clean

led.uf2: led.elf
	picotool uf2 convert $< -t elf $@ -t uf2

led.elf: image_def.o start.o main.o
	$(PREFIX)ld -nostdlib -T memmap.ld $^ -o $@

%.o: %.S
	$(PREFIX)as $(MCPU) -mthumb -c $< -o $@

clean:
	@rm *.o
	@rm *.elf
	@rm *.uf2
