/*
 * blitter.c
 * E64-ROM
 *
 * Copyright © 2022-2023 elmerucr. All rights reserved.
 */

#include "blitter.h"

u8 current_blit;

void blitter_init_display_list()
{
	//display_list = (struct display_list_entry *)0x00000400;

	DISPLAY_LIST[0].active  = 0x01;
	DISPLAY_LIST[0].blit_no = 0x00;
	DISPLAY_LIST[0].flags0  = 0x1a;
	DISPLAY_LIST[0].flags1  = 0x00;
	DISPLAY_LIST[0].xpos    = 0x0000;
	DISPLAY_LIST[0].ypos    = 0x0018;

	for (u8 i=1; i<32; i++) {
		DISPLAY_LIST[i].active  = 0;
		DISPLAY_LIST[i].blit_no = 0;
		DISPLAY_LIST[i].flags0  = 0;
		DISPLAY_LIST[i].flags1  = 0;
		DISPLAY_LIST[i].xpos    = 0;
		DISPLAY_LIST[i].ypos    = 0;
	}
}

void blitter_init_default_blit()
{
	/*
	 * Note: flags and position not set, done in kernel display list
	 */
	current_blit = 0;
	BLIT[current_blit].control_register = 0xc1;	// deactivate cursor
	BLIT[current_blit].cursor_blink_speed = 0x14;
	BLIT[current_blit].columns = 80;
	BLIT[current_blit].rows = 44;
	BLIT[current_blit].tile_width = 1;
	BLIT[current_blit].tile_height = 1;
	BLIT[current_blit].foreground_color = E64_BLUE_08;
	BLIT[current_blit].background_color = 0x0000;
}

void blitter_set_bordersize_and_colors()
{
	BLITTER->clear_color = E64_BLUE_03;
	BLITTER->hor_border_color = E64_BLUE_01;
	BLITTER->ver_border_color = E64_BLUE_01;
	BLITTER->hor_border_size = 24;
	BLITTER->ver_border_size = 0;
//	__asm(	"	nop\n"
//		"	clr.b	D0\n"
//		"	nop");			// just a test
}

void clear_screen()
{
	BLIT[current_blit].cursor_pos = 0;

	do {
		BLIT[current_blit].cursor_char = ' ';
		BLIT[current_blit].cursor_foreground_color = BLIT[current_blit].foreground_color;
		BLIT[current_blit].cursor_background_color = BLIT[current_blit].background_color;
		BLIT[current_blit].control_register = BLIT_CMD_INCREASE_CURSOR_POS;
	}
	while (!(BLIT[current_blit].status_register & 0x80));
}
