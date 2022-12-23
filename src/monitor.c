/*
 * monitor.c
 * E64-ROM
 *
 * Copyright © 2022 elmerucr. All rights reserved.
 */

#include "kernel.h"
//#include "screeneditor.h"
//#include "blitter.h"

u32 get_address(const char *command_line)
{
	return 0xffce;
}

void putchar(u8 letter);

void execute()
{
	u8 letter;

	while (letter = se_command_buffer_get_char()) {
		putchar(letter);
	}
	// for (u8 i=0; i<10; i++) {
	// 	putchar('*');		// not put on stack as byte!!! but as word!!!
	// }
}
