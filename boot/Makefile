PREFIX = arm-none-eabi

boot.uf2: start.o
	$(PREFIX)-ld -nostdlib -T map.ld $^ -o boot.elf
	../tools/picotool uf2 convert boot.elf -t elf $@ -t uf2

%.o: %.S
	$(PREFIX)-as -c $< -o $@
