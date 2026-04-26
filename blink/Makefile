PREFIX = arm-none-eabi-
MCPU = -mcpu=cortex-m33
ASFLAGS = -mthumb

BUILD ?= release
ifeq ($(BUILD), debug)
	ASFLAGS += -g
endif

.PHONY: clean

blink.elf: image_def.o main.o
	$(PREFIX)ld -nostdlib -T memmap.ld $^ -o $@

%.o: %.S
	$(PREFIX)as $(MCPU) $(ASFLAGS) -c $< -o $@

clean:
	@rm *.o
	@rm *.elf
