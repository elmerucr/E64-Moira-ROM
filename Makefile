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
		obj/kernel.o \
		obj/kernel_asm.o \
		obj/monitor_asm.o \
		obj/monitor.o \
		obj/screeneditor.o \
		obj/sound.o \
		obj/tables.o \
		obj/test.o \
		obj/timer.o \
		obj/vectors.o

ASMTARGETS =	obj/blitter.s \
		obj/cia.s \
		obj/kernel.s \
		obj/monitor.s \
		obj/test.s

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
	rm mk_rom rom.bin rom_unpatched.bin rom.map rom.cpp $(OBJECTS)
	cd obj && rm *.list && rm *.s && cd ..
