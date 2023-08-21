#ifndef lox_vm_h
#define lox_vm_h

#include "lox_chunk.h"

typedef struct {
	Chunk *chunk;
} VM;

void initVM();
void freeVM();

#endif
