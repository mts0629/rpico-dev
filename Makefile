PREFIX = arm-none-eabi-
MCPU = -mcpu=cortex-m33
ASFLAGS = -mthumb
TARGET = prog.elf

BUILD ?= release
ifeq ($(BUILD), debug)
	ASFLAGS += -g
endif

SRCS = $(wildcard *.S)
OBJS = $(SRCS:.S=.o)

.PHONY: clean

$(TARGET): $(OBJS)
	$(PREFIX)ld -nostdlib -T memmap.ld $^ -o $@

%.o: %.S
	$(PREFIX)as $(MCPU) $(ASFLAGS) -c $< -o $@

clean:
	@rm *.o
	@rm *.elf
