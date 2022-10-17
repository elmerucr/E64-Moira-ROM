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

blitter_init::	move.w	#C64_BLUE,BLITTER_CLC.w
		move.w	#C64_LIGHTBLUE,BLITTER_HBC.w
		move.w	#C64_LIGHTBLUE,BLITTER_VBC.w
		rts

blitter_screen_refresh_exception_handler::
		movem.l	D0-D1/A0-A1,-(SP)	; save scratch registers

		move.b	#$1,BLITTER_SR.w	; confirm pending irq
		move.b	#BLITTER_CMD_CLEAR_FRAMEBUFFER,BLITTER_TASK.w
		move.b	#BLITTER_CMD_DRAW_HOR_BORDER,BLITTER_TASK.w
		move.b	#BLITTER_CMD_DRAW_VER_BORDER,BLITTER_TASK.w

		movem.l	(SP)+,D0-D1/A0-A1	; restore scratch registers
		rte
