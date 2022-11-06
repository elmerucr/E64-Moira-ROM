		include	"definitions.i"

		section	TEXT

se_init::
		clr.b	BLITTER_CONTEXT_0
		jsr	se_clear_screen
		move.b	#BLIT_CMD_ACTIVATE_CURSOR,BLIT_CR
		rts

se_loop::	move.b	CIA_AC,D0
		beq	se_loop
		move.b	#BLIT_CMD_DEACTIVATE_CURSOR,BLIT_CR
		jsr	se_putchar
		move.b	#BLIT_CMD_ACTIVATE_CURSOR,BLIT_CR
		bra	se_loop

se_clear_screen::
		clr.w	BLIT_CURSOR_POS
		move.b	#' ',D0
.1		jsr	se_putsymbol
		move.b	#BLIT_CMD_INCREASE_CURSOR_POS,BLIT_CR
		btst	#7,BLIT_SR
		beq	.1

se_putsymbol::
		; putsymbol - expects code to be in D0, doesn't change registers
		move.b	D0,BLIT_CURSOR_CHAR
		move.w	BLIT_FG_COLOR,BLIT_CURSOR_FG_COLOR
		move.w	BLIT_BG_COLOR,BLIT_CURSOR_BG_COLOR
		rts

se_putchar::
is_lf		cmpi.b	#ASCII_LF,D0
		bne	is_cri
.1		move.b	#BLIT_CMD_INCREASE_CURSOR_POS,BLIT_CR
		btst	#6,BLIT_SR	; did we reach column 0?
		beq	.1
		rts
is_cri		jsr	se_putsymbol
		move.b	#BLIT_CMD_INCREASE_CURSOR_POS,BLIT_CR
		rts

; THIS IS A HACK FOR NOW
se_puts::
		move.b	(A0)+,D0
		beq	.1
		jsr	se_putchar
		bra	se_puts
.1		rts
