/*
 * monitor.c
 * E64-ROM
 *
 * Copyright © 2022-2023 elmerucr. All rights reserved.
 */

#include "blitter.h"
#include "cia.h"
#include "kernel.h"
#include "lox.h"
#include "screeneditor.h"

extern u8 se_do_prompt;	// part of screeneditor
extern u8 *se_command_buffer;
//void ver_command();	// definition elsewhere
extern u8 current_blit;
extern u8 *rom_version;

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
	old_cursor_position--;
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

	u16 old_color = BLIT[current_blit].background_color;

	BLIT[current_blit].background_color = BLIT[current_blit].foreground_color & 0x1fff;

	for (u32 no = 0; no < 8; no++) {
		putsymbol(peekb((address + no) & 0xffffff));
		putchar(ASCII_CURSOR_RIGHT);
	}

	BLIT[current_blit].background_color = old_color;

	BLIT[current_blit].cursor_column = 9;
}

static void monitor_word_line(u32 address)
{
	puts("\r.;");
	out6x(address & 0xffffff);

	for (u32 no = 0; no < 8; no++) {
		putchar(' ');
		out4x(peekw((address + (2*no)) & 0xffffff));
	}

	putchar(' ');

	u16 old_color = BLIT[current_blit].background_color;

	//BLIT[current_blit].background_color = BLIT[current_blit].foreground_color & 0x1fff;

	for (u32 no = 0; no < 8; no++) {
		BLIT[current_blit].background_color = peekw(address + (2 * no)) | 0xf000;
		puts("  ");
	}

	BLIT[current_blit].background_color = old_color;

	BLIT[current_blit].cursor_column = 9;
}

static void monitor_command(u16 mw_out)
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

	if (mw_out != 0) {
		start_address &= 0xfffffffe;
		end_address   &= 0xfffffffe;
	}

	for (u32 i = start_address; i <= end_address; i += ((mw_out == 0) ? 8 : 16)) {
		if (mw_out == 0) {
			putchar('\n');
			monitor_line(i);
		} else {
			putchar('\n');
			monitor_word_line(i);
		}
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

static void monitor_word_input_command()
{
	u32 address;

	if (!get_hex_specific(&address, 3)) {
		error();
		return;
	}

	address &= 0xfffffe;

	for (u32 i=0; i < 8; i++) {
		u32 number;
		if(!get_hex_specific(&number, 2)) {
			error();
			return;
		}
		pokew(address + (2 * i), number & 0xffff);
	}

	monitor_word_line(address);

	puts("\n.;");
	out6x((address + 16) & 0xffffff);
	putchar(' ');
	se_do_prompt = 0;
}

static u32 min(u32 a, u32 b)
{
	return a < b ? a : b;
}

static void t_command()
{
	u32 source;
	u32 destination;
	u32 bytes;

	// numbers will be max 0xffffff because getting 3 bytes...

	if (!get_hex_specific(&source, 3)) {
		error();
		return;
	}

	if (!get_hex_specific(&destination, 3)) {
		error();
		return;
	}

	if (!get_hex_specific(&bytes, 3)) {
		error();
		return;
	}

	if (source < destination) {
		if (min(destination - source, 0x1000000 - destination) < bytes) {
			bytes = min(destination - source, 0x1000000 - destination);
		}
	} else {
		if (min(source - destination, 0x1000000 - source) < bytes) {
			bytes = min(source - destination, 0x1000000 - source);
		}
	}

	puts("\ntransferring $");
	out6x(bytes);
	puts(" bytes from $");
	out6x(source);
	puts(" to $");
	out6x(destination);

	u8 *src = (u8 *)source;
	u8 *dst = (u8 *)destination;

	while (bytes--) {
		*dst++ = *src++;
	}
}

static void ver_command()
{
	putchar('\n');
	puts((u8 *)&rom_version);
}

static void monitor_word_command()
{
	puts("\nmonitor word command");
}

static void lox_command()
{
	lox_main();
}

void execute()
{
	command_buffer = (u8 *)&se_command_buffer;	// reset to start of buffer
	skips = 0;

	skip_dots_and_spaces();

	u8 c = advance();

	switch (c) {
		case ':':
			monitor_input_command();
			break;
		case ';':
			monitor_word_input_command();
			break;
		case 'a':
			if (check_keyword(5, "miga ")) {
				blitter_amiga_theme();
				clear_screen();
				puts("\nAmiga Theme");
				break;
			} else {
				advance();
				error();
				break;
			}
		case 'c':
			if (check_keyword(3, "64 ")) {
				blitter_c64_theme();
				clear_screen();
				puts("\nC64 Theme");
				break;
			} else if (check_keyword(5, "lear ")) {
				clear_screen();
				break;
			} else {
				advance();
				error();
				break;
			}
		case 'e':
			if (check_keyword(3, "64 ")) {
				blitter_e64_theme();
				clear_screen();
				puts("\nE64 Theme");
			} else {
				advance();
				error();
			}
			break;
		case 'l':
			if (check_keyword(3, "ox ")) {
				lox_command();
			} else {
				advance();
				error();
			}
			break;
		case 'm':
			if (peek() == ' ') {
				advance();
				monitor_command(0);
				break;
			} else {
				if (check_keyword(2, "w ")) {
					//advance();
					monitor_command(1);
					break;
				}
				advance();
				error();
				break;
			}
		case 't':
			if (check_keyword(1, " ")) {
				t_command();
			} else {
				advance();
				error();
				break;
			}
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

/*
 * No (of bytes) must be between 1 and 4 (8, 16, 24 or 32 bits)
 */
static u8 get_hex_specific_from_screen(u32 *hex_number, u8 bytes)
{
	*hex_number = 0;

	if (bytes > 4) return 1;

	// no of chars to fetch
	u8 no = bytes << 1;

	u8 result = 0;
	u8 c = BLIT[current_blit].cursor_char;
	BLIT[current_blit].cursor_column++;

	while (no--) {
		if (is_hex(&c)) {
			result = 1;
			*hex_number = (*hex_number << 4) | c;
			c = BLIT[current_blit].cursor_char;
			BLIT[current_blit].cursor_column++;
		} else {
			return 0;
		}
	}

	return result;
}

void bottom_row()
{
	u16 old_cursor_pos = BLIT[current_blit].cursor_pos;
	u8 rows_to_check = BLIT[current_blit].rows;

	BLIT[current_blit].cursor_column = 1;
	BLIT[current_blit].cursor_row = BLIT[current_blit].rows - 1;

	u32 address;

	for (u16 i=0; i < rows_to_check; i++) {
		switch (BLIT[current_blit].cursor_char) {
			case ':':
				BLIT[current_blit].cursor_column = 2;
				if (get_hex_specific_from_screen(&address, 3)) {
					address = (address + 8) & 0x00ffffff;
					BLIT[current_blit].cursor_pos = old_cursor_pos;
					se_add_bottom_row();
					monitor_line(address);
					return;
				} else {
					BLIT[current_blit].cursor_column = 1;
				}
				break;
			case ';':
				BLIT[current_blit].cursor_column = 2;
				if (get_hex_specific_from_screen(&address, 3)) {
					address = (address + 16) & 0x00fffffe;
					BLIT[current_blit].cursor_pos = old_cursor_pos;
					se_add_bottom_row();
					monitor_word_line(address);
					return;
				} else {
					BLIT[current_blit].cursor_column = 1;
				}
				break;
			default:
				break;
		}
		BLIT[current_blit].cursor_row--;
	}

	BLIT[current_blit].cursor_pos = old_cursor_pos;
	se_add_bottom_row();
}

void top_row()
{
	u16 old_cursor_pos = BLIT[current_blit].cursor_pos;
	u8 rows_to_check = BLIT[current_blit].rows;

	BLIT[current_blit].cursor_column = 1;

	u32 address;

	for (u16 i=0; i < rows_to_check; i++) {
		switch (BLIT[current_blit].cursor_char) {
			case ':':
				BLIT[current_blit].cursor_column = 2;
				if (get_hex_specific_from_screen(&address, 3)) {
					address = (address - 8) & 0x00ffffff;
					BLIT[current_blit].cursor_pos = old_cursor_pos;
					se_add_top_row();
					monitor_line(address);
					return;
				} else {
					BLIT[current_blit].cursor_column = 1;
				}
				break;
			case ';':
				BLIT[current_blit].cursor_column = 2;
				if (get_hex_specific_from_screen(&address, 3)) {
					address = (address - 16) & 0x00fffffe;
					BLIT[current_blit].cursor_pos = old_cursor_pos;
					se_add_top_row();
					monitor_word_line(address);
					return;
				} else {
					BLIT[current_blit].cursor_column = 1;
				}
				break;
			default:
				break;
		}
		BLIT[current_blit].cursor_row++;
	}

	BLIT[current_blit].cursor_pos = old_cursor_pos;
	se_add_top_row();
}
