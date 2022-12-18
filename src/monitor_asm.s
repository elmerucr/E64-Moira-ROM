;
; monitor_asm.s
; E64-ROM
;
; Copyright © 2022 elmerucr. All rights reserved.
;

	include	"definitions.i"

	section	RODATA

prompt	dc.b	ASCII_LF,'.',0
stmes	dc.b	ASCII_LF,ASCII_LF,'Monitor',0
ermes	dc.b	'?',ASCII_LF,'error',0
ermes2	dc.b	'?',0
success	dc.b	ASCII_LF,'command recognized',0

	section	TEXT

monitor_setup::
	lea	prompt,A0
	move.l	A0,prompt_vector
	lea	execute,A0
	move.l	A0,execute_vector

	lea.l	stmes,A0	; Point to banner
	bsr	se_puts		; and print heading
	rts

execute
	lea.l	commands,A0
	bsr	search
	bcs	.1			; if command found, execute
	lea.l	ermes,A0		; error
	bra	se_puts			; and return (rts in puts)
.1	movea.l	(A0),A0			; get command address
	jsr	(A0)

; search_wrong
; .1	bsr	se_command_buffer_get_char
; 	cmp.b	#'.',D0
; 	beq	.1
; 	cmp.b	#' ',D0
; 	beq	.1
; 	tst.b	D0
; 	bne	.2
; 	lea	(4,SP),SP
; .2	rts

; at the end, A2 points to the next character in the command_buffer
search
	lea.l	se_command_buffer,A2	; A2 points to command_buffer
.1	cmp.b	#'.',(A2)
	bne	.2
	lea	(1,A2),A2
	bra	.1
.2	cmp.b	#' ',(A2)
	bne	.3
	lea	(1,A2),A2
	bra	.1
.3	tst.b	(A2)		; test for 0 (means empty command line)
	bne	.4
	lea	(4,SP),SP	; discard first return address from stack
	rts			; directly return to caller of execute
.4	clr.l	D0
	move.b	(A0),D0			; get first byte (=length of string)
	beq	search7			; if 0, then exit
	lea.l	(6,A0,D0.w),A1		; calculate address of next entry
	move.b	(1,A0),D1		; get characters to match
	move.b	(2,A0),D2		; get first character in this entry
	cmp.b	(A2)+,D2		; from the table and match with buffer
	beq	search3			; if match then try rest of string
search2	move.l	A1,A0			; else get address of next entry
	bra	search
search3	sub.b	#1,D1			; One less character to match
	beq	search6			; if match counter=0, then all done
	lea.l	(3,A0),A0		; else point to next char in table
search4	move.b	(A0)+,D2		; now match a pair of characters
	cmp.b	(A2)+,D2
	bne	search2			; no match, try next entry
	sub.b	#1,D1			; else decr counter and
	bne	search4			; repeat until no chars left to match
search6	lea.l	(-4,A1),A0		; calc addr of command entry
	or.b	#1,CCR			; point. Mark carry flag as success
	rts				; and return
search7	and.b	#$fe,CCR		; fail, clear carry to indicate
	rts				; and return

clear_command
	clr.b	do_prompt
	bsr	se_clear_screen
	;movea.l	BLITTER_CONTEXT_PTR,A0
	move.b	#'.',D0
	jsr	putchar
	rts

ver_command
	move.b	#ASCII_LF,D0
	bsr	putchar
	lea.l	rom_version,A0
	bsr	se_puts
	rts

jump_command
	lea.l	success,A0
	bsr	se_puts
	rts

m_command
	bsr	consume_space
	bcc.s	m_err		; error
	bsr	hex
	bcc.s	m_err		; error, not hex
	movem.l	D2-D3,-(SP)
	clr.l	D1
m_nc	add.b	D0,D1
	bsr	hex
	bcc.s	m_ea1		; not hex, reached the end of address1
	lsl.l	#4,D1
	bra.s	m_nc		; next char
m_ea1	and.l	#$00ffffff,D1	; make 24 bit address
	move.l	D1,D3		; D3 contains start address

	addq	#1,A2		; advance pointer one step

	bsr	hex		; start work on end address
	bcc.s	.3		; not hex -> end address = start address

	clr.l	D1
	add.b	D0,D1
	nop
	nop
	;
	; process rest of end address
	;
	;


.3	move.l	D3,D0		; move start address back into D0
	movea.l	BLITTER_CONTEXT_PTR,A0
	move.b	(BLIT_ROWS,A0),D2
	sub.b	#1,D2
.4	move.b	D0,-(SP)
	move.b	#ASCII_LF,D0
	bsr	putchar
	move.b	(SP)+,D0
	bsr	memory
	movea.l	BLITTER_CONTEXT_PTR,A0
	cmp.b	(BLIT_CURSOR_ROW,A0),D2
	bne.s	.4

	clr.b	do_prompt
	movem.l	(SP)+,D2-D3
	rts
m_err	lea.l	ermes,A0
	bsr	se_puts
	rts

; invoked with ":" character (monitor view)
m_input_command
	movem.l	D2/A3-A4,-(SP)
	clr.l	D1		; destination register
	moveq	#6,D2		; need 6 hex digits

.1	bsr	hex		; get one character
	bcc.s	.2		; not a hex number
	lsl.l	#4,D1
	add.b	D0,D1
	subq	#1,D2
	bne.s	.1

	movea.l	D1,A3		; prepare addresses
	movea.l	A3,A4
	adda.l	#8,A4

.3	bsr	consume_space
	bcc.s	.2
	bsr	hex	; grab first digit of byte
	bcc.s	.2
	move.b	D0,D1
	lsl.b	#4,D1
	bsr	hex	; grab second digit of byte
	bcc.s	.2
	add.b	D0,D1
	move.b	D1,(A3)+
	cmp.l	A3,A4
	bne	.3

	move.b	#ASCII_CR,D0
	bsr	putchar
	move.l	A3,D0
	sub.l	#8,D0
	bsr	memory

	move.b	#ASCII_LF,D0
	bsr	putchar
	move.b	#'.',D0
	bsr	putchar
	move.b	#':',D0
	bsr	putchar

	move.l	A3,D0
	bsr	out6x
	move.b	#' ',D0
	bsr	putchar

	;lea.l	success,A0
	;bsr	se_puts
	clr.b	do_prompt
	movem.l	(SP)+,D2/A3-A4
	rts
.2	suba.l	#se_command_buffer,A2
	movea.l	BLITTER_CONTEXT_PTR,A0
	move.l	A2,D0
	move.b	D0,(BLIT_CURSOR_COLUMN,A0)
	lea.l	ermes2,A0
	bsr	se_puts
	movem.l	(SP)+,D2/A3-A4
	rts


; commands is the built-in command table. All entries are made up of
; a string length + number of characters to match + the string
; plus the address of the command relative to commands
commands
	dc.b	6,5
	dc.b	'clear '
	dc.l	clear_command
	dc.b	2,1
	dc.b	'm '		; m <address> examines contents of
	dc.l	m_command	; <address> and allows them to be changed
	dc.b	4,3
	dc.b	'ver '
	dc.l	ver_command
	dc.b	4,4		; jump <address> causes execution to
	dc.b	'jump'		; begin at <address>
	dc.l	jump_command
	dc.b	2,1
	dc.b	': '
	dc.l	m_input_command
	dc.b	0,0		; end of table

consume_space
	cmp.b	#' ',(A2)+
	bne.s	.1
	or.b	#1,CCR		; success
	rts
.1	and.b	#$fe,CCR	; no success
	rts

hex	move.b	(A2)+,D0
	andi.b	#%01111111,D0	; remove reversed
	sub.b	#$30,D0
	bmi.s	not_hex		; less than 30? --> error
	cmp.b	#$9,D0		; else test for number
	bls.s	hex_ok		; yes, success
	and.b	#%11011111,D0	; convert to uppercase
	sub.b	#$11,D0		; convert letter to hex
	cmp.b	#$5,D0		; if char range A (0) to F (5)
	bls.s	hex_ok2		; yes, exit successfully
not_hex	and.b	#$fe,CCR
	rts
hex_ok2	add.b	#$a,D0
hex_ok	or.b	#$1,CCR
	rts

; byte	bsr.s	hex
; 	asl.b	#4,D0
; 	move.b	D0,D1
; 	bsr.s	hex
; 	add.b	D1,D0
; 	rts

; address in D1
;print_address;
;	move.l	D1,D0
;	bsr	memory
;	rts

out1x	move.w	D0,-(A7)	; Save D0
        and.b	#$f,D0		; Mask off MS nybble
	add.b	#$30,D0		; Convert to ASCII
	cmp.b	#$39,D0		; ASCII = HEX + $30
	bls.s	out1x1		; If ASCII <= $39 then print and exit
	add.b	#$27,D0		; Else ASCII := HEX + $27
out1x1	bsr	putchar	; Print the character
	move.w	(A7)+,D0	; Restore D0
	rts

out2x	ror.b	#4,D0		; Get MS nybble in LS position
        bsr.s	out1x		; Print MS nybble
        rol.b	#4,D0		; Restore LS nybble
        bra.s	out1x		; Print LS nybble and return

out4x	ror.w	#8,D0		; Get MS byte in LS position
	bsr.s	out2x		; Print MS byte
	rol.w	#8,D0		; Restore LS byte
	bra.s	out2x		; Print LS byte and return

out6x	swap	D0
	bsr.s	out2x
	swap	D0
	bra.s	out4x

out8x	swap	D0		; Get MS word in LS position
	bsr.s	out4x		; Print MS word
	swap	D0		; Restore LS word
	bra.s	out4x		; Print LS word and return

; starting address must be in D0
; (address + 8) in D0 at end of routine
memory
	movem.l	A2-A4,-(SP)
	move.l	D0,A2		; start address in A2
	movea.l	A2,A4		; copy to A4
	;move.b	#ASCII_LF,D0	; next line
	;bsr	putchar
	move.b	#'.',D0	; print '.:' and address
	bsr	putchar
	move.b	#':',D0
	bsr	putchar
	move.l	A2,D0
	bsr.s	out6x
	move.l	A2,A3
	adda.l	#8,A3		; A3 now contains end address
.1	move.b	#' ',D0
	bsr	putchar
	move.b	(A2)+,D0
	bsr.s	out2x		; print hex byte
	cmp.l	A2,A3
	bne	.1
	move.b	#' ',D0		; space between hex and chars
	bsr	putchar
	movea.l	A4,A2		; A2 back to start
	movea.l	BLITTER_CONTEXT_PTR,A0
.2	move.b	(A2)+,D0
	bsr	se_putsymbol
	move.b	#BLIT_CMD_INCREASE_CURSOR_POS,(BLIT_CR,A0)
	cmp.l	A2,A3
	bne	.2
	move.l	A2,D0				; D0 contains next address
	move.b	#9,(BLIT_CURSOR_COLUMN,A0)	; move cursor to right position
	movem.l	(SP)+,A2-A4
	rts
