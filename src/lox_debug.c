//#include <stdio.h>

#include "lox_debug.h"
#include "monitor.h"

void disassembleChunk(Chunk* chunk, const char* name) {
	puts("\n== ");
	puts(name);
	puts(" ==");

	for (int offset = 0; offset < chunk->count;) {
		offset = disassembleInstruction(chunk, offset);
	}
}

static int simpleInstruction(const char* name, int offset) {
	puts(name);
	return offset + 1;
}

int disassembleInstruction(Chunk* chunk, int offset) {
	putchar('\n');
	out6x(offset);
	putchar(' ');

	uint8_t instruction = chunk->code[offset];
	switch (instruction) {
		case OP_RETURN:
			return simpleInstruction("OP_RETURN", offset);
		default:
			puts("Unknown opcode ");
			out6x(instruction);
			return offset + 1;
	}
}
