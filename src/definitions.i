;
; definitions.i
; E64-ROM
;
; Copyright © 2022-2023 elmerucr. All rights reserved.
;

; fixed ram locations
DISPL_LIST		equ	$0400
TIMER0_VECTOR		equ	$0500
TIMER1_VECTOR		equ	$0504
TIMER2_VECTOR		equ	$0508
TIMER3_VECTOR		equ	$050c
TIMER4_VECTOR		equ	$0510
TIMER5_VECTOR		equ	$0514
TIMER6_VECTOR		equ	$0518
TIMER7_VECTOR		equ	$051c

; blitter registers
BLITTER			equ	$0800
BLITTER_SR		equ	BLITTER
BLITTER_CR		equ	BLITTER+$01
BLITTER_OPERATION	equ	BLITTER+$02
BLITTER_CONTEXT_PTR_NO	equ	BLITTER+$03
BLITTER_CONTEXT_PTR	equ	BLITTER+$04	; 32 bit
BLITTER_HBS		equ	BLITTER+$08
BLITTER_VBS		equ	BLITTER+$0a
BLITTER_HBC		equ	BLITTER+$0c	; 16 bit
BLITTER_VBC		equ	BLITTER+$0e	; 16 bit
BLITTER_CLC		equ	BLITTER+$10	; 16 bit

; blitter commands
BLITTER_CMD_CLEAR_FRAMEBUFFER	equ	%00000001
BLITTER_CMD_DRAW_HOR_BORDER	equ	%00000010
BLITTER_CMD_DRAW_VER_BORDER	equ	%00000100

; blit specific registers in contexts
BLIT			equ	$10000
BLIT_SR			equ	$00
BLIT_CR			equ	$01
BLIT_FLAGS_0		equ	$02
BLIT_FLAGS_1		equ	$03
BLIT_TILE_WIDTH		equ	$04
BLIT_TILE_HEIGHT	equ	$05
BLIT_COLUMNS		equ	$06
BLIT_ROWS		equ	$07
BLIT_FG_COLOR		equ	$08
BLIT_BG_COLOR		equ	$0a
BLIT_XPOS		equ	$0c	; 16 bit
BLIT_YPOS		equ	$0e	; 16 bit
BLIT_NO_OF_TILES	equ	$10	; 16 bit read only
BLIT_CURSOR_POS		equ	$12	; 16 bit pointer
BLIT_CURSOR_COLUMN	equ	$14	; 8 bit read only
BLIT_CURSOR_ROW		equ	$15	; 8 bit read only
BLIT_CURSOR_BLINK_INTERVAL	equ	$16	; read/write
BLIT_CURSOR_CHAR	equ	$17	; read/write
BLIT_CURSOR_FG_COLOR	equ	$18	; read/write
BLIT_CURSOR_BG_COLOR	equ	$1a	; read/write
BLIT_TILE_RAM_PTR	equ	$20	; 32 bit read only
BLIT_FG_COLOR_RAM_PTR	equ	$24	; 32 bit read only
BLIT_BG_COLOR_RAM_PTR	equ	$28	; 32 bit read only
BLIT_PIXEL_RAM_PTR	equ	$2C	; 32 bit read only

; blit specific commands
BLIT_CMD_DRAW_BLIT		equ	%00000001
BLIT_CMD_DECREASE_CURSOR_POS	equ	%10000000
BLIT_CMD_INCREASE_CURSOR_POS	equ	%10000001
BLIT_CMD_ACTIVATE_CURSOR	equ	%11000000
BLIT_CMD_DEACTIVATE_CURSOR	equ	%11000001
BLIT_CMD_PROCESS_CURSOR_STATE	equ	%11000010

; timer
TIMER		equ	$0b00
TIMER_SR	equ	TIMER
TIMER_CR	equ	TIMER+$01
TIMER0_BPM	equ	TIMER+$10
TIMER1_BPM	equ	TIMER+$12
TIMER2_BPM	equ	TIMER+$14
TIMER3_BPM	equ	TIMER+$16
TIMER4_BPM	equ	TIMER+$18
TIMER5_BPM	equ	TIMER+$1a
TIMER6_BPM	equ	TIMER+$1c
TIMER7_BPM	equ	TIMER+$1e

; sound / sid / analog / mixer
SND	equ	$0c00

SID0	equ	SND		; sid0 base
SID0F	equ	SID0+$00
SID0P	equ	SID0+$02
SID0VC	equ	SID0+$04
SID0AD	equ	SID0+$05
SID0SR	equ	SID0+$06
SID0V	equ	SID0+$1b

SID1	equ	SND+$20		; sid1 base
SID1F	equ	SID1+$00
SID1P	equ	SID1+$02
SID1VC	equ	SID1+$04
SID1AD	equ	SID1+$05
SID1SR	equ	SID1+$06
SID1V	equ	SID1+$1b

SID2	equ	SND+$40		; sid2 base
SID2F	equ	SID2+$00
SID2P	equ	SID2+$02
SID2VC	equ	SID2+$04
SID2AD	equ	SID2+$05
SID2SR	equ	SID2+$06
SID2V	equ	SID2+$1b

SID3	equ	SND+$60		; sid3 base
SID3F	equ	SID3+$00
SID3P	equ	SID3+$02
SID3VC	equ	SID3+$04
SID3AD	equ	SID3+$05
SID3SR	equ	SID3+$06
SID3V	equ	SID3+$1b

;ANA0	equ	SND+$04		; analog0 base
;ANA0P	equ	ANA0+$02

SNDM	equ	SND+$100	; mixer base
SNDM0L	equ	SNDM+$00
SNDM0R	equ	SNDM+$01
SNDM1L	equ	SNDM+$02
SNDM1R	equ	SNDM+$03
MXAN0L	equ	SNDM+$08
MXAN0R	equ	SNDM+$09
MXAN1L	equ	SNDM+$0a
MXAN1R	equ	SNDM+$0b
MXAN2L	equ	SNDM+$0c
MXAN2R	equ	SNDM+$0d
MXAN3L	equ	SNDM+$0e
MXAN3R	equ	SNDM+$0f

; cia
CIA	equ	$0e00		; CIA base
CIA_SR	equ	CIA		; status register
CIA_CR	equ	CIA+$01		; control register
CIA_KRD	equ	CIA+$02		; keyboard repeat delay in 10ms
CIA_KRS	equ	CIA+$03		; keyboard repeat speed in 10ms
CIA_AC	equ	CIA+$04		; ascii code
CIA_KSA	equ	CIA+$80		; start of key state array

CIA_CMD_GENERATE_EVENTS		equ	%00000001
CIA_CMD_CLEAR_EVENT_LIST	equ	%10000000

; ascii
ASCII_BACKSPACE		equ	$08
ASCII_LF		equ	$0a
ASCII_CR		equ	$0d
ASCII_CURSOR_DOWN	equ	$11
ASCII_CURSOR_RIGHT	equ	$1d
ASCII_CURSOR_UP		equ	$91
ASCII_CURSOR_LEFT	equ	$9d

; colors
C64_BLACK		equ	$f000
C64_WHITE		equ	$ffff
C64_RED			equ	$f733
C64_CYAN		equ	$f8cc
C64_PURPLE		equ	$f849
C64_GREEN		equ	$f6a5
C64_BLUE		equ	$f339
C64_YELLOW		equ	$fee8
C64_ORANGE		equ	$f853
C64_BROWN		equ	$f531
C64_LIGHTRED		equ	$fb77
C64_DARKGREY		equ	$f444
C64_GREY		equ	$f777
C64_LIGHTGREEN		equ	$fbfa
C64_LIGHTBLUE		equ	$f67d
C64_LIGHTGREY		equ	$faaa

; music notes index
N_C0_	equ	00*2
N_C0S	equ	01*2
N_D0_	equ	02*2
N_D0S	equ	03*2
N_E0_	equ	04*2
N_F0_	equ	05*2
N_F0S	equ	06*2
N_G0_	equ	07*2
N_G0S	equ	08*2
N_A0_	equ	09*2
N_A0S	equ	10*2
N_B0_	equ	11*2

N_C1_	equ	12*2
N_C1S	equ	13*2
N_D1_	equ	14*2
N_D1S	equ	15*2
N_E1_	equ	16*2
N_F1_	equ	17*2
N_F1S	equ	18*2
N_G1_	equ	19*2
N_G1S	equ	20*2
N_A1_	equ	21*2
N_A1S	equ	22*2
N_B1_	equ	23*2

N_C2_	equ	24*2
N_C2S	equ	25*2
N_D2_	equ	26*2
N_D2S	equ	27*2
N_E2_	equ	28*2
N_F2_	equ	29*2
N_F2S	equ	30*2
N_G2_	equ	31*2
N_G2S	equ	32*2
N_A2_	equ	33*2
N_A2S	equ	34*2
N_B2_	equ	35*2

N_C3_	equ	36*2
N_C3S	equ	37*2
N_D3_	equ	38*2
N_D3S	equ	39*2
N_E3_	equ	40*2
N_F3_	equ	41*2
N_F3S	equ	42*2
N_G3_	equ	43*2
N_G3S	equ	44*2
N_A3_	equ	45*2
N_A3S	equ	46*2
N_B3_	equ	47*2

N_C4_	equ	48*2
N_C4S	equ	49*2
N_D4_	equ	50*2
N_D4S	equ	51*2
N_E4_	equ	52*2
N_F4_	equ	53*2
N_F4S	equ	54*2
N_G4_	equ	55*2
N_G4S	equ	56*2
N_A4_	equ	57*2
N_A4S	equ	58*2
N_B4_	equ	59*2

N_C5_	equ	60*2
N_C5S	equ	61*2
N_D5_	equ	62*2
N_D5S	equ	63*2
N_E5_	equ	64*2
N_F5_	equ	65*2
N_F5S	equ	66*2
N_G5_	equ	67*2
N_G5S	equ	68*2
N_A5_	equ	69*2
N_A5S	equ	70*2
N_B5_	equ	71*2

N_C6_	equ	72*2
N_C6S	equ	73*2
N_D6_	equ	74*2
N_D6S	equ	75*2
N_E6_	equ	76*2
N_F6_	equ	77*2
N_F6S	equ	78*2
N_G6_	equ	79*2
N_G6S	equ	80*2
N_A6_	equ	81*2
N_A6S	equ	82*2
N_B6_	equ	83*2

N_C7_	equ	84*2
N_C7S	equ	85*2
N_D7_	equ	86*2
N_D7S	equ	87*2
N_E7_	equ	88*2
N_F7_	equ	89*2
N_F7S	equ	90*2
N_G7_	equ	91*2
N_G7S	equ	92*2
N_A7_	equ	93*2
N_A7S	equ	94*2
