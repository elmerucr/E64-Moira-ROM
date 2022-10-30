		include	"definitions.i"

		section	TEXT

timer_exception_handler::
		movem.l	D0-D1/A0-A1,-(SP)	; save scratch registers

		;
		; do something
		;

		add.b	#10,BLITTER_HBS.w

		movem.l	(SP)+,D0-D1/A0-A1	; restore scratch registers
		rte

timer_0_handler::
		rts

timer_1_handler::
timer_2_handler::
timer_3_handler::
timer_4_handler::
timer_5_handler::
timer_6_handler::
timer_7_handler::
		rts
