	include	"definitions.i"

	section	RODATA

prompt	dc.b	ASCII_LF,'.',0
stmes	dc.b	ASCII_LF,ASCII_LF,'Monitor version 18.11.2022',0
ermes	dc.b	ASCII_LF,'invalid command',0
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
	lea.l	comtab,A0
	bsr	search
	bcs	exec2			; if command found, execute
	lea.l	ermes,A0		; error
	bra	se_puts			; and return (rts in puts)
exec2	movea.l	(A0),A0			; get command address
	jsr	(A0)

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

clear_comtab
	bra	se_clear_screen

ver_comtab
	move.b	ASCII_LF,D0
	jsr	se_putchar
	lea.l	rom_version,A0
	jsr	se_puts
	rts

jump_comtab

m_comtab
	bsr	consume_space
	bcs	.1
	lea.l	ermes,A0
	bra.s	.2
.1	lea.l	success,A0
.2	jsr	se_puts
	rts

; comtab is the built-in command table. All entries are made up of
; a string length + number of characters to match + the string
; plus the address of the command relative to COMTAB
comtab	dc.b	6,5
	dc.b	'clear '
	dc.l	clear_comtab
	dc.b	2,1
	dc.b	'm '		; m <address> examines contents of
	dc.l	m_comtab	; <address> and allows them to be changed
	dc.b	4,3
	dc.b	'ver '
	dc.l	ver_comtab
	dc.b	4,4		; jump <address> causes execution to
	dc.b	'jump'		; begin at <address>
	dc.l	jump_comtab
	dc.b	0,0		; end of table

consume_space
	cmp.b	#' ',(A2)+
	bne	.1
	or.b	#1,CCR
	rts
.1	and.b	#$fe,CCR
	rts
