;
; blitter_asm.s
; E64-ROM
;
; Copyright © 2022 elmerucr. All rights reserved.
;

	include	"definitions.i"

	section	BSS

add_row_flag
	ds.w	1

	section	TEXT

blitter_screen_refresh_exception_handler::
	movem.l	D0-D1/A0-A1,-(SP)	; save scratch registers

	move.b	#$1,BLITTER_SR.w	; confirm pending irq
	move.b	#BLITTER_CMD_CLEAR_FRAMEBUFFER,BLITTER_OPERATION.w

	movea.l	#DISPL_LIST,A0
.1	move.b	(A0)+,D0		; check command (1 = blit, 2 = ..., 4 = ...) TODO
	beq	.2			; if zero, go to end
	move.b	(A0)+,BLITTER_CONTEXT_PTR_NO.w		; load context number
	movea.l	BLITTER_CONTEXT_PTR.w,A1			; A1 points to right blit context
	move.b	(A0)+,(BLIT_FLAGS_0,A1)
	move.b	(A0)+,(BLIT_FLAGS_1,A1)
	move.w	(A0)+,(BLIT_XPOS,A1)
	move.w	(A0)+,(BLIT_YPOS,A1)
	move.b	#BLIT_CMD_DRAW_BLIT,(BLIT_CR,A1)
	cmp	#DISPL_LIST+$100,A0
	bne	.1

.2	move.b	#BLITTER_CMD_DRAW_HOR_BORDER,BLITTER_OPERATION.w
	move.b	#BLITTER_CMD_DRAW_VER_BORDER,BLITTER_OPERATION.w

	movem.l	(SP)+,D0-D1/A0-A1	; restore scratch registers
	rte

; putsymbol - expects code to be on stack
; the code must be pushed as a word, hence (5,SP)
_putsymbol::
	move.b	_current_blit,BLITTER_CONTEXT_PTR_NO.w
	movea.l	BLITTER_CONTEXT_PTR.w,A0
	move.b	(5,SP),(BLIT_CURSOR_CHAR,A0)
	move.w	(BLIT_FG_COLOR,A0),(BLIT_CURSOR_FG_COLOR,A0)
	move.w	(BLIT_BG_COLOR,A0),(BLIT_CURSOR_BG_COLOR,A0)
	rts

; expects character to be on stack, destroys A0,A1
_putchar::
	;link	A6,#0
	movem.l	A2-A3,-(SP)
	clr.w	add_row_flag
	move.b	_current_blit,BLITTER_CONTEXT_PTR_NO
	movea.l	BLITTER_CONTEXT_PTR.w,A0
	move.b	($d,SP),D0

is_lf	cmpi.b	#ASCII_LF,D0
	bne	is_cri

	clr.b	(BLIT_CURSOR_COLUMN,A0)
	move.b	(BLIT_ROWS,A0),D0
	subi.b	#1,D0
	cmp.b	(BLIT_CURSOR_ROW,A0),D0
	bne	.1
	bsr	_se_add_bottom_row
	bra	finish
.1	addi.b	#1,(BLIT_CURSOR_ROW,A0)
	bra	finish

is_cri	cmpi.b	#ASCII_CURSOR_RIGHT,D0
	bne	is_cl
	move.b	#BLIT_CMD_INCREASE_CURSOR_POS,(BLIT_CR,A0)
	btst	#5,(BLIT_SR,A0)	; did we reach the end of the screen?
	beq	finish
	move.l	A0,-(SP)
	bsr	_se_add_bottom_row
	move.l	(SP)+,A0
	bra	finish
is_cl	cmpi.b	#ASCII_CURSOR_LEFT,D0
	bne	is_cd
	tst.w	(BLIT_CURSOR_POS,A0)
	beq	finish
	move.b	#BLIT_CMD_DECREASE_CURSOR_POS,(BLIT_CR,A0)
;	btst	#5,(BLIT_SR,A0) ; did we cross start of the screen?
;	beq	finish
;	move.l	A0,-(SP)
;	bsr	_se_add_top_row
;	move.l	(SP)+,A0
	bra	finish
is_cd	cmpi.b	#ASCII_CURSOR_DOWN,D0
	bne	is_cu

	move.b	(BLIT_ROWS,A0),D0
	subi.b	#1,D0
	cmp.b	(BLIT_CURSOR_ROW,A0),D0	; are we at the last row?
	bne	.1	; no goto 1
	move.l	A0,-(SP)
	movea.l	bottom_row_callback,A0
	jsr	(A0)
	move.l	(SP)+,A0
	bra	finish
.1	addi.b	#1,(BLIT_CURSOR_ROW,A0)
	bra	finish


;	move.b	(BLIT_COLUMNS,A0),D0
;.1	move.b	#BLIT_CMD_INCREASE_CURSOR_POS,(BLIT_CR,A0)
;	btst	#5,(BLIT_SR,A0)	; did we reach end screen?
;	beq.s	.2		; no
;	move.w	#1,add_row_flag	; yes
;.2	subq.b	#1,D0
;	bne.s	.1
;	tst.w	add_row_flag
;	beq	.3
;	move.l	A0,-(SP)
;	bsr	_se_add_bottom_row
;	movea.l	bottom_row_callback,A0
;	jsr	(A0)
;	move.l	(SP)+,A0
;.3	bra	finish
is_cu	cmpi.b	#ASCII_CURSOR_UP,D0
	bne	is_bksp

	tst.b	(BLIT_CURSOR_ROW,A0)	; are we at row 0?
	bne	.1	; no goto 1
	move.l	A0,-(SP)
	movea.l	top_row_callback,A0
	jsr	(A0)
	move.l	(SP)+,A0
	bra.s	.2
.1	subi.b	#1,(BLIT_CURSOR_ROW,A0)
.2	movem.l	(SP)+,A2-A3
	rts

is_bksp	cmpi.b	#ASCII_BACKSPACE,D0
	bne	is_cr
	tst.w	(BLIT_CURSOR_POS,A0)
	beq	finish
	move.b	#BLIT_CMD_DECREASE_CURSOR_POS,(BLIT_CR,A0)
	move.l	(BLIT_TILE_RAM_PTR,A0),A1
	movea.l (BLIT_FG_COLOR_RAM_PTR,A0),A2
	movea.l (BLIT_BG_COLOR_RAM_PTR,A0),A3
	moveq.l	#0,D0
	move.w	(BLIT_CURSOR_POS,A0),D0
	adda.l	D0,A1
	lsl.w	#1,D0
	adda.w	D0,A2
	adda.w	D0,A3
	lsr.w	#1,D0
	move.b	(BLIT_COLUMNS,A0),D0
	sub.b	(BLIT_CURSOR_COLUMN,A0),D0
.1	subq.b	#1,D0				; D0 now contains the amount of chars to shift
	beq.s	.2				; reached 0
	move.b	(1,A1),(A1)+
	move.w	(2,A2),(A2)+
	move.w	(2,A3),(A3)+
	bra.s	.1
.2	move.b	#' ',(A1)			; puts space keeps existing fg and bg color
	bra	finish
is_cr	cmp.b	#ASCII_CR,D0
	bne	is_sym
	clr.b	(BLIT_CURSOR_COLUMN,A0)
	bra	finish
is_sym	move.b	D0,(BLIT_CURSOR_CHAR,A0)			; _putsymbol directly
	move.w	(BLIT_FG_COLOR,A0),(BLIT_CURSOR_FG_COLOR,A0)	; _putsymbol directly
	move.w	(BLIT_BG_COLOR,A0),(BLIT_CURSOR_BG_COLOR,A0)	; _putsymbol directly
	move.b	#BLIT_CMD_INCREASE_CURSOR_POS,(BLIT_CR,A0)
	btst	#5,(BLIT_SR,A0)	; did we reach the end of the screen?
	beq	finish
	move.l	A0,-(SP)
	bsr	_se_add_bottom_row
	move.b	(BLIT_ROWS,A0),D0
	subi.b	#1,D0
	move.b	D0,(BLIT_CURSOR_ROW,A0)
	move.l	(SP)+,A0
finish	movem.l	(SP)+,A2-A3
	;unlk	A6
	rts

; putstring, needs pointer on stack
_puts::	;link	A6,#0
	move.l	A2,-(SP)
	movea.l	($8,SP),A2
	;moveq	#0,D0
.1	move.b	(A2)+,D0
	beq.s	.2
	move.w	D0,-(SP)	; move as word in stead of byte
	bsr	_putchar
	lea	(2,SP),SP
	bra.s	.1
.2	movea.l	(SP)+,A2
	;unlk	A6
	rts
