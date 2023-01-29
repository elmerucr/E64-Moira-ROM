;
; monitor_asm.s
; E64-ROM
;
; Copyright © 2022-2023 elmerucr. All rights reserved.
;

	include	"definitions.i"

	section	RODATA

prompt	dc.b	ASCII_LF,'.',0
stmes	dc.b	ASCII_LF,ASCII_LF,'Monitor',0

	section	TEXT

monitor_setup::
	lea	prompt,A0
	move.l	A0,prompt_vector
	lea	_execute,A0
	move.l	A0,execute_vector
	lea	_bottom_row,A0
	move.l	A0,bottom_row_callback
	lea	_top_row,A0
	move.l	A0,top_row_callback
	pea	stmes		; Point to banner
	bsr	_puts		; and print heading
	lea	(4,SP),SP
	rts
