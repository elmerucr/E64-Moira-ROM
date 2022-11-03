#include "types.h"

void test()
{
	for (u16 i=0; i<32768; i++) {
		*(char *)0x080a = i;
		*(char *)0x0c80 = 3;
	}
}

unsigned short test2(unsigned short color)
{
	*(unsigned short*)0x080a = color;
	return color;
}
