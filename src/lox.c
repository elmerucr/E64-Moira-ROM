#include "lox.h"
#include "lox_chunk.h"
#include "lox_common.h"
#include "lox_debug.h"
#include "blitter.h"

void lox_main()
{
	Chunk chunk;
	initChunk(&chunk);
	int8_t constant = addConstant(&chunk, 34);
	int8_t constant2 = addConstant(&chunk, 15);
	writeChunk(&chunk, OP_RETURN);
	writeChunk(&chunk, OP_CONSTANT);
	writeChunk(&chunk, constant);
	writeChunk(&chunk, OP_CONSTANT);
	writeChunk(&chunk, constant2);
	writeChunk(&chunk, OP_CONSTANT);
	writeChunk(&chunk, constant2);
	writeChunk(&chunk, OP_RETURN);
	disassembleChunk(&chunk, "test chunk");
	freeChunk(&chunk);
}
