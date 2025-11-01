################################################################################
#  STM32F446RE MAKEFILE
#  Author: Linus Lindberg
#  MCU: STM32F446RE (Cortex-M4)
#  Toolchain: arm-none-eabi-gcc
################################################################################

######################################
# Project configuration
######################################
MEMORY_MODEL ?= ram
PROJECT_NAME ?= $(notdir $(CURDIR))
TARGET_DIR   := build/$(MEMORY_MODEL)
TARGET       := $(TARGET_DIR)/$(PROJECT_NAME)

######################################
# Feature toggles
######################################
LTO           ?= 0         # Link Time Optimization
NANO          ?= 1         # --specs=nano.specs
SEMIHOSTING   ?= 0         # 1: rdimon (GDB console), 0: nosys (egen retarget)
PRINTF_FLOAT  ?= 0         # -u _printf_float (+ _scanf_float)
USE_USART     ?= 1         # 1: auto-inkludera usart2_init.c + retarget_usart.c

# (valfritt) tysta RWX-varningen i RAM-bygge
NO_RWX_WARN   ?= 0

######################################
# TOOLCHAIN
######################################
CC    := arm-none-eabi-gcc
AS    := arm-none-eabi-as
CP    := arm-none-eabi-objcopy
OD    := arm-none-eabi-objdump
SZ    := arm-none-eabi-size
AR    := arm-none-eabi-ar
RM    := rm -rf
MKDIR := mkdir -p

######################################
# MCU & build options
######################################
MCU       := cortex-m4
FPU       := fpv4-sp-d16
FLOAT_ABI := softfp

CSTD  := -std=c11
OPT   := -O0
DEBUG := -g3

# Extra -D från kommandorad: make DEFS="-DSTM32F446xx -DUSE_STDPERIPH_DRIVER"
DEFS  ?=

######################################
# DIRECTORIES
######################################
SRC_DIRS   := src lib lib/src lib/lelles/src
INC_DIRS   := inc lib lib/inc lib/lelles/inc
LINKER_DIR := linker
LINKER_SCRIPT := $(LINKER_DIR)/stm32f446re_$(MEMORY_MODEL).ld

VPATH := $(SRC_DIRS)

######################################
# Files
######################################
SRCS_c := $(foreach d,$(SRC_DIRS),$(wildcard $(d)/*.c))
SRCS_s := $(foreach d,$(SRC_DIRS),$(wildcard $(d)/*.s))
SRCS_S := $(foreach d,$(SRC_DIRS),$(wildcard $(d)/*.S))
SRCS   := $(SRCS_c) $(SRCS_s) $(SRCS_S)

# Auto-inkludera USART-moduler vid USE_USART=1
ifeq ($(USE_USART),1)
  # Säkerställ SPL/MCU-defines när vi använder SPL-drivare i modulerna
  SRCS += lib/lelles/src/usart2_init.c lib/lelles/src/retarget_usart.c
  # Undvik krock med semihostingstubs
  SEMIHOSTING := 0
endif

OBJS := $(patsubst %.c,$(TARGET_DIR)/%.o,$(SRCS_c)) \
        $(patsubst %.s,$(TARGET_DIR)/%.o,$(SRCS_s)) \
        $(patsubst %.S,$(TARGET_DIR)/%.o,$(SRCS_S))

DEPS := $(OBJS:.o=.d)

######################################
# Flags
######################################
CFLAGS := $(CSTD) $(OPT) $(DEBUG) $(DEFS)
CFLAGS += -mcpu=$(MCU) -mthumb -mfpu=$(FPU) -mfloat-abi=$(FLOAT_ABI)
CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += -Wall -Wextra
CFLAGS += $(addprefix -I,$(INC_DIRS))
CFLAGS += -Wno-unused-parameter -Wno-unused-variable

ASFLAGS := -mcpu=$(MCU) -mthumb

LDFLAGS := -T$(LINKER_SCRIPT) -Wl,--gc-sections -Wl,-Map=$(TARGET).map
LDFLAGS += -mcpu=$(MCU) -mthumb -mfpu=$(FPU) -mfloat-abi=$(FLOAT_ABI)

ifeq ($(NANO),1)
  LDFLAGS += --specs=nano.specs
endif

ifeq ($(PRINTF_FLOAT),1)
  LDFLAGS += -u _printf_float -u _scanf_float
endif

ifeq ($(LTO),1)
  CFLAGS  += -flto
  LDFLAGS += -flto
endif

ifeq ($(NO_RWX_WARN),1)
  LDFLAGS += -Wl,--no-warn-rwx-segments
endif

ifeq ($(SEMIHOSTING),1)
  LDLIBS := -lc -lm -lrdimon
  LDFLAGS += --specs=rdimon.specs
else
  LDLIBS := -lc -lm -lnosys
endif

######################################
# Default target
######################################
.PHONY: all
all: $(TARGET).elf $(TARGET).bin $(TARGET).hex

######################################
# Build rules
######################################
$(TARGET_DIR)/%.o: %.c
	@$(MKDIR) $(dir $@)
	@printf "\033[1;34m[CC]\033[0m  %s\n" "$<"
	@$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(TARGET_DIR)/%.o: %.s
	@$(MKDIR) $(dir $@)
	@printf "\033[1;35m[AS]\033[0m  %s\n" "$<"
	@$(CC) $(ASFLAGS) -x assembler -c $< -o $@

$(TARGET_DIR)/%.o: %.S
	@$(MKDIR) $(dir $@)
	@printf "\033[1;35m[AS]\033[0m  %s\n" "$<"
	@$(CC) $(ASFLAGS) -x assembler-with-cpp -c $< -o $@

$(TARGET).elf: $(OBJS)
	@printf "\033[1;32m[LD]\033[0m  %s\n" "$@"
	@$(CC) $(OBJS) -o $@ $(LDFLAGS) $(LDLIBS)
	@$(SZ) $@

$(TARGET).hex: $(TARGET).elf
	@printf "\033[1;36m[OBJCOPY]\033[0m  %s\n" "$@"
	@$(CP) -O ihex $< $@

$(TARGET).bin: $(TARGET).elf
	@printf "\033[1;36m[OBJCOPY]\033[0m  %s\n" "$@"
	@$(CP) -O binary $< $@

######################################
# Clean
######################################
.PHONY: clean
clean:
	@printf "\033[1;31m[RM]\033[0m  Cleaning build artifacts...\n"
	@$(RM) $(TARGET_DIR)
	@$(RM) $(TARGET).map $(TARGET).elf $(TARGET).bin $(TARGET).hex $(TARGET).lst

######################################
# Include dependency files
######################################
-include $(DEPS)

######################################
# Convenience targets
######################################
.PHONY: flash ram list program size rebuild run debug disasm help

flash:
	@$(MAKE) MEMORY_MODEL=flash all

ram:
	@$(MAKE) MEMORY_MODEL=ram all

list:
	@echo "Project:        $(PROJECT_NAME)"
	@echo "Memory model:   $(MEMORY_MODEL)"
	@echo "Linker:         $(LINKER_SCRIPT)"
	@echo "Sources:        $(words $(SRCS)) files"
	@echo "Toggles:        LTO=$(LTO) NANO=$(NANO) SEMIHOSTING=$(SEMIHOSTING) PRINTF_FLOAT=$(PRINTF_FLOAT) USE_USART=$(USE_USART)"

program: $(TARGET).bin
	@printf "\033[1;33m[FLASH]\033[0m  Writing %s to MCU...\n" "$(TARGET).bin"
	st-flash write $(TARGET).bin 0x08000000 && st-flash reset

size: $(TARGET).elf
	@$(SZ) --format=berkeley $<

rebuild: clean all

run: program

debug: $(TARGET).elf
	@printf "\033[1;33m[DEBUG]\033[0m  Launching GDB...\n"
	st-util &
	sleep 1
	arm-none-eabi-gdb -ex "target extended-remote :4242" $(TARGET).elf

disasm: $(TARGET).elf
	@printf "\033[1;36m[OBJDUMP]\033[0m  %s\n" "$(TARGET).lst"
	@$(OD) -d -S $(TARGET).elf > $(TARGET).lst

help:
	@echo "make                # Build (default RAM)"
	@echo "make flash          # Build for FLASH"
	@echo "make ram            # Build for RAM"
	@echo "make program        # Flash via st-flash"
	@echo "make debug          # Start st-util + GDB"
	@echo "make disasm         # Generate disassembly .lst"
	@echo "make clean          # Clean"
	@echo "Toggles: LTO=0/1, NANO=0/1, SEMIHOSTING=0/1, PRINTF_FLOAT=0/1, USE_USART=0/1"
