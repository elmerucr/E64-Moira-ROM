#include "kernel.h"

void test()
{
	for (u32 i=0; i<250000; i++) {
		pokeb(0x80b,i & 0xff);
	}
	pokeb(0x80b,0x13);

	pokeb(0x50000,0x13);
	pokeb(0x50001,0x14);

	pokeb(0x50002,peekb(0x50000) + peekb(0x50001));

	//pokel(0x60000,0xdeadbeef);
	pokel(0x60001,0xdeadbeef);
}

u16 test2(u16 color)
{
	*(u16*)0x080a = color;
	return color;
}

void test3()
{
	peekl(0x60001);
}