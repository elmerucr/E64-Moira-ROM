		include	"definitions.i"

		section	TEXT

se_loop::
		movea.l	BLITTER_CONTEXT_PTR,A0
		move.b	#BLIT_CMD_ACTIVATE_CURSOR,(BLIT_CR,A0)
.1		move.b	CIA_AC,D0
		beq	.1
		move.b	#BLIT_CMD_DEACTIVATE_CURSOR,(BLIT_CR,A0)
		jsr	se_putchar
		move.b	#BLIT_CMD_ACTIVATE_CURSOR,(BLIT_CR,A0)
		bra	.1

se_clear_screen::
		movea.l	BLITTER_CONTEXT_PTR,A0
		clr.w	(BLIT_CURSOR_POS,A0)
		move.b	#' ',D0
.1		jsr	se_putsymbol
		move.b	#BLIT_CMD_INCREASE_CURSOR_POS,(BLIT_CR,A0)
		btst	#7,(BLIT_SR,A0)
		beq	.1

; putsymbol - expects code to be in D0
se_putsymbol::	movea.l	BLITTER_CONTEXT_PTR,A0
		move.b	D0,(BLIT_CURSOR_CHAR,A0)
		move.w	(BLIT_FG_COLOR,A0),(BLIT_CURSOR_FG_COLOR,A0)
		move.w	(BLIT_BG_COLOR,A0),(BLIT_CURSOR_BG_COLOR,A0)
		rts

se_putchar::	movem.l	A2-A3,-(SP)
		movea.l	BLITTER_CONTEXT_PTR,A0
is_lf		cmpi.b	#ASCII_LF,D0
		bne	is_cri
.1		move.b	#BLIT_CMD_INCREASE_CURSOR_POS,(BLIT_CR,A0)
		btst	#6,(BLIT_SR,A0)	; did we reach column 0?
		beq	.1		; no goto .1
		btst	#5,(BLIT_SR,A0)	; did we reach the end of the screen?
		beq	finish
		jsr	se_add_bottom_row
		bra	finish
is_cri		cmpi.b	#ASCII_CURSOR_RIGHT,D0
		bne	is_cl
		move.b	#BLIT_CMD_INCREASE_CURSOR_POS,(BLIT_CR,A0)
		btst	#5,(BLIT_SR,A0)	; did we reach the end of the screen?
		beq	finish
		jsr	se_add_bottom_row
		bra	finish
is_cl		cmpi.b	#ASCII_CURSOR_LEFT,D0
		bne	is_cd
		move.b	#BLIT_CMD_DECREASE_CURSOR_POS,(BLIT_CR,A0)
		btst	#5,(BLIT_SR,A0) ; did we cross start of the screen?
		beq	finish
		jsr	se_add_top_row
		bra	finish
is_cd		cmpi.b	#ASCII_CURSOR_DOWN,D0
		bne	is_cu
		move.b	(BLIT_COLUMNS,A0),D0
.1		move.b	#BLIT_CMD_INCREASE_CURSOR_POS,(BLIT_CR,A0)
		btst	#5,(BLIT_SR,A0)	; did we reach end screen?
		beq	.2
		move.l	D0,-(SP)
		jsr	se_add_bottom_row
		move.l	(SP)+,D0
.2		subq.b	#1,D0
		bne	.1
		bra	finish
is_cu		cmpi.b	#ASCII_CURSOR_UP,D0
		bne	is_bksp
		move.b	(BLIT_COLUMNS,A0),D0
.1		move.b	#BLIT_CMD_DECREASE_CURSOR_POS,(BLIT_CR,A0)
		btst	#5,(BLIT_SR,A0)	; did we reach start of screen?
		beq	.2
		move.l	D0,-(SP)
		jsr	se_add_top_row
		move.l	(SP)+,D0
.2		subq.b	#1,D0
		bne	.1
		movem.l	(SP)+,A2-A3	; finish
		rts
is_bksp		cmpi.b	#ASCII_BACKSPACE,D0
		bne	is_cr

		move.b	#BLIT_CMD_DECREASE_CURSOR_POS,(BLIT_CR,A0)
		btst	#5,(BLIT_SR,A0) ; did we cross start of the screen?
		beq	.1		; no goto .1
		jsr	se_add_top_row

.1		move.l	(BLIT_TILE_RAM_PTR,A0),A1
		movea.l (BLIT_FG_COLOR_RAM_PTR,A0),A2
		movea.l (BLIT_BG_COLOR_RAM_PTR,A0),A3
		moveq.l	#0,D0
		move.w	(BLIT_CURSOR_POS,A0),D0
		adda.l	D0,A1
		lsl.w	#1,D0
		adda.w	D0,A2
		adda.w	D0,A3
		lsr.w	#1,D0

elmer		move.b	(BLIT_COLUMNS,A0),D0
		sub.b	(BLIT_CURSOR_COLUMN,A0),D0
.2		subq.b	#1,D0				; D0 now contains the amount of chars to shift
		beq	.3				; reached 0
		move.b	(1,A1),(A1)+
		move.w	(2,A2),(A2)+
		move.w	(2,A3),(A3)+
		bra	.2
.3		move.b	#' ',(A1)
		move.w	(BLIT_FG_COLOR,A0),(A2)
		move.w	(BLIT_BG_COLOR,A0),(A3)
		bra	finish
is_cr		jsr	se_putsymbol
		move.b	#BLIT_CMD_INCREASE_CURSOR_POS,(BLIT_CR,A0)
		btst	#5,(BLIT_SR,A0)	; did we reach the end of the screen?
		beq	finish
		jsr	se_add_bottom_row
finish		movem.l	(SP)+,A2-A3
		rts

; putstring, pointer in A0
se_puts::	move.b	(A0)+,D0
		beq	.1
		move.l	A0,-(SP)
		jsr	se_putchar
		move.l	(SP)+,A0
		bra	se_puts
.1		rts

se_add_bottom_row::
		movem.l	A2-A3,-(SP)

		movea.l	BLITTER_CONTEXT_PTR,A0

		move.w	(BLIT_NO_OF_TILES,A0),D0
		clr.l	D1
		move.b	(BLIT_COLUMNS,A0),D1
		sub.w	D1,D0

		movea.l	(BLIT_TILE_RAM_PTR,A0),A1
		movea.l (BLIT_FG_COLOR_RAM_PTR,A0),A2
		movea.l (BLIT_BG_COLOR_RAM_PTR,A0),A3

.1		move.b	(0,A1,D1),(A1)+
		lsl.b	D1
		move.w	(0,A2,D1),(A2)+
		move.w	(0,A3,D1),(A3)+
		lsr.b	D1
		subq	#1,D0
		bne	.1

.2		move.b	#' ',(A1)+
		move.w	(BLIT_FG_COLOR,A0),(A2)+
		move.w	(BLIT_BG_COLOR,A0),(A3)+
		subq	#1,D1
		bne	.2

		move.b	(BLIT_COLUMNS,A0),D0
.3		move.b	#BLIT_CMD_DECREASE_CURSOR_POS,(BLIT_CR,A0)
		sub.b	#1,D0
		bne	.3

		movem.l	(SP)+,A2-A3
		rts

se_add_top_row::
		movem.l	A2-A3,-(SP)

		movea.l	BLITTER_CONTEXT_PTR,A0

		move.w	(BLIT_NO_OF_TILES,A0),D0
		subq.w	#1,D0	; D0 = index to last char
		move.w	D0,D1
		sub.b	(BLIT_COLUMNS,A0),D1

		movea.l	(BLIT_TILE_RAM_PTR,A0),A1
		movea.l (BLIT_FG_COLOR_RAM_PTR,A0),A2
		movea.l (BLIT_BG_COLOR_RAM_PTR,A0),A3

.1		move.b	(0,A1,D1),(0,A1,D0)
		lsl.w	#1,D0
		lsl.w	#1,D1
		move.w	(0,A2,D1),(0,A2,D0)
		move.w	(0,A3,D1),(0,A3,D0)
		lsr.w	#1,D0
		lsr.w	#1,D1

		subq.w	#1,D0
		subq.w	#1,D1
		cmp.w	#-1,D1
		bne	.1

.2		move.b	#' ',(0,A1,D0)
		lsl.w	#1,D0
		move.w	(BLIT_FG_COLOR,A0),(0,A2,D0)
		move.w	(BLIT_BG_COLOR,A0),(0,A3,D0)
		lsr.w	#1,D0
		subq.w	#1,D0
		cmp.w	#-1,D0
		bne	.2

		move.b	(BLIT_COLUMNS,A0),D0
.3		move.b	#BLIT_CMD_INCREASE_CURSOR_POS,(BLIT_CR,A0)
		sub.b	#1,D0
		bne	.3

		movem.l	(SP)+,A2-A3
		rts
