		include	"definitions.i"

		section	BSS

prompt_vector::		ds.l	1	; callback pointer (event)
execute_vector::	ds.l	1	; callback pointer (event)
bottom_row_callback::	ds.l	1	; callback pointer (event)
top_row_callback::	ds.l	1	; callback pointer (event)
_se_command_buffer::	ds.b	80	; enough space (79 chars + '\0')
se_command_buffer_ptr	ds.l	1	; points to a character in command buffer
_se_do_prompt::		ds.b	1

		section	TEXT

se_loop::
	move.l	prompt_vector,-(SP)
	bsr	_puts
	lea	(4,SP),SP
no_prompt
	move.b	#1,_se_do_prompt		; reset prompt flag
	move.b	_current_blit,BLITTER_CONTEXT_PTR_NO.w
	movea.l	BLITTER_CONTEXT_PTR.w,A0
.1	move.b	#BLIT_CMD_ACTIVATE_CURSOR,(BLIT_CR,A0)
.2	move.b	CIA_AC,D0	; check for character
	beq.s	.2		; no, check again
	move.b	#BLIT_CMD_DEACTIVATE_CURSOR,(BLIT_CR,A0)
	cmp.b	#ASCII_LF,D0	; is it enter?
	beq.s	.3		; yes, goto .3
	move.w	D0,-(SP)
	bsr	_putchar
	lea	(2,SP),SP
	bra.s	.1
.3	bsr	se_fill_command_buffer
	movea.l	execute_vector,A0
	jsr	(A0)
	tst.b	_se_do_prompt
	beq.s	no_prompt
	bra.s	se_loop

_se_add_bottom_row::
	movem.l	A2-A3,-(SP)

	move.b	_current_blit,BLITTER_CONTEXT_PTR_NO.w
	movea.l	BLITTER_CONTEXT_PTR.w,A0

	move.w	(BLIT_NO_OF_TILES,A0),D0
	clr.l	D1
	move.b	(BLIT_COLUMNS,A0),D1
	sub.w	D1,D0				; D0 now contains tiles - no_of_columns

	movea.l	(BLIT_TILE_RAM_PTR,A0),A1
	movea.l (BLIT_FG_COLOR_RAM_PTR,A0),A2
	movea.l (BLIT_BG_COLOR_RAM_PTR,A0),A3

.1	move.b	(0,A1,D1),(A1)+
	lsl.b	D1
	move.w	(0,A2,D1),(A2)+
	move.w	(0,A3,D1),(A3)+
	lsr.b	D1
	subq	#1,D0
	bne.s	.1

.2	move.b	#' ',(A1)+			; fill bottom row with spaces
	move.w	(BLIT_FG_COLOR,A0),(A2)+
	move.w	(BLIT_BG_COLOR,A0),(A3)+
	subq	#1,D1
	bne.s	.2

;	move.b	(BLIT_COLUMNS,A0),D0
;.3	move.b	#BLIT_CMD_DECREASE_CURSOR_POS,(BLIT_CR,A0)	; bug??? for some reason cursor is always at zero pos when putchar
;	sub.b	#1,D0
;	bne.s	.3

	movem.l	(SP)+,A2-A3

	rts

_se_add_top_row::
	movem.l	D2/A2-A3,-(SP)

	move.b	_current_blit,BLITTER_CONTEXT_PTR_NO.w
	movea.l	BLITTER_CONTEXT_PTR.w,A0

	move.w	(BLIT_NO_OF_TILES,A0),D0
	subq.w	#1,D0	; D0 = index to last char
	move.w	D0,D1

	clr.l	D2
	move.b	(BLIT_COLUMNS,A0),D2
	sub.w	D2,D1

	movea.l	(BLIT_TILE_RAM_PTR,A0),A1
	movea.l (BLIT_FG_COLOR_RAM_PTR,A0),A2
	movea.l (BLIT_BG_COLOR_RAM_PTR,A0),A3

.1	move.b	(0,A1,D1),(0,A1,D0)
	lsl.w	#1,D0
	lsl.w	#1,D1
	move.w	(0,A2,D1),(0,A2,D0)
	move.w	(0,A3,D1),(0,A3,D0)
	lsr.w	#1,D0
	lsr.w	#1,D1

	subq.w	#1,D0
	subq.w	#1,D1
	cmp.w	#-1,D1
	bne.s	.1

.2	move.b	#' ',(0,A1,D0)
	lsl.w	#1,D0
	move.w	(BLIT_FG_COLOR,A0),(0,A2,D0)
	move.w	(BLIT_BG_COLOR,A0),(0,A3,D0)
	lsr.w	#1,D0
	subq.w	#1,D0
	cmp.w	#-1,D0
	bne.s	.2

;	move.b	(BLIT_COLUMNS,A0),D0
;.3	move.b	#BLIT_CMD_INCREASE_CURSOR_POS,(BLIT_CR,A0)
;	sub.b	#1,D0
;	bne.s	.3

	movem.l	(SP)+,D2/A2-A3

	rts

se_fill_command_buffer:
	move.b	_current_blit,BLITTER_CONTEXT_PTR_NO.w
	movea.l	BLITTER_CONTEXT_PTR.w,A0
	move.b	(BLIT_CURSOR_COLUMN,A0),-(SP)	; save current cursor pos
	move.w	#ASCII_CR,-(SP)			; move cursor to first position
	bsr	_putchar
	lea	(2,SP),SP
	movea.l	#_se_command_buffer,A1
.1	move.b	(BLIT_CURSOR_CHAR,A0),(A1)+
	move.b	#BLIT_CMD_INCREASE_CURSOR_POS,(BLIT_CR,A0)
	btst.b	#6,(BLIT_SR,A0)
	beq.s	.1
	clr.b	-(A1)	; place 0 at end of string
	move.b	#BLIT_CMD_DECREASE_CURSOR_POS,(BLIT_CR,A0)
	move.b	(SP)+,(BLIT_CURSOR_COLUMN,A0)
	move.l	#_se_command_buffer,se_command_buffer_ptr
	rts
