		include	"definitions.i"

		section TEXT

		dc.l	$0000e000	; initial SSP
		dc.l	exc_reset	; initial PC

rom_version::	dc.b	'E64-ROM v0.4 20221010',0

exc_reset::	move.w	#$2700,sr

		jsr	init_vector_table
		jsr	init_relocate_sections
		jsr	init_heap_pointers

		jsr	blitter_init

		move.b	#$01,BLITTER_CR

		; set interrupt mask to 1, so all interrupts of 2 and more allowed
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
	MOVE.L	#_BSS_END,D0
	SUB.L	#_BSS_START,D0
	MOVE.L	D0,-(SP)	; push number of bytes
	MOVE.B	#$00,-(SP)	; push the clear value
	PEA	_BSS_START	; push address
	JSR	memset
	LEA	($a,SP),SP	; clean up stack

	RTS

init_vector_table
	pea	blitter_screen_refresh_exception_handler
	move.b	#28,-(SP)
	jsr	update_exception_vector
	lea	($6,SP),SP
	rts

init_heap_pointers
	MOVE.L	#_BSS_END,heap_start
	MOVE.L	#_BSS_END,heap_end
	RTS
