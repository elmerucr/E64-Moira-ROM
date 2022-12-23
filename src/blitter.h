/*
 * blitter.h
 * E64-ROM
 *
 * Copyright © 2022 elmerucr. All rights reserved.
 */

#ifndef BLITTER_H
#define BLITTER_H

#include "kernel.h"

#define	BLITTER	((struct blitter_ic *)0x00000800)
#define	BLIT ((struct blit_ic *)0x00010000)
#define	DISPLAY_LIST ((struct display_list_entry *)0x00000400)

#define	BLIT_CMD_INCREASE_CURSOR_POS	0x81

struct blitter_ic {
	u8	status_register;
	u8	control_register;
	u8	operation;
	u8	context_no;
	u32	context_ptr;
	u8	hor_border_size;
	u8	ver_border_size;
	u16	hor_border_color;
	u16	ver_border_color;
	u16	clear_color;
};

struct blit_ic {
	u8	status_register;	// 00
	u8	control_register;	// 01
	u8	flags0;			// 02
	u8	flags1;			// 03
	u8	tile_width;		// 04
	u8	tile_height;		// 05
	u8	columns;		// 06
	u8	rows;			// 07
	u16	foreground_color;	// 08
	u16	background_color;	// 0a
	u16	xpos;			// 0c
	u16	ypos;			// 0e
	u16	no_of_tiles;
	u16	cursor_pos;
	u8	cursor_column;
	u8	cursor_row;
	u8	cursor_blink_speed;
	u8	cursor_char;
	u16	cursor_foreground_color;
	u16	cursor_background_color;

	u32	padding_long_00;		// 1c

	u32	tile_ram_ptr;			// 20
	u32	foreground_color_ram_ptr;	// 24
	u32	background_color_ram_ptr;	// 28
	u32	pixel_ram_ptr;			// 2c

	u32	padding_long_30, padding_long_34, padding_long_38, padding_long_3c;
	u32	padding_long_40, padding_long_44, padding_long_48, padding_long_4c;
	u32	padding_long_50, padding_long_54, padding_long_58, padding_long_5c;
	u32	padding_long_60, padding_long_64, padding_long_68, padding_long_6c;
	u32	padding_long_70, padding_long_74, padding_long_78, padding_long_7c;
	u32	padding_long_80, padding_long_84, padding_long_88, padding_long_8c;
	u32	padding_long_90, padding_long_94, padding_long_98, padding_long_9c;
	u32	padding_long_a0, padding_long_a4, padding_long_a8, padding_long_ac;
	u32	padding_long_b0, padding_long_b4, padding_long_b8, padding_long_bc;
	u32	padding_long_c0, padding_long_c4, padding_long_c8, padding_long_cc;
	u32	padding_long_d0, padding_long_d4, padding_long_d8, padding_long_dc;
	u32	padding_long_e0, padding_long_e4, padding_long_e8, padding_long_ec;
	u32	padding_long_f0, padding_long_f4, padding_long_f8, padding_long_fc;
};

struct display_list_entry {
	u8	active;
	u8	blit_no;
	u8	flags0;
	u8	flags1;
	u16	xpos;
	u16	ypos;
};

void blitter_init_display_list();
void blitter_init_default_blit();
void blitter_set_bordersize_and_colors();

void clear_screen();
void putsymbol(u8 symbol);
//void putchar(u8 character);	// huh? u8 not working...

#endif
