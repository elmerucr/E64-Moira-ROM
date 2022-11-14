	include	"definitions.i"

	section	RODATA

prompt	dc.b	ASCII_LF,'.',0

	section	TEXT

monitor_setup::
	lea	monitor_prompt,A0
	move.l	A0,prompt_vector
	rts

monitor_prompt
	lea	prompt,A0
	jsr	se_puts
	rts
