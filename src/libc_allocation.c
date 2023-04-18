//#include <stdlib.h>
//#include <string.h>
#include "libc_allocation.h"
//#include "kernel.h"

/*
 * Some ideas have been inspired by:
 * http://tharikasblogs.blogspot.com/p/how-to-write-your-own-malloc-and-free.html
 */

struct block *block_list;

extern void *heap_start;
extern void *heap_end;

void allocation_init()
{
	block_list = (struct block *)heap_start;

	// set the first block
	block_list->size = ((size_t)heap_end - (size_t)heap_start) - sizeof(struct block);
	block_list->free = true;
	block_list->next = 0x00000000;
}

void allocation_split(struct block *fitting_slot, size_t size)
{
	struct block *new = (void *)((size_t)fitting_slot + size + sizeof(struct block));

	new->size = (fitting_slot->size) - size - sizeof(struct block);
	new->free = true;
	new->next = fitting_slot->next;

	fitting_slot->size = size;
	fitting_slot->free = false;
	fitting_slot->next = new;
}

void *malloc(size_t bytes)
{
	// ensure even amount of bytes
	if (bytes & 0x1) bytes++;

	struct block *curr, *prev;
	void *result;

	curr = block_list;

	while (((curr->size) < bytes) || ((curr->free) == false) && ((curr->next) != 0x00000000)) {
		prev = curr;
		curr = curr->next;
	}

	if ((curr->size) == bytes) {
		curr->free = false;
		result = (void *)++curr; // points to memory straight after struct
		// exact fitting of required memory
		return result;
	} else if ((curr->size) > (bytes + sizeof(struct block))) {
		allocation_split(curr, bytes);
		result = (void *)++curr;
		// allocation with a split
		return result;
	} else {
		result = 0x00000000;
		// no memory available from heap
		return result;
	}
}

static void allocation_merge()
{
	struct block *curr, *prev;
	curr = block_list;
	while ((curr->next) != 0x00000000) {
		if ((curr->free) && (curr->next->free)) {
			curr->size += (curr->next->size) + sizeof(struct block);
			curr->next = curr->next->next;
		}
		prev = curr;
		curr = curr->next;
	}
}

void free(void *ptr)
{
	// NEEDS WORK
	// this is a very minimal implementation
	// doesn't iterate through the blocks to check if the given pointer is valid
	if ( (((void *)block_list) <= ptr) && (ptr <= ((void *)heap_end))) {
		struct block *curr = ptr;
		--curr;
		curr->free = true;
		allocation_merge();
	}
}

static size_t allocation_get_size(void *ptr)
{
	struct block *curr = ptr;
	--curr;
	return curr->size;
}

void *realloc(void *ptr, size_t size)
{
	if (ptr == 0x00000000) {
		return malloc(size);
	}

	size_t old_size = allocation_get_size(ptr);

	if (size < old_size)
		return ptr;

	void *new_ptr = malloc(size);

	if (new_ptr == 0x00000000) {
		return 0x00000000;
	}

	memcpy(new_ptr, ptr, old_size);
	free(ptr);
	return new_ptr;
}
