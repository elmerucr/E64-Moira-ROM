		include	"definitions.i"

		section	DATA

blitter_tty::	dc.b	%00001010	; flags_0
		dc.b	%00000000	; flags_1
		dc.b	%01010110	; size
		dc.b	%00000000	; unused
		dc.w	$00		; x
		dc.w	$10		; y
		dc.w	C64_LIGHTBLUE	; foreground color
		dc.w	$0		; background color
		dc.l	$0		; pixel data
		dc.l	$0		; tiles
		dc.l	$0		; tiles color
		dc.l	$0		; tiles backgr color
		dc.l	$0		; user data


		section	TEXT

blitter_clear_display_list::
		move.l	#$100,-(SP)		; 256 bytes
		move.b	#0,-(SP)		; put in 0
		move.l	#DISPL_LIST,-(SP)	; @ location displ list
		jsr	memset
		lea	($a,SP),SP		; restore stack
		rts

blitter_init_blit_0::
		clr.b	BLITTER_CONTEXT_0.w	; work with 1st blit
		move.b	#$14,BLIT_CURSOR_BLINK_INTERVAL.w
		move.b	#80,BLIT_COLUMNS.w
		move.b	#45,BLIT_ROWS.w
		move.b	#1,BLIT_TILE_WIDTH.w
		move.b	#1,BLIT_TILE_HEIGHT.w
		move.w	e64_blue_08,BLIT_FG_COLOR.w
		clr.w	BLIT_BG_COLOR.w
		rts

blitter_init_display_list::
		movea.l	#DISPL_LIST,A0
		move.b	#%00000001,(A0)+	; this is a blit
		clr.b	(A0)+			; we're dealing with blit0
		move.b	#%10001010,(A0)+	; flags 0 = $8a
		clr.b	(A0)+			; flags 1 = $00
		move.w	#0,(A0)+		; x position
		move.w	#20,(A0)		; y position
		rts

blitter_set_bordersize_and_colors::
		move.w	e64_blue_03,BLITTER_CLC.w
		move.w	e64_blue_01,BLITTER_HBC.w
		move.w	e64_blue_01,BLITTER_VBC.w
		move.b	#20,BLITTER_HBS.w
		clr.b	BLITTER_VBS.w
		rts

blitter_screen_refresh_exception_handler::
		movem.l	D0-D1/A0-A1,-(SP)	; save scratch registers

		move.b	#$1,BLITTER_SR.w	; confirm pending irq
		move.b	#BLITTER_CMD_CLEAR_FRAMEBUFFER,BLITTER_TASK.w

		move.b	BLITTER_CONTEXT_0,-(SP)	; save current context

		movea	#DISPL_LIST,A0
.1		move.b	(A0)+,D0		; check command (1 = blit, 2 = ..., 4 = ...)
		beq	.2			; if zero, end it
		move.b	(A0)+,BLITTER_CONTEXT_0	; load context number
		move.b	(A0)+,BLIT_FLAGS_0
		move.b	(A0)+,BLIT_FLAGS_1
		move.w	(A0)+,BLIT_XPOS
		move.w	(A0)+,BLIT_YPOS
		move.b	#BLIT_CMD_DRAW_BLIT,BLIT_CR
		cmp	DISPL_LIST+$100,A0
		bne	.1

.2		move.b	#BLITTER_CMD_DRAW_HOR_BORDER,BLITTER_TASK.w
		move.b	#BLITTER_CMD_DRAW_VER_BORDER,BLITTER_TASK.w

		move.b	(SP)+,BLITTER_CONTEXT_0	; restore old context

		movem.l	(SP)+,D0-D1/A0-A1	; restore scratch registers
		rte
