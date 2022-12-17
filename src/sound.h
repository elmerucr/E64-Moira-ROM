/*
 * sound.h
 * E64
 *
 * Copyright © 2022 elmerucr. All rights reserved.
 */

#ifndef	SOUND_H
#define	SOUND_H

#include "kernel.h"

#define	SOUND	((struct sound_ic *)0x00000c00)
#define SOUND_MIXER	((struct sound_mixer_ic *)0x00000d00)

struct sound_ic {
	u16	sid0_voice1_frequency;
	u16	sid0_voice1_pulsewidth;
	u8	sid0_voice1_control_register;
	u8	sid0_voice1_attack_decay;
	u8	sid0_voice1_sustain_release;
	u8	sid0_voice1_padding_byte;
	u16	sid0_voice2_frequency;
	u16	sid0_voice2_pulsewidth;
	u8	sid0_voice2_control_register;
	u8	sid0_voice2_attack_decay;
	u8	sid0_voice2_sustain_release;
	u8	sid0_voice2_padding_byte;
	u16	sid0_voice3_frequency;
	u16	sid0_voice3_pulsewidth;
	u8	sid0_voice3_control_register;
	u8	sid0_voice3_attack_decay;
	u8	sid0_voice3_sustain_release;
	u8	sid0_voice3_padding_byte;
	u8	sid0_filter_cutoff_low_byte;
	u8	sid0_filter_cutoff_high_byte;
	u8	sid0_filter_res;
	u8	sid0_filtermode_volume;
	u8	sid0_potx;
	u8	sid0_poty;
	u8	sid0_voice3_random;
	u8	sid0_voice3_envelope;

	u16	sid1_voice1_frequency;
	u16	sid1_voice1_pulsewidth;
	u8	sid1_voice1_control_register;
	u8	sid1_voice1_attack_decay;
	u8	sid1_voice1_sustain_release;
	u8	sid1_voice1_padding_byte;
	u16	sid1_voice2_frequency;
	u16	sid1_voice2_pulsewidth;
	u8	sid1_voice2_control_register;
	u8	sid1_voice2_attack_decay;
	u8	sid1_voice2_sustain_release;
	u8	sid1_voice2_padding_byte;
	u16	sid1_voice3_frequency;
	u16	sid1_voice3_pulsewidth;
	u8	sid1_voice3_control_register;
	u8	sid1_voice3_attack_decay;
	u8	sid1_voice3_sustain_release;
	u8	sid1_voice3_padding_byte;
	u8	sid1_filter_cutoff_low_byte;
	u8	sid1_filter_cutoff_high_byte;
	u8	sid1_filter_res;
	u8	sid1_filtermode_volume;
	u8	sid1_potx;
	u8	sid1_poty;
	u8	sid1_voice3_random;
	u8	sid1_voice3_envelope;

	u16	sid2_voice1_frequency;
	u16	sid2_voice1_pulsewidth;
	u8	sid2_voice1_control_register;
	u8	sid2_voice1_attack_decay;
	u8	sid2_voice1_sustain_release;
	u8	sid2_voice1_padding_byte;
	u16	sid2_voice2_frequency;
	u16	sid2_voice2_pulsewidth;
	u8	sid2_voice2_control_register;
	u8	sid2_voice2_attack_decay;
	u8	sid2_voice2_sustain_release;
	u8	sid2_voice2_padding_byte;
	u16	sid2_voice3_frequency;
	u16	sid2_voice3_pulsewidth;
	u8	sid2_voice3_control_register;
	u8	sid2_voice3_attack_decay;
	u8	sid2_voice3_sustain_release;
	u8	sid2_voice3_padding_byte;
	u8	sid2_filter_cutoff_low_byte;
	u8	sid2_filter_cutoff_high_byte;
	u8	sid2_filter_res;
	u8	sid2_filtermode_volume;
	u8	sid2_potx;
	u8	sid2_poty;
	u8	sid2_voice3_random;
	u8	sid2_voice3_envelope;

	u16	sid3_voice1_frequency;
	u16	sid3_voice1_pulsewidth;
	u8	sid3_voice1_control_register;
	u8	sid3_voice1_attack_decay;
	u8	sid3_voice1_sustain_release;
	u8	sid3_voice1_padding_byte;
	u16	sid3_voice2_frequency;
	u16	sid3_voice2_pulsewidth;
	u8	sid3_voice2_control_register;
	u8	sid3_voice2_attack_decay;
	u8	sid3_voice2_sustain_release;
	u8	sid3_voice2_padding_byte;
	u16	sid3_voice3_frequency;
	u16	sid3_voice3_pulsewidth;
	u8	sid3_voice3_control_register;
	u8	sid3_voice3_attack_decay;
	u8	sid3_voice3_sustain_release;
	u8	sid3_voice3_padding_byte;
	u8	sid3_filter_cutoff_low_byte;
	u8	sid3_filter_cutoff_high_byte;
	u8	sid3_filter_res;
	u8	sid3_filtermode_volume;
	u8	sid3_potx;
	u8	sid3_poty;
	u8	sid3_voice3_random;
	u8	sid3_voice3_envelope;

	u8	analog0_waveform_gate;
	u8	analog0_pitch_factor_semitones;
	u16	analog0_digital_frequency;
	u16	analog0_square_wave_duty;
	u16	analog0_attack;
	u16	analog0_decay;
	u16	analog0_sustain;
	u16	analog0_release;
	u16	analog0_pitch_bend_duration;
	u32	analog0_padding_long_0;
	u32	analog0_padding_long_1;
	u32	analog0_padding_long_2;
	u32	analog0_padding_long_3;

	u8	analog1_waveform_gate;
	u8	analog1_pitch_factor_semitones;
	u16	analog1_digital_frequency;
	u16	analog1_square_wave_duty;
	u16	analog1_attack;
	u16	analog1_decay;
	u16	analog1_sustain;
	u16	analog1_release;
	u16	analog1_pitch_bend_duration;
	u32	analog1_padding_long_0;
	u32	analog1_padding_long_1;
	u32	analog1_padding_long_2;
	u32	analog1_padding_long_3;

	u8	analog2_waveform_gate;
	u8	analog2_pitch_factor_semitones;
	u16	analog2_digital_frequency;
	u16	analog2_square_wave_duty;
	u16	analog2_attack;
	u16	analog2_decay;
	u16	analog2_sustain;
	u16	analog2_release;
	u16	analog2_pitch_bend_duration;
	u32	analog2_padding_long_0;
	u32	analog2_padding_long_1;
	u32	analog2_padding_long_2;
	u32	analog2_padding_long_3;

	u8	analog3_waveform_gate;
	u8	analog3_pitch_factor_semitones;
	u16	analog3_digital_frequency;
	u16	analog3_square_wave_duty;
	u16	analog3_attack;
	u16	analog3_decay;
	u16	analog3_sustain;
	u16	analog3_release;
	u16	analog3_pitch_bend_duration;
	u32	analog3_padding_long_0;
	u32	analog3_padding_long_1;
	u32	analog3_padding_long_2;
	u32	analog3_padding_long_3;
};

struct sound_mixer_ic {
	u8	sid0_volume_left;
	u8	sid0_volume_right;
	u8	sid1_volume_left;
	u8	sid1_volume_right;
	u8	sid2_volume_left;
	u8	sid2_volume_right;
	u8	sid3_volume_left;
	u8	sid3_volume_right;
	u8	analog0_volume_left;
	u8	analog0_volume_right;
	u8	analog1_volume_left;
	u8	analog1_volume_right;
	u8	analog2_volume_left;
	u8	analog2_volume_right;
	u8	analog3_volume_left;
	u8	analog3_volume_right;
};

extern u16 *music_notes;

enum notes {
	N_C0_,
	N_C0S,
	N_D0_,
	N_D0S,
	N_E0_,
	N_F0_,
	N_F0S,
	N_G0_,
	N_G0S,
	N_A0_,
	N_A0S,
	N_B0_,
	N_C1_,
	N_C1S,
	N_D1_,
	N_D1S,
	N_E1_,
	N_F1_,
	N_F1S,
	N_G1_,
	N_G1S,
	N_A1_,
	N_A1S,
	N_B1_,
	N_C2_,
	N_C2S,
	N_D2_,
	N_D2S,
	N_E2_,
	N_F2_,
	N_F2S,
	N_G2_,
	N_G2S,
	N_A2_,
	N_A2S,
	N_B2_,
	N_C3_,
	N_C3S,
	N_D3_,
	N_D3S,
	N_E3_,
	N_F3_,
	N_F3S,
	N_G3_,
	N_G3S,
	N_A3_,
	N_A3S,
	N_B3_,
	N_C4_,
	N_C4S,
	N_D4_,
	N_D4S,
	N_E4_,
	N_F4_,
	N_F4S,
	N_G4_,
	N_G4S,
	N_A4_,
	N_A4S,
	N_B4_,
	N_C5_,
	N_C5S,
	N_D5_,
	N_D5S,
	N_E5_,
	N_F5_,
	N_F5S,
	N_G5_,
	N_G5S,
	N_A5_,
	N_A5S,
	N_B5_,
	N_C6_,
	N_C6S,
	N_D6_,
	N_D6S,
	N_E6_,
	N_F6_,
	N_F6S,
	N_G6_,
	N_G6S,
	N_A6_,
	N_A6S,
	N_B6_,
	N_C7_,
	N_C7S,
	N_D7_,
	N_D7S,
	N_E7_,
	N_F7_,
	N_F7S,
	N_G7_,
	N_G7S,
	N_A7_,
	N_A7S
};

void sound_reset();
void sound_welcome_sound();

#endif
