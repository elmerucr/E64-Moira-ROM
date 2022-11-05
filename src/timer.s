		include	"definitions.i"

		section	TEXT

timer_exception_handler::
		movem.l	D0-D1/A0-A1,-(SP)	; save scratch registers

		;
		; do something
		;
		move.b	#1,D0
		movea.l	#TIMER0_VECTOR,A0
.1		bset	D0,TIMER_SR
		beq	.2
		addq	#1,D0
		addq	#4,A0
		bra	.1
.2		movea.l	(A0),A0
		jsr	(A0)
		movem.l	(SP)+,D0-D1/A0-A1	; restore scratch registers
		rte

timer_0_handler::
		clr.b	BLITTER_CONTEXT_0
		move.b	#BLIT_CMD_PROCESS_CURSOR_STATE,BLIT_CR.w
		;add.b	#1,BLITTER_HBS.w	; TODO remove later
		rts

timer_1_handler::
timer_2_handler::
timer_3_handler::
timer_4_handler::
timer_5_handler::
timer_6_handler::
timer_7_handler::
		rts
