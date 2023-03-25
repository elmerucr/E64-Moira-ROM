#ifndef LIBC_ALLOCATION_H
#define LIBC_ALLOCATION_H

#include "libc_stdint.h"
#include "libc_stddef.h"
#include "libc_stdbool.h"

struct block {
	size_t size;		// must be evenly sized
	bool free;		// 0 = occupied, 1 = free
	struct block *next;
};

void allocation_init();
void allocation_split(struct block *fitting_slot, size_t size);

#endif
