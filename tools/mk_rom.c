#include <stdint.h>
#include <stdio.h>
#include <time.h>

int main(int argc, char *argv[]) {
	time_t t;
	time(&t);

	uint8_t romdata[65536];

	// read
	FILE *f;
	f = fopen("rom_unpatched.bin", "r");

	fseek(f, 0L, SEEK_END);
	long pos = ftell(f);

	printf("[mk_rom] Size of rom_unpatched.bin: %lu bytes\n", pos);
	if( pos >= 65536L )
	{
		printf("[mk_rom] Too large, exiting...\n");
		fclose(f);
		return 1;
	}

	// go back to beginning of file
	// read data
	rewind(f);
	fread(romdata, pos, 1, f);

	// fill up the rest of the final rom with zeroes
	for(int i=pos; i < 65536; i++) romdata[i] = 0x00;

	// close original unpatched bin file
	fclose(f);

	// write 64k output to cpp file
	printf("[mk_rom] Writing 64k (65536 bytes) image 'rom.bin' and 'rom.cpp' for inclusion in E64\n");
	f = fopen("rom.cpp","w");

	fprintf(f, "/*\n");
	fprintf(f, " * E64-ROM (rom.cpp) elmerucr (c)2020-2023\n");
	fprintf(f, " *\n");
	fprintf(f, " * built-in rom image for E64\n");
	fprintf(f, " * %s",ctime(&t));
	fprintf(f, " */\n\n");
	fprintf(f, "#include <cstdint>\n\n");
	fprintf(f, "uint8_t rom[65536] = {");

	for(int i = 0; i<(65535); i++) {
		if(i%16 == 0) fprintf(f, "\n\t");
		fprintf(f, "0x%02x,", romdata[i]);
	}
	fprintf(f, "0x%02x", romdata[(65536)-1]);
	fprintf(f, "\n};\n");

	fclose(f);

	// write 64k output to bin file
	f = fopen("rom.bin","wb");
	fwrite(romdata, sizeof(romdata), 1, f);
	fclose(f);

	return 0;
}
