		include	"definitions.i"

		section TEXT

		dc.l	$00010000	; initial SSP
		dc.l	reset_exception	; initial PC

rom_version::	dc.b	'rom v20221211',0

reset_exception::
		;move.w	#$2700,sr	; supervisor mode, highest IPL (done by reset)

		;clr.l	D0		; Not needed, reset exception
		;movec	D0,VBR		; sets VBR to $00000000.

		move.l	#$00040000,D0	; set USP
		movec	D0,USP

		jsr	init_vector_table
		jsr	init_relocate_sections
		jsr	init_heap_pointers	; this doesn't make sense yet, memory area wrong?

		jsr	blitter_clear_display_list
		jsr	blitter_init_blit_0
		jsr	blitter_init_display_list
		jsr	_blitter_set_bordersize_and_colors

		; turn on interrupt generation by BLITTER (@ screenrefresh)
		move.b	#$01,BLITTER_CR.w

		; set up a 60Hz timer (3600bpm)
		;move.w	#3600,TIMER7_BPM.w
		;or.b	#%10000000,TIMER_CR.w	; turn on timer 7
		move.w	#3600,TIMER0_BPM.w
		or.b	#%00000001,TIMER_CR.w	; turn on timer 0

		; sound
		jsr	sound_reset
		;jsr	sound_welcome_sound

		; cia stuff
		jsr	_cia_init_keyboard

		; do not yet activate interrupts here, during init and
		; printing of first messages
		clr.b	BLITTER_CONTEXT_PTR_NO	; let's use screen/blit 0 in kernel mode
		jsr	se_clear_screen		; init screen editor
		movea.l	#welcome,A0
		jsr	se_puts
		;movea.l	#rom_version,A0
		;jsr	se_puts
		;move.b	#ASCII_LF,D0
		;jsr	se_putchar

		; set interrupt mask to 1, so all interrupts of 2 and higher allowed
		move.w	#$1,-(A7)
		jsr	set_interrupt_mask
		lea	($2,SP),SP

		;testing c routine... (to be removed later on)
		jsr	_test
		jsr	_test3
		;move.w	#$f67f,-(A7)
		;jsr	_test2
		;lea	($2,A7),A7

		jsr	monitor_setup

		jmp	se_loop

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

		pea	address_error
		move.b	#3,-(SP)
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
	move.l	#$00030000,_heap_start
	move.l	#$00030000,_heap_end
	rts

		section	VEC

timer_0_vec::	dc.l	timer_0_handler

address_error
	move.b	#$ff,BLITTER_HBS.w
	move.w	#$ff00,BLITTER_HBC.w
	move.b	#BLITTER_CMD_DRAW_HOR_BORDER,BLITTER_CR.w
.1	bra	.1

welcome	dc.b	'E64 Computer System (C)2022 elmerucr',0
