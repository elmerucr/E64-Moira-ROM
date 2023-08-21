//#include <stdio.h>

#include "lox_debug.h"
#include "lox_value.h"
#include "monitor.h"

void disassembleChunk(Chunk* chunk, const char* name) {
	puts("\n== ");
	puts(name);
	puts(" ==");

	for (int offset = 0; offset < chunk->count;) {
		offset = disassembleInstruction(chunk, offset);
	}
}

static int constantInstruction(const char *name, Chunk *chunk, int offset)
{
	uint8_t constant = chunk->code[offset + 1];
	puts(name);
	putchar(' ');
	out6x(constant);
	puts(" '");
	printValue(chunk->constants.values[constant]);
	putchar('\'');
	return offset + 2;
}

static int simpleInstruction(const char* name, int offset) {
	puts(name);
	return offset + 1;
}

int disassembleInstruction(Chunk* chunk, int offset) {
	putchar('\n');
	out6x(offset);
	putchar(' ');

	if (offset > 0 && chunk->lines[offset] == chunk->lines[offset - 1]) {
		puts("   | ");
	} else {
		out4x(chunk->lines[offset]);
		puts(" ");
		//printf("%4d ", chunk->lines[offset]);
	}

	uint8_t instruction = chunk->code[offset];
	switch (instruction) {
		case OP_CONSTANT:
			return constantInstruction("OP_CONSTANT", chunk, offset);
		case OP_RETURN:
			return simpleInstruction("OP_RETURN", offset);
		default:
			puts("Unknown opcode ");
			out6x(instruction);
			return offset + 1;
	}
}
