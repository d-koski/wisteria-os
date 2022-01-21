SOURCE_DIR ?=
OUTPUT_DIR ?=

NASM ?= nasm
NASM_FLAGS ?= -f bin -I$(SOURCE_DIR)/source/mbr/

mbr:
	mkdir -p $(OUTPUT_DIR)
	$(NASM) $(NASM_FLAGS) -o $(OUTPUT_DIR)/mbr.bin $(SOURCE_DIR)/source/mbr/bootloader.asm
