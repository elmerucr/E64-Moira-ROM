/*
 * monitor.c
 * E64-ROM
 *
 * Copyright © 2022-2023 elmerucr. All rights reserved.
 */

#include "blitter.h"
#include "cia.h"

extern u8 se_do_prompt;	// part of screeneditor
extern void *se_command_buffer;
void ver_command();	// definition elsewhere
extern u8 current_blit;

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

/*
 * No (of bytes) must be between 1 and 4 (8, 16, 24 or 32 bits)
 */
static u8 get_hex_specific(u32 *hex_number, u8 bytes)
{
	*hex_number = 0;

	if (bytes > 4) return 1;

	// no of chars to fetch
	u8 no = bytes << 1;

	u8 result = 0;
	u8 c = advance();

	while (no--) {
		if (is_hex(&c)) {
			result = 1;
			*hex_number = (*hex_number << 4) | c;
			c = advance();
		} else {
			return 0;
		}
	}

	return result;
}

static u8 get_hex(u32 *hex_number)
{
	*hex_number = 0;

	u8 result = 0;
	u8 c = advance();

	while (is_hex(&c)) {
		result = 1;
		*hex_number = (*hex_number << 4) | c;
		c = advance();
	}

	return result;
}

static void monitor_line(u32 address)
{
	puts("\r.:");
	out6x(address & 0xffffff);

	for (u32 no = 0; no < 8; no++) {
		putchar(' ');
		out2x(peekb((address + no) & 0xffffff));
	}

	putchar(' ');

	for (u32 no = 0; no < 8; no++) {
		putsymbol(peekb((address + no) & 0xffffff));
		putchar(ASCII_CURSOR_RIGHT);
	}

	BLIT[current_blit].cursor_column = 9;
}

static void monitor_command()
{
	u32 start_address;
	u32 end_address;

	if (!(get_hex(&start_address))) {
		error();
		return;
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
		monitor_line(i);
		/*
		 * check for escape key
		 */
		if (CIA_KEYSTATES[CIA_KEY_ESCAPE] != 0) {
			puts("\nbreak");
			CIA->control_register = CIA_CMD_CLEAR_EVENT_LIST | CIA_CMD_GENERATE_EVENTS;
			return;
		}
	}

	CIA->control_register = CIA_CMD_CLEAR_EVENT_LIST | CIA_CMD_GENERATE_EVENTS;
	se_do_prompt = 0;
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

static void monitor_input_command()
{
	u32 address;

	if (!get_hex_specific(&address, 3)) {
		error();
		return;
	}

	for (u32 i=0; i < 8; i++) {
		u32 number;
		if(!get_hex_specific(&number, 1)) {
			error();
			return;
		}
		pokeb(address + i, number & 0xff);
	}

	monitor_line(address);

	puts("\n.:");
	out6x((address + 8) & 0xffffff);
	putchar(' ');
	se_do_prompt = 0;
}

void execute()
{
	command_buffer = &se_command_buffer;	// reset to start of buffer
	skips = 0;

	skip_dots_and_spaces();

	u8 c = advance();

	switch (c) {
		case ':':
			monitor_input_command();
			break;
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

void bottom_row()
{
	//puts("down");
}

void top_row()
{
	//puts("up");
}
