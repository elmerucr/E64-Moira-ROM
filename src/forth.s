; based on jonesforth
;
;

NEXT macro
		move (A2)+,A3
endm

		section	BSS

_dictionary	ds.b	32768	; dictionary 32kb size
_latest		ds.l	1	; pointer to latest entry in dictionary


		section	TEXT

_forth_init::	clr.l	_dictionary		; first entry is a null pointer
		move.l	#_dictionary,_latest
		rts

_forth_prompt::	rts

_forth_comm::	NEXT
		movea.l	(A0),A0		; another level of indirection
		jmp (A0)
		rts
