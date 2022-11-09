		include	"definitions.i"

		section	BSS

se_current_scr	ds.b	1

		section	TEXT

se_init::
		clr.b	se_current_scr
		move.b	#$b0,se_current_scr
		jsr	se_clear_screen
		move.b	#BLIT_CMD_ACTIVATE_CURSOR,BLIT_CONTEXT_00+BLIT_CR
		rts

se_loop::
.1		move.b	CIA_AC,D0
		beq	.1
		move.b	#BLIT_CMD_DEACTIVATE_CURSOR,BLIT_CONTEXT_00+BLIT_CR
		jsr	se_putchar
		move.b	#BLIT_CMD_ACTIVATE_CURSOR,BLIT_CONTEXT_00+BLIT_CR
		bra	.1

se_clear_screen::
		clr.w	BLIT_CONTEXT_00+BLIT_CURSOR_POS
		move.b	#' ',D0
.1		jsr	se_putsymbol
		move.b	#BLIT_CMD_INCREASE_CURSOR_POS,BLIT_CONTEXT_00+BLIT_CR
		btst	#7,BLIT_CONTEXT_00+BLIT_SR
		beq	.1

se_putsymbol::
		; putsymbol - expects code to be in D0, doesn't change registers
		move.b	D0,BLIT_CONTEXT_00+BLIT_CURSOR_CHAR
		move.w	BLIT_CONTEXT_00+BLIT_FG_COLOR,BLIT_CONTEXT_00+BLIT_CURSOR_FG_COLOR
		move.w	BLIT_CONTEXT_00+BLIT_BG_COLOR,BLIT_CONTEXT_00+BLIT_CURSOR_BG_COLOR
		rts

se_putchar::
is_lf		cmpi.b	#ASCII_LF,D0
		bne	is_cri
.1		move.b	#BLIT_CMD_INCREASE_CURSOR_POS,BLIT_CONTEXT_00+BLIT_CR
		btst	#6,BLIT_CONTEXT_00+BLIT_SR	; did we reach column 0?
		beq	.1		; no goto .1
		btst	#5,BLIT_CONTEXT_00+BLIT_SR	; did we reach the end of the screen?
		beq	.2
		jsr	se_add_bottom_row
.2		rts
is_cri		jsr	se_putsymbol
		move.b	#BLIT_CMD_INCREASE_CURSOR_POS,BLIT_CONTEXT_00+BLIT_CR
finish		rts

; THIS IS A HACK FOR NOW
se_puts::
		move.b	(A0)+,D0
		beq	.1
		jsr	se_putchar
		bra	se_puts
.1		rts

se_add_bottom_row::
		movem.l	A2,-(SP)

		move.w	BLIT_CONTEXT_00+BLIT_CURSOR_POS,-(SP)	; save old cursor position

		move.w	BLIT_CONTEXT_00+BLIT_NO_OF_TILES,D0
		clr.l	D1
		move.b	BLIT_CONTEXT_00+BLIT_COLUMNS,D1
		sub.w	D1,D0

		; hack
		movea.l	#$200000,A0
		movea.l #$400000,A1
		movea.l #$600000,A2

.1		move.b	(0,A0,D1),(A0)+
		lsl.b	D1
		move.w	(0,A1,D1),(A1)+
		move.w	(0,A2,D1),(A2)+
		lsr.b	D1
		subq	#1,D0
		bne	.1

.2		move.b	#' ',(A0)+
		move.w	BLIT_CONTEXT_00+BLIT_FG_COLOR,(A1)+
		move.w	BLIT_CONTEXT_00+BLIT_BG_COLOR,(A2)+
		subq	#1,D1
		bne	.2

		move.w (SP)+,BLIT_CONTEXT_00+BLIT_CURSOR_POS	; restore old cursor position

		move.b	BLIT_CONTEXT_00+BLIT_COLUMNS,D0
.3		move.b	#BLIT_CMD_DECREASE_CURSOR_POS,BLIT_CONTEXT_00+BLIT_CR
		sub.b	#1,D0
		bne	.3

		movem.l	(SP)+,A2
		rts
