		include	"definitions.i"

		section	TEXT

timer_exception_handler::
		movem.l	D0-D1/A0-A1,-(SP)	; save scratch registers

		clr.b	D0			; start with timer 0
		movea.l	#TIMER0_VECTOR,A0

.1		btst	D0,TIMER_SR	; set?
		beq	.2		; no, goto .2

		move.b	#%00000001,D1
		lsl.b	D0,D1
		move.b	D1,TIMER_SR	; acknowledge
		movem.l	D0/A0,-(SP)
		movea.l (A0),A0
		jsr	(A0)
		movem.l	(SP)+,D0/A0

.2		addq	#1,D0
		addq	#4,A0
		cmp.b	#8,D0
		bne	.1

		movem.l	(SP)+,D0-D1/A0-A1	; restore scratch registers
		rte

timer_0_handler::
		movea.l	BLITTER_CONTEXT_PTR,A0
		move.b	#BLIT_CMD_PROCESS_CURSOR_STATE,(BLIT_CR,A0)
		rts
timer_1_handler::
timer_2_handler::
timer_3_handler::
timer_4_handler::
timer_5_handler::
timer_6_handler::
		rts
timer_7_handler::
		add.b	#1,BLITTER_HBS.w	; TODO remove later
		rts
