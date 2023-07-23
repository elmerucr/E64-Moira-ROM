/*
 * kernel.c
 * E64-ROM
 *
 * Copyright © 2022-2023 elmerucr. All rights reserved.
 */

#include "kernel.h"

void *heap_start;
void *heap_end;

void reset_heap_pointers()
{
	heap_start = (void *)0x00060000;
	heap_end   = (void *)0x00100000;
}

void kernel_panic()
{
	pokew(0x000808, 0x0020);
	pokew(0x00080a, 0x0020);
	pokew(0x00080c, 0xff00);
	pokew(0x00080e, 0xff00);
	for (;;) {}
}
