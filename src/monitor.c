/*
 * monitor.c
 * E64-ROM
 *
 * Copyright © 2022 elmerucr. All rights reserved.
 */

#include "blitter.h"
#include "cia.h"

extern u8 se_do_prompt;	// part of screeneditor
extern void *se_command_buffer;
void ver_command();	// definition elsewhere

u8 *command_buffer;
u8 skips;
const u8 hex_values[] = "0123456789abcdef";

static void out2x(u8 byte)
{
	putchar(hex_values[byte >> 4]);
	putchar(hex_values[byte & 0x0f]);
}

static void out4x(u16 word)
{
	out2x(word >> 8);
	out2x(word & 0x00ff);
}

static void out6x(u32 longword)
{
	out2x(longword >> 16);
	out2x((longword >> 8) & 0xff);
	out2x(longword & 0xff);
}

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

static void skip_dots_and_spaces() {
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

static void error()
{
	putchar('\r');
	while (skips--) {
		putchar(ASCII_CURSOR_RIGHT);
	}
	putchar('?');
}

static u8 is_hex(u8 *sym)
{
	if (*sym >= '0' && *sym <= '9') {
		*sym = *sym - '0';
	} else if (*sym >= 'a' && *sym <='f') {
		*sym = *sym - 'a' + 10;
	} else if (*sym >= 'A' && *sym <='F') {
		*sym = *sym - 'A' + 10;
	} else {
		// Not a hex value
		return 0;
	}
	return 1;
}

static u8 get_hex(u32 *hex_number)
{
	*hex_number = 0;

	u8 result = 0;

	u8 c = advance();

	while (is_hex(&c)) {
		*hex_number = (*hex_number << 4) | c;
		result = 1;
		c = advance();
	}

	return result;
}

static void monitor_command()
{
	u32 start_address;
	u32 end_address;

	if (!(get_hex(&start_address))) {
		advance();
		error();
	} else {
		start_address &= 0xffffff;
		if (!(get_hex(&end_address))) {
			end_address = start_address;
		} else if (end_address < start_address) {
			end_address |= 0x01000000;
		}
	}

	for (u32 i = start_address; i <= end_address; i += 8) {
		puts("\n.:");
		out6x(i & 0xffffff);

		for (u32 no = 0; no < 8; no++) {
			putchar(' ');
			out2x(peekb((i+ no) & 0xffffff));
		}

		putchar(' ');

		for (u32 no = 0; no < 8; no++) {
			putsymbol(peekb((i+ no) & 0xffffff));
			putchar(ASCII_CURSOR_RIGHT);
		}

		if (CIA_KEYSTATES[CIA_KEY_ESCAPE] != 0) {
			puts("\nbreak");
			break;
		}
	}
	CIA->control_register = CIA_CMD_CLEAR_EVENT_LIST | CIA_CMD_GENERATE_EVENTS;
}

static u8 check_keyword(u8 length, const u8 *rest)
{
	for (u8 i = 0; i < length; i++) {
		if (*command_buffer != rest[i]) {
			return 0;
		}
		advance();
	}
	return 1;
}

void execute()
{
	command_buffer = &se_command_buffer;	// reset to start of buffer
	skips = 0;

	skip_dots_and_spaces();

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
