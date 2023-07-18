/*
 * blitter.c
 * E64-ROM
 *
 * Copyright © 2022-2023 elmerucr. All rights reserved.
 */

#include "blitter.h"
#include "monitor.h"

u8 current_blit;

void blitter_init_display_list()
{
	for (u8 i=0; i<32; i++) {
		DISPLAY_LIST[i].active  = 0;
		DISPLAY_LIST[i].blit_no = 0;
		DISPLAY_LIST[i].flags0  = 0;
		DISPLAY_LIST[i].flags1  = 0;
		DISPLAY_LIST[i].xpos    = 0;
		DISPLAY_LIST[i].ypos    = 0;
	}
	// __asm(	"	nop\n"
	// 	"	clr.b	D0\n"
	// 	"	nop");			// just a test
}

void blitter_init_default_blit_and_theme()
{
	/*
	 * Note: flags and position not set, done in kernel display list
	 */
	current_blit = 0;
	DISPLAY_LIST[0].active  = 0x01;
	blitter_e64_theme();
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

void blitter_e64_theme()
{
	BLITTER->clear_color = E64_BLUE_03;
	BLITTER->hor_border_color = E64_BLUE_01;
	BLITTER->ver_border_color = E64_BLUE_01;
	BLITTER->hor_border_size = 16;
	BLITTER->ver_border_size = 0;
	BLITTER->screen_width = 64;
	BLITTER->screen_height = 40;

	BLIT[0].tile_width = 1;
	BLIT[0].tile_height = 1;
	BLIT[0].cursor_blink_speed = 0x14;
	BLIT[0].columns = 64;
	BLIT[0].rows = 36;
	BLIT[0].foreground_color = E64_BLUE_08;
	BLIT[0].background_color = 0x0000;

	DISPLAY_LIST[0].flags0  = 0x1a;
	DISPLAY_LIST[0].flags1  = 0x00;
	DISPLAY_LIST[0].xpos    = 0x0000;
	DISPLAY_LIST[0].ypos    = 0x0010;
}

void blitter_E64_theme()
{
	BLITTER->clear_color = E64_BLUE_03;
	BLITTER->hor_border_color = E64_BLUE_01;
	BLITTER->ver_border_color = E64_BLUE_01;
	BLITTER->hor_border_size = 16;
	BLITTER->ver_border_size = 0;
	BLITTER->screen_width = 80;
	BLITTER->screen_height = 60;

	BLIT[0].tile_width = 1;
	BLIT[0].tile_height = 2;
	BLIT[0].cursor_blink_speed = 0x14;
	BLIT[0].columns = 80;
	BLIT[0].rows = 23;
	BLIT[0].foreground_color = E64_BLUE_08;
	BLIT[0].background_color = 0x0000;

	DISPLAY_LIST[0].flags0  = 0x2a;
	DISPLAY_LIST[0].flags1  = 0x00;
	DISPLAY_LIST[0].xpos    = 0x0000;
	DISPLAY_LIST[0].ypos    = 0x0010;
}

void blitter_c64_theme()
{
	BLITTER->clear_color = C64_BLUE;
	BLITTER->hor_border_color = C64_LIGHTBLUE;
	BLITTER->ver_border_color = C64_LIGHTBLUE;
	BLITTER->hor_border_size = 20;
	BLITTER->ver_border_size = 32;
	BLITTER->screen_width = 48;
	BLITTER->screen_height = 30;

	BLIT[0].tile_width = 1;
	BLIT[0].tile_height = 1;
	BLIT[0].cursor_blink_speed = 0x14;
	BLIT[0].columns = 40;
	BLIT[0].rows = 25;
	BLIT[0].tile_width = 1;
	BLIT[0].tile_height = 1;
	BLIT[0].foreground_color = C64_LIGHTBLUE;
	BLIT[0].background_color = 0x0000;

	DISPLAY_LIST[0].flags0 = 0x1a;
	DISPLAY_LIST[0].flags1 = 0x00;
	DISPLAY_LIST[0].xpos = 0x0020;
	DISPLAY_LIST[0].ypos = 0x0014;
}

void blitter_amiga_theme()
{
	BLITTER->clear_color = 0xf25a;
	BLITTER->hor_border_color = 0xf000;
	BLITTER->ver_border_color = 0xf000;
	BLITTER->hor_border_size = 0;
	BLITTER->ver_border_size = 0;
	BLITTER->screen_width = 80;
	BLITTER->screen_height = 60;

	BLIT[0].tile_width = 1;
	BLIT[0].tile_height = 2;
	BLIT[0].cursor_blink_speed = 0x14;
	BLIT[0].columns = 80;
	BLIT[0].rows = 25;
	BLIT[0].foreground_color = 0xfeee;
	BLIT[0].background_color = 0x0000;

	DISPLAY_LIST[0].flags0 = 0x2a;
	DISPLAY_LIST[0].flags1 = 0x00;
	DISPLAY_LIST[0].xpos = 0x0000;
	DISPLAY_LIST[0].ypos = 0x0000;
}
