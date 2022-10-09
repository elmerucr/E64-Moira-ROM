		section	BSS

heap_start::	ds.l	1
heap_end::	ds.l	1
char_ram::	ds.l	1


		section	TEXT

; void *malloc(size_t chunk);
malloc::	MOVE.L	($4,SP),D1	; load chunk size parameter from stack
		BTST.L	#$0,D1		; test bit zero
		BEQ	.1
		ADDQ	#$1,D1		; add one for word alignment
.1		MOVE.L	heap_end,D0	; return value in D0
		ADD.L	D1,heap_end	; update heap pointer
		RTS

;u8 *memcpy(u8 *dest, const u8 *src, size_t count)
;{
;	for (u32 i=0; i<count; i++)
;		dest[i] = src[i];
;	return dest;
;}
memcpy::	movea.l	($4,SP),A1	; dest
		movea.l	($8,SP),A0	; src
		move.l	($c,SP),D0	; no of bytes
		beq	.2		; if no of bytes=0 then return
.1		move.b	(A0)+,(A1)+
		subq	#$1,D0
		bne	.1
.2		rts

;u8 *memset(u8 *dest, u8 val, size_t count)
;{
;	for (u32 i=0; i<count; i++)
;		dest[i] = val;
;	return dest;
;}
memset::	movea.l	($4,SP),A0	; destination
		move.b	($8,SP),D0	; value
		move.l	($a,SP),D1	; no of bytes
		beq	.2		; if no of bytes=0 then return
.1		move.b	D0,(A0)+
		subq	#$1,D1
		bne	.1
.2		rts

**************************************
* void set_interrupt_mask(word mask) *
**************************************
set_interrupt_mask::
		move.w	($4,SP),D0	; get word value from stack
		andi.w	#$7,D0		; between 0 and 7
		lsl.w	#$8,D0		; leftshift 8 bits
		move	SR,D1		; get current status register
		andi.w	#$f8ff,D1	; clear IPL values
		or.w	D0,D1		; apply new level
		move	D1,SR		; move back to SR
		rts

*****************************
* word get_interrupt_mask() *
*****************************
get_interrupt_mask::
		move	SR,D0
		andi.w	#$0700,D0
		lsr.w	#$8,D0		; current priority is in D0 = return value
		rts


*****************************************************************
* void update_exception_vector(byte vectornumber, long address) *
*****************************************************************
update_exception_vector::
		LINK	A6,#-$2		; local storage for current imask
		JSR	get_interrupt_mask
		MOVE.W	D0,(-$2,A6)	; store it
		MOVE.W	#$7,-(SP)	; mask all incoming irq's
		jsr	set_interrupt_mask
		lea	($2,SP),SP
		clr.l	D0
		move.b	($8,A6),D0
		add.l	D0,D0
		add.l	D0,D0		; times 4 to get address
		movea.l	D0,A0
		move.l	($a,A6),D0
		move.l	D0,(A0)
		move.w	(-$2,A6),-(SP)	; load former value of imask
		jsr	set_interrupt_mask
		lea	($2,SP),SP
		unlk	A6
		rts
