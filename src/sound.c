/*
 * sound.c
 * E64
 *
 * Copyright © 2022 elmerucr. All rights reserved.
 */

#include "sound.h"

const u16 music_notes[95] = {
	0x0116, 0x0127, 0x0139, 0x014b, 0x015f, 0x0174,	// N_C0_ to N_B0_
	0x018a, 0x01a1, 0x01ba, 0x01d4, 0x01f0, 0x020e,
	0x022d, 0x024e, 0x0271, 0x0296, 0x02be, 0x02e7,	// N_C1_ to N_B1_ ($0342 = G1 = kick drum)
	0x0314, 0x0342, 0x0374, 0x03a9, 0x03e0, 0x041b,
	0x045a, 0x049c, 0x04e2, 0x052d, 0x057b, 0x05cf,	// N_C2_ to N_B2_
	0x0627, 0x0685, 0x06e8, 0x0751, 0x07c1, 0x0837,
	0x08b4, 0x0938, 0x09c4, 0x0a59, 0x0af7, 0x0b9d,	// N_C3_ to N_B3_
	0x0c4e, 0x0d0a, 0x0dd0, 0x0ea2, 0x0f81, 0x106d,
	0x1167, 0x1270, 0x1389, 0x14b2, 0x15ed, 0x173b,	// N_C4_ to N_B4_ ($1d45 = A4 = 440Hz std)
	0x189c, 0x1a13, 0x1ba0, 0x1d45, 0x1f02, 0x20da,
	0x22ce, 0x24e0, 0x2711, 0x2964, 0x2bda, 0x2e76,	// N_C5_ to N_B5_
	0x3139, 0x3426, 0x3740, 0x3a89, 0x3e04, 0x41b4,
	0x459c, 0x49c0, 0x4e23, 0x52c8, 0x57b4, 0x5ceb,	// N_C6_ to N_B6_
	0x6272, 0x684c, 0x6e80, 0x7512, 0x7c08, 0x8368,
	0x8b39, 0x9380, 0x9c45, 0xa590, 0xaf68, 0xb9d6,	// N_C7_ to N_A7S
	0xc4e3, 0xd099, 0xdd00, 0xea24, 0xf810
}

void sound_reset()
{
	// zero out 4 sids
	for (u32 i=0; i<128; i++) {
		pokeb(0x00000c00+i, 0);
	}

	SOUND->sid0_filtermode_volume = 0x0f;
	SOUND->sid1_filtermode_volume = 0x0f;
	SOUND->sid2_filtermode_volume = 0x0f;
	SOUND->sid3_filtermode_volume = 0x0f;

	for (u32 i=0; i<16; i++) {
		pokeb(0x00000d00+i,0xf);
	}
}

void sound_welcome_sound()
{
	SOUND->sid0_voice1_frequency = music_notes[N_D3_];
	SOUND->sid0_voice1_attack_decay = 0x09;
	SOUND->sid0_voice1_pulsewidth = 0xf0f;
	SOUND_MIXER->sid0_volume_left = 0xff;
	pokeb(0x0000d00,0xff);	// solve this
	pokeb(0x0000d01,0x10);	// solve this
	SOUND->sid0_voice1_control_register = 0x41;

	SOUND->sid1_voice1_frequency = music_notes[N_A3_];
	SOUND->sid1_voice1_attack_decay = 0x09;
	SOUND->sid1_voice1_pulsewidth = 0xf0f;
	pokeb(0x0000d02,0x10);	// solve this
	pokeb(0x0000d03,0xff);	// solve this
	SOUND->sid1_voice1_control_register = 0x41;
}

		// ; play a welcome sound on SID0
		// lea	SID0,A0
		// lea	music_notes,A1
		// move.w	(N_D3_,A1),(A0)		; set frequency of voice 1
		// move.b	#%00001001,($5,A0)	; attack and decay of voice 1
		// move.w	#$f0f,$02(A0)		; pulse width of voice 1
		// move.b	#$ff,SNDM0L		; left channel mix
		// move.b	#$10,SNDM0R		; right channel mix
		// move.b	#%01000001,($4,A0)	; pulse (bit 6) and open gate (bit 0)
		// ; play a welcome sound on SID1
		// lea	SID1,A0
		// lea	music_notes,A1
		// move.w	(N_A3_,A1),(A0)		; set frequency of voice 1
		// move.b	#%00001001,($5,A0)	; attack and decay of voice 1
		// move.w	#$f0f,($2,A0)		; pulse width of voice 1
		// move.b	#$10,SNDM1L		; left channel mix
		// move.b	#$ff,SNDM1R		; right channel mix
		// move.b	#%01000001,($4,A0)	; pulse (bit 6) and open gate (bit 0)
		// rts
