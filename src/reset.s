		include	"definitions.i"

		section TEXT

		dc.l	$0000e000	; initial SSP
		dc.l	reset_exception	; initial PC

rom_version::	dc.b	'E64-ROM v0.4 20221023',0

reset_exception::
		move.w	#$2700,sr	; supervisor mode, highest IPL

		jsr	init_vector_table
		jsr	init_relocate_sections
		jsr	init_heap_pointers

		jsr	blitter_clear_display_list
		jsr	blitter_init_blit_0
		jsr	blitter_init_display_list
		jsr	blitter_set_bordersize_and_colors

		move.b	#$01,BLITTER_CR		; turn on interrupt generation by BLITTER

		; set interrupt mask to 1, so all interrupts of 2 and higher allowed
		move.w	#$1,-(A7)
		jsr	set_interrupt_mask
		lea	($2,SP),SP

		jsr	sound_reset
		jsr	sound_welcome_sound

.1		bra	.1

init_relocate_sections
		; move data section
		MOVE.L	#_DATA_END,D0
		SUB.L	#_DATA_START,D0
		MOVE.L	D0,-(SP)	; push number of bytes
		PEA	_DATA_START	; push source address
		PEA	_RAM_START	; push destination address
		JSR	memcpy
		LEA	($c,SP),SP	; clean up stack

		; zero bss section
		move.l	#_BSS_END,D0
		sub.l	#_BSS_START,D0
		move.l	D0,-(SP)	; push number of bytes
		move.b	#$00,-(SP)	; push the clear value
		pea	_BSS_START	; push address
		jsr	memset
		lea	($a,SP),SP	; clean up stack

		rts

init_vector_table
		pea	timer_exception_handler
		move.b	#26,-(SP)
		jsr	update_exception_vector
		lea	($6,SP),SP

		pea	blitter_screen_refresh_exception_handler
		move.b	#28,-(SP)
		jsr	update_exception_vector
		lea	($6,SP),SP

		move.l	#timer_0_handler,TIMER0_VECTOR.w
		move.l	#timer_1_handler,TIMER1_VECTOR.w
		move.l	#timer_2_handler,TIMER2_VECTOR.w
		move.l	#timer_3_handler,TIMER3_VECTOR.w
		move.l	#timer_4_handler,TIMER4_VECTOR.w
		move.l	#timer_5_handler,TIMER5_VECTOR.w
		move.l	#timer_6_handler,TIMER6_VECTOR.w
		move.l	#timer_7_handler,TIMER7_VECTOR.w

		rts

init_heap_pointers
	move.l	#_BSS_END,heap_start
	move.l	#_BSS_END,heap_end
	rts

		section	VEC

timer_0_vec::	dc.l	timer_0_handler
