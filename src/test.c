void test()
{
	for (int i=0; i<125600; i++) {
		*(char *)0x080a = i;
		*(char *)0x0c80 = 3;
	}
}

unsigned short test2(unsigned short color)
{
	*(unsigned short*)0x080a = color;
	return color;
}
