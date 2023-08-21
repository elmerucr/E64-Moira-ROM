#include "lox.h"
#include "lox_chunk.h"
#include "lox_common.h"
#include "lox_debug.h"
#include "lox_vm.h"
#include "monitor.h"
#include "blitter.h"
#include "libc_stdlib.h"

void lox_main()
{
	//putchar('\n');
	//out6x(0x1234);
	//putchar('\n');
	//out6x(0x12);
	//putchar('\n');
	//putchar('\n');
	//out6x((u32)malloc(0x1f));
	//putchar('\n');
	//out6x((u32)malloc(0x20));
	//putchar('\n');
	//out6x((u32)malloc(0x20));
	putchar('\n');

	initVM();
	Chunk chunk;
	initChunk(&chunk);
	int8_t constant = addConstant(&chunk, 34);
	int8_t constant2 = addConstant(&chunk, 15);
	writeChunk(&chunk, OP_RETURN, 123);
	writeChunk(&chunk, OP_CONSTANT, 123);
	writeChunk(&chunk, constant, 123);
	writeChunk(&chunk, OP_CONSTANT, 223);
	writeChunk(&chunk, constant2, 223);
	writeChunk(&chunk, OP_CONSTANT, 223);
	writeChunk(&chunk, constant2, 223);
	writeChunk(&chunk, OP_RETURN, 223);
	disassembleChunk(&chunk, "test chunk");
	freeVM();
	freeChunk(&chunk);
}
