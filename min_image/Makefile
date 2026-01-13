PREFIX = arm-none-eabi-
MCPU = -mcpu=cortex-m0plus

.PHONY: clean

min_image.uf2: min_image.elf
	picotool uf2 convert $< -t elf $@ -t uf2

min_image.elf: image_def.o
	$(PREFIX)ld -nostdlib -T memmap.ld $< -o $@

%.o: %.S
	$(PREFIX)as $(MCPU) -mthumb -c $< -o $@

clean:
	@rm *.o
	@rm *.elf
	@rm *.uf2
