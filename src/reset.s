		include	"definitions.i"

		section TEXT

		dc.l	$0000e000	; initial SSP
		dc.l	exc_reset	; initial PC

rom_version::	dc.b	'E64-ROM v0.4 20221009',0

exc_reset::	move.w	#$2700,sr
		jsr	init_vector_table
		jsr	blitter_init

		move.b	#$01,BLITTER_CR

		; set interrupt mask to 1, so all interrupts of 2 and more allowed
		move.w	#$1,-(A7)
		jsr	set_interrupt_mask
		lea	($2,SP),SP

		jsr	sound_reset
		jsr	sound_welcome_sound

.1		bra	.1

	JSR	init_relocate_sections

	JSR	init_heap_pointers

	MOVE.B	#$03,$00000c80

	MOVE.L	#$8000,-(SP)	; 32kb heap reservation for char ram
	JSR	malloc		; D0 contains address after call
	LEA	($4,SP),SP	; restore stack
	MOVE.L	D0,char_ram
	JSR	init_create_character_ram

	;JSR	vicv_init
	JSR	blitter_init

	MOVE.W	#$1,-(SP)
	JSR	set_interrupt_mask
	LEA	($2,SP),SP

	;JSR	sids_reset
	;JSR	sids_welcome_sound

.2	BRA	.2


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

init_create_character_ram
	; Copy char rom to ram (from 2k to 32k). Expands charset 1 to 16 bit.
	; Scratch register Usage:
	; D0 current_byte, holds a byte from the original rom charset
	; D1 i, counter from 7 to 0 (for 8 bits per byte)
	; A0 must contain *char_ram pointer
	; A1 will contain *char_rom pointer
	MOVEQ	#0,D0			; current_byte = 0;
	MOVEA.L	char_ram,A0		; get char_ram pointer
	LEA	CHAR_ROM,A1
.1	CMPA.L	#CHAR_ROM+$800,A1	; end of rom?
	BEQ	.5			; return if end of rom is reached
	MOVE.B	(A1)+,D0		; load byte from rom
	MOVEQ	#8,D1			; start counter
.2	BTST	#$7,D0			; leftmost bit turned on?
	BEQ	.3			; no, goto .3
	MOVE.W	#C64_GREY,(A0)+		; yes, make ram pixel grey
	BRA	.4
.3	MOVE.W	#$0000,(A0)+		; no, make ram pixel transparent
.4	LSL.B	#$01,D0			; bitshift original byte 1 pix to left
	SUBQ	#$01,D1			; counter--
	BEQ	.1			; finish byte? Then goto .1
	BRA	.2
.5	RTS
