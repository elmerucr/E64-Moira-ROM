	INCLUDE	"definitions.i"

	SECTION DATA

blitter_tty::
	DC.B	%00001010	; flags_0
	DC.B	%00000000	; flags_1
	DC.B	%01010110	; size
	DC.B	%00000000	; unused
	DC.W	$00		; x
	DC.W	$10		; y
	DC.W	C64_LIGHTBLUE	; foreground color
	DC.W	$0		; background color
	DC.L	$0		; pixel data
	DC.L	$0		; tiles
	DC.L	$0		; tiles color
	DC.L	$0		; tiles backgr color
	DC.L	$0		; user data


		section	TEXT

blitter_init::	move.w	#C64_BLUE,BLITTER_CLC
		move.w	#C64_LIGHTBLUE,BLITTER_HBC
		move.w	#C64_LIGHTBLUE,BLITTER_VBC
		rts

blitter_screen_refresh_exception_handler::
		movem.l	D0-D1/A0-A1,-(SP)	; save scratch registers

		move.b	#$1,BLITTER_SR		; confirm pending irq
		move.b	#BLITTER_CMD_CLEAR_FRAMEBUFFER,BLITTER_TASK
		move.b	#BLITTER_CMD_DRAW_HOR_BORDER,BLITTER_TASK
		move.b	#BLITTER_CMD_DRAW_VER_BORDER,BLITTER_TASK

		movem.l	(SP)+,D0-D1/A0-A1	; restore scratch registers
		rte
