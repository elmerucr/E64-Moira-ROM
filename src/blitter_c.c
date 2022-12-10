#include "blitter.h"

void blitter_set_bordersize_and_colors()
{
	BLITTER->clear_color = E64_BLUE_03;
	BLITTER->hor_border_color = E64_BLUE_01;
	BLITTER->ver_border_color = E64_BLUE_01;
	BLITTER->hor_border_size = 24;
	BLITTER->ver_border_size = 0;
	__asm("\tnop\n\tnop");			// just a test
}
