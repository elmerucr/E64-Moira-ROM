#include "kernel.h"
#include "blitter.h"

void test()
{
	for (u32 i=0; i<250000; i++) {
		BLITTER->clear_color = i & 0xffff;
	}
	pokew(0x80e,0xf339);

	for (u8 i=255; i>=0x18; i--) {
		BLITTER->hor_border_size = i;
	}

	pokeb(0x50000,0x13);
	pokeb(0x50001,0x14);

	pokeb(0x50002,peekb(0x50000) + peekb(0x50001));

	//pokel(0x60000,0xdeadbeef);
	pokel(0x60000,0xdeadbeef);
}

void test3()
{
	peekl(0x60001);
}
