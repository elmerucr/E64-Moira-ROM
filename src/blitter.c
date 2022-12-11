/*
 * blitter.c
 * E64
 *
 * Copyright © 2022 elmerucr. All rights reserved.
 */

#include "blitter.h"

struct display_list_entry *display_list;

void blitter_init_display_list()
{
	display_list = (struct display_list_entry *)0x00000400;

	display_list[0].active  = 0x01;
	display_list[0].blit_no = 0x00;
	display_list[0].flags0  = 0x8a;
	display_list[0].flags1  = 0x00;
	display_list[0].xpos    = 0x0000;
	display_list[0].ypos    = 0x0018;

	for (u8 i=1; i<32; i++) {
		display_list[i].active  = 0;
		display_list[i].blit_no = 0;
		display_list[i].flags0  = 0;
		display_list[i].flags1  = 0;
		display_list[i].xpos    = 0;
		display_list[i].ypos    = 0;
	}
}

void blitter_set_bordersize_and_colors()
{
	BLITTER->clear_color = E64_BLUE_03;
	BLITTER->hor_border_color = E64_BLUE_01;
	BLITTER->ver_border_color = E64_BLUE_01;
	BLITTER->hor_border_size = 24;
	BLITTER->ver_border_size = 0;
	__asm(	"	nop\n"
		"	clr.b	D0\n"
		"	nop");			// just a test
}
