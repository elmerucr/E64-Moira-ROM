		include "definitions.i"

		section	TEXT

sound_reset::	move.l	#$80,-(SP)	; push number of bytes
		move.b	#$0,-(SP)	; push data item
		pea	SND		; push starting address
		jsr	memset		; call memset
		lea	($a,SP),SP	; restore stack
		move.b	#$f,SID0V.w
		move.b	#$f,SID1V.w
		move.b	#$f,SID2V.w
		move.b	#$f,SID3V.w

		; analogs?

		move.l	#$10,-(SP)	; set all 16 mixer volumes on max
		move.b	#$ff,-(SP)
		pea	SNDM
		jsr	memset
		lea	($a,SP),SP

		rts

sound_welcome_sound::
		; play a welcome sound on SID0
		lea	SID0,A0
		lea	music_notes,A1
		move.w	(N_D3_,A1),(A0)		; set frequency of voice 1
		move.b	#%00001001,($5,A0)	; attack and decay of voice 1
		move.w	#$f0f,$02(A0)		; pulse width of voice 1
		move.b	#$ff,SNDM0L		; left channel mix
		move.b	#$10,SNDM0R		; right channel mix
		move.b	#%01000001,($4,A0)	; pulse (bit 6) and open gate (bit 0)
		; play a welcome sound on SID1
		lea	SID1,A0
		lea	music_notes,A1
		move.w	(N_A3_,A1),(A0)		; set frequency of voice 1
		move.b	#%00001001,($5,A0)	; attack and decay of voice 1
		move.w	#$f0f,($2,A0)		; pulse width of voice 1
		move.b	#$10,SNDM1L		; left channel mix
		move.b	#$ff,SNDM1R		; right channel mix
		move.b	#%01000001,($4,A0)	; pulse (bit 6) and open gate (bit 0)
		rts
