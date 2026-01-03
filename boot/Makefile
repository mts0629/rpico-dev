PREFIX = arm-none-eabi

boot.bin: start.o
	$(PREFIX)-ld -nostdlib -T map.ld $^ -o boot.elf
	$(PREFIX)-objcopy -O binary boot.elf $@

%.o: %.S
	$(PREFIX)-as -c $< -o $@
