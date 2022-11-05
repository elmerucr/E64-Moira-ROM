#include "types.h"

void test()
{
	for (u16 i=0; i<53281; i++) {
		*(char *)0x080a = i;
		//*(char *)0x0c80 = 3;
	}
}

u16 test2(u16 color)
{
	*(u16*)0x080a = color;
	return color;
}
