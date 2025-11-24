ASM := nasm
LD := ld
OUTPUT := out
SRC := main.asm functions.asm
OBJ := $(SRC:.asm=.o)

ASMFLAGS := -f elf
LDFLAGS := -m elf_i386

all: $(OUTPUT)

$(OUTPUT): $(OBJ)
	$(LD) $(LDFLAGS) -o $@ $^

%.o: %.asm
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f $(OBJ) $(OUTPUT)

run: $(OUTPUT)
	./$(OUTPUT)

.PHONY: all clean run
