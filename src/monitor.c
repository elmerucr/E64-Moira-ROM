/*
 * monitor.c
 * E64-ROM
 *
 * Copyright © 2022 elmerucr. All rights reserved.
 */

#include "blitter.h"

extern u8 se_do_prompt;	// part of screeneditor
extern void *se_command_buffer;
void ver_command();	// definition elsewhere

u8 *command_buffer;
u8 skips;

static u8 advance()
{
	command_buffer++;
	skips++;
	return command_buffer[-1];
}

static u8 peek()
{
	return *command_buffer;
}

static void skip_dots_and_white_space() {
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

static void monitor_command()
{
	puts("\nmonitor command");
}

static void error()
{
	putchar('\r');
	while (skips--) {
		putchar(ASCII_CURSOR_RIGHT);
	}
	putchar('?');
}

static u8 check_keyword(u8 length, const u8 *rest)
{
	for (u8 i = 0; i < length; i++) {
		if (*command_buffer != rest[i]) {
			return 0;
		}
		advance();
		//skips++;
	}
	return 1;
}

void execute()
{
	command_buffer = &se_command_buffer;	// reset to start of buffer
	skips = 0;

	skip_dots_and_white_space();

	u8 c = advance();

	switch (c) {
		case 'c':
			if (check_keyword(5, "lear ")) {
				clear_screen();
				break;
			} else {
				advance();
				error();
				break;
			}
		case 'm':
			if (peek() != ' ') {
				advance();
				error();
				break;
			}
			advance();
			monitor_command();
			break;
		case 'v':
			if (check_keyword(3, "er ")) {
				ver_command();
				break;
			} else {
				advance();
				error();
				break;
			}
		case '\0':
			return;
		default:
			error();
	}
}
