/*
 * kernel.c
 * E64
 *
 * Copyright © 2022 elmerucr. All rights reserved.
 */

#include "kernel.h"

void *heap_start;
void *heap_end;

void init_kernel()
{
	init_vector_table();
	init_relocate_sections();
	init_heap_pointers();
}

void init_heap_pointers()
{
	heap_start = (void *)0x00030000;
	heap_end   = (void *)0x00030000;
}
