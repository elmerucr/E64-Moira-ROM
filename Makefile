AS =		vasmm68k_mot
LD =		vlink
VPATH =		src obj

# The reset.o object must be first to ensure proper start of the executable code.
OBJECTS =	obj/reset.o

# Order of the rest of the objects doesn't matter.
OBJECTS +=	obj/blitter.o \
		obj/kernel.o \
		obj/sound.o \
		obj/tables.o \
		obj/test.o \
		obj/timer.o

SOBJECTS =	obj/test.s

# Sometimes there seems be strange behaviour related to the -align option. Now
# it seems ok. Another way would be to use the -devpac option?
ASFLAGS = -align -no-opt -Felf -m68000 -quiet
LDFLAGS = -b rawbin1 -Trom.ld -Mrom.map

CCNATIVE = gcc

all: rom.bin

rom.bin: rom_unpatched.bin mk_rom
	./mk_rom

rom_unpatched.bin: $(OBJECTS) rom.ld
	$(LD) $(LDFLAGS) $(OBJECTS) -o rom_unpatched.bin

$(SOBJECTS) : obj/%.s : src/%.c
	vc -S -quiet -use-framepointer -cpu=68000 -o=$@ $<

obj/%.o : %.s
	$(AS) $(ASFLAGS) $< -o $@ -L $@.list

mk_rom: tools/mk_rom.c
	$(CCNATIVE) -o mk_rom tools/mk_rom.c

.PHONY: clean
clean:
	rm mk_rom rom.bin rom_unpatched.bin rom.map rom.cpp $(OBJECTS)
	cd obj && rm *.list && rm *.s && cd ..
