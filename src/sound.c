/*
 * sound.c
 * E64-ROM
 *
 * Copyright © 2022-2023 elmerucr. All rights reserved.
 */

#include "sound.h"

/*
 * The following table is based on a SID clock frequency of 985248Hz
 * (PAL). Calculations were made according to Codebase64 article:
 * https://codebase64.org/doku.php?id=base:how_to_calculate_your_own_sid_frequency_table
 */

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
};

void sound_reset()
{
	// zero out 4 sids
	for (u32 i=0; i<128; i++) {
		pokeb(0x00000c80+i, 0);
	}

	SOUND_SID->sid0_filtermode_volume = 0x0f;
	SOUND_SID->sid1_filtermode_volume = 0x0f;
	SOUND_SID->sid2_filtermode_volume = 0x0f;
	SOUND_SID->sid3_filtermode_volume = 0x0f;

	for (u32 i=0; i<16; i++) {
		pokeb(0x00000e00+i,0x7f);	// 50% volume
	}
}

void sound_init_welcome_sound()
{
	SOUND_SID->sid0_voice1_frequency = music_notes[N_D3_];
	SOUND_SID->sid0_voice1_attack_decay = 0x09;
	SOUND_SID->sid0_voice1_pulsewidth = 0xf0f;
	SOUND_MIXER->sid0_volume_left = 0xff;
	SOUND_MIXER->sid0_volume_right = 0x10;
	SOUND_SID->sid0_voice1_control_register = 0x40;

	SOUND_SID->sid1_voice1_frequency = music_notes[N_A3_];
	SOUND_SID->sid1_voice1_attack_decay = 0x09;
	SOUND_SID->sid1_voice1_pulsewidth = 0xf0f;
	SOUND_MIXER->sid1_volume_left = 0x10;
	SOUND_MIXER->sid1_volume_right = 0xff;
	SOUND_SID->sid1_voice1_control_register = 0x40;
}

void sound_welcome_sound()
{
	SOUND_SID->sid0_voice1_control_register = 0x41;
	SOUND_SID->sid1_voice1_control_register = 0x41;
}
