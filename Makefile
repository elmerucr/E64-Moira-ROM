AS =		vasmm68k_mot
LD =		vlink
CC =		vbccm68ks
VPATH =		src obj

# The reset.o object must be first to ensure proper start of the executable code.
OBJECTS =	obj/reset.o

# Order of the rest of the objects doesn't matter.
OBJECTS +=	obj/blitter_asm.o \
		obj/blitter.o \
		obj/cia.o \
		obj/forth.o \
		obj/kernel.o \
		obj/kernel_asm.o \
		obj/libc_allocation.o \
		obj/lox.o \
		obj/lox_chunk.o \
		obj/lox_debug.o \
		obj/lox_memory.o \
		obj/lox_value.o \
		obj/lox_vm.o \
		obj/monitor_asm.o \
		obj/monitor.o \
		obj/screeneditor.o \
		obj/screeneditor_asm.o \
		obj/sound.o \
		obj/tables.o \
		obj/timer.o \
		obj/vectors.o

ASMTARGETS =	obj/blitter.s \
		obj/cia.s \
		obj/kernel.s \
		obj/libc_allocation.s \
		obj/lox.s \
		obj/lox_chunk.s \
		obj/lox_debug.s \
		obj/lox_memory.s \
		obj/lox_value.s \
		obj/lox_vm.s \
		obj/monitor.s \
		obj/screeneditor.s \
		obj/sound.s

# Sometimes there seems be strange behaviour related to the -align option. Now
# it seems ok. Another way would be to use the -devpac option?
ASFLAGS = -align -no-opt -Felf -m68020 -quiet
LDFLAGS = -b rawbin1 -Trom.ld -Mrom.map
CFLAGS =  -quiet -use-framepointer -cpu=68020

CCNATIVE = gcc

all: rom.bin

rom.bin: rom_unpatched.bin mk_rom
	./mk_rom

mk_rom: tools/mk_rom.c
	$(CCNATIVE) -o mk_rom tools/mk_rom.c

rom_unpatched.bin: $(OBJECTS) rom.ld
	$(LD) $(LDFLAGS) $(OBJECTS) -o $@

$(ASMTARGETS) : obj/%.s : src/%.c
	$(CC) $(CFLAGS) -o=$@ $<

obj/%.o : %.s
	$(AS) $(ASFLAGS) $< -o $@ -L $@.list

.PHONY: clean
clean:
	rm mk_ro* *.bin *.map ro*.cpp $(ASMTARGETS) $(OBJECTS)
	cd obj && rm *.list && cd ..
