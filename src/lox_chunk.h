#ifndef lox_chunk_h
#define lox_chunk_h

#include "lox_common.h"
#include "libc_stdint.h"
#include "lox_value.h"

typedef enum {
	OP_CONSTANT,
	OP_RETURN
} OpCode;

typedef struct {
	int count;
	int capacity;
	uint8_t *code;
	ValueArray constants;
} Chunk;

void initChunk(Chunk* chunk);
void freeChunk(Chunk* chunk);
void writeChunk(Chunk* chunk, uint8_t byte);
int addConstant(Chunk *chunk, Value value);

#endif
