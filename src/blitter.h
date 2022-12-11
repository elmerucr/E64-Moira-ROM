/*
 * blitter.h
 * E64
 *
 * Copyright © 2022 elmerucr. All rights reserved.
 */

#ifndef BLITTER_H
#define BLITTER_H

#include "kernel.h"

#define	BLITTER	((struct blitter_ic *)0x00000800)

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

struct display_list_entry {
	u8	active;
	u8	blit_no;
	u8	flags0;
	u8	flags1;
	u16	xpos;
	u16	ypos;
};

void blitter_init_display_list();
void blitter_set_bordersize_and_colors();

#endif
