#include "lox.h"
#include "lox_chunk.h"
#include "lox_common.h"
#include "lox_debug.h"
#include "blitter.h"

void lox_main()
{
	//puts("\n<lox>");
	Chunk chunk;
	initChunk(&chunk);
	writeChunk(&chunk, OP_RETURN);
	writeChunk(&chunk, OP_RETURN);
	disassembleChunk(&chunk, "test chunk");
	freeChunk(&chunk);
}
