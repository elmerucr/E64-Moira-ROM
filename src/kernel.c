/*
 * kernel.c
 * E64-ROM
 *
 * Copyright © 2022 elmerucr. All rights reserved.
 */

#include "kernel.h"

void *heap_start;
void *heap_end;

void init_kernel()
{
	reset_vector_table();
	reset_relocate_sections();
	reset_heap_pointers();
}

void reset_heap_pointers()
{
	heap_start = (void *)0x00040000;
	heap_end   = (void *)0x00040000;
}
