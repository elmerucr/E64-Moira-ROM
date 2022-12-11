		include	"definitions.i"

		section	TEXT

blitter_clear_display_list::
		move.l	#$100,-(SP)		; 256 bytes
		move.b	#0,-(SP)		; put in 0
		move.l	#DISPL_LIST,-(SP)	; @ location displ list
		jsr	memset
		lea	($a,SP),SP		; restore stack
		rts

blitter_init_blit_0::
		clr.b	BLITTER_CONTEXT_PTR_NO.w
		movea.l	BLITTER_CONTEXT_PTR,A0
		move.b	#BLIT_CMD_DEACTIVATE_CURSOR,(BLIT_CR,A0)
		move.b	#$14,(BLIT_CURSOR_BLINK_INTERVAL,A0)
		move.b	#80,(BLIT_COLUMNS,A0)
		move.b	#44,(BLIT_ROWS,A0)
		move.b	#1,(BLIT_TILE_WIDTH,A0)
		move.b	#1,(BLIT_TILE_HEIGHT,A0)
		move.w	e64_blue_08,(BLIT_FG_COLOR,A0)
		clr.w	(BLIT_BG_COLOR,A0)
		rts

blitter_init_display_list::
		movea.l	#DISPL_LIST,A0
		move.b	#%00000001,(A0)+	; this is a blit
		clr.b	(A0)+			; we're dealing with blit0
		move.b	#%10001010,(A0)+	; flags 0 = $8a
		clr.b	(A0)+			; flags 1 = $00
		move.w	#0,(A0)+		; x position
		move.w	#24,(A0)		; y position
		rts

blitter_screen_refresh_exception_handler::
		movem.l	D0-D1/A0-A1,-(SP)	; save scratch registers

		move.b	#$1,BLITTER_SR.w	; confirm pending irq
		move.b	#BLITTER_CMD_CLEAR_FRAMEBUFFER,BLITTER_OPERATION.w

		movea	#DISPL_LIST,A0
.1		move.b	(A0)+,D0		; check command (1 = blit, 2 = ..., 4 = ...) TODO
		beq	.2			; if zero, go to end
		move.b	(A0)+,BLITTER_CONTEXT_PTR_NO.w		; load context number
		movea.l	BLITTER_CONTEXT_PTR,A1			; A1 points to right blit context
		move.b	(A0)+,(BLIT_FLAGS_0,A1)
		move.b	(A0)+,(BLIT_FLAGS_1,A1)
		move.w	(A0)+,(BLIT_XPOS,A1)
		move.w	(A0)+,(BLIT_YPOS,A1)
		move.b	#BLIT_CMD_DRAW_BLIT,(BLIT_CR,A1)
		cmp	#DISPL_LIST+$100,A0
		bne	.1

.2		move.b	#BLITTER_CMD_DRAW_HOR_BORDER,BLITTER_OPERATION.w
		move.b	#BLITTER_CMD_DRAW_VER_BORDER,BLITTER_OPERATION.w

		movem.l	(SP)+,D0-D1/A0-A1	; restore scratch registers
		rte
