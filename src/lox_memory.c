#include "libc_stdlib.h"

#include "lox_memory.h"

void* reallocate(void* pointer, size_t oldSize, size_t newSize) {
	if (newSize == 0) {
		free(pointer);
		return 0x00000000;
	}

	void* result = realloc(pointer, newSize);
	if (result == 0x00000000) {
		// PANIC!!!
	}
	return result;
}
