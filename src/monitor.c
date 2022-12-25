/*
 * monitor.c
 * E64-ROM
 *
 * Copyright © 2022 elmerucr. All rights reserved.
 */

//#include "kernel.h"
#include "blitter.h"

extern u8 do_prompt;
extern void *se_command_buffer;
void ver_command();

u8 *command_buffer;

static u8 advance()
{
	command_buffer++;
	return command_buffer[-1];
}

static u8 peek() {
	return *command_buffer;
}

static void skip_white_space() {
	for (;;) {
		u8 c = peek();
		switch (c) {
			case ' ':
			case '.':
				advance();
				break;
			default:
				return;
		}
	}
}

void execute()
{
	command_buffer = &se_command_buffer;	// reset to start of buffer

	/*
	 *  Skip all '.' and ' '
	 */
	skip_white_space();

	u8 new_char = advance();

	switch (new_char) {
		case 'v':
			puts("\ntesting something");
			ver_command();
			break;
		default:
			//
	}
}
