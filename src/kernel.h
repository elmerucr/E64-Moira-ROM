/*
 * kernel.h
 * E64-ROM
 *
 * Copyright © 2022-2023 elmerucr. All rights reserved.
 */

#ifndef	KERNEL_H
#define KERNEL_H

typedef	unsigned char	u8;
typedef	signed char	i8;
typedef	unsigned int	u16;
typedef	int		i16;
typedef unsigned long	u32;
typedef	signed long	i32;

#define	C64_BLACK	0xf000
#define	C64_WHITE	0xffff
#define	C64_RED		0xf733
#define	C64_CYAN	0xf8cc
#define	C64_PURPLE	0xf849
#define	C64_GREEN	0xf6a5
#define	C64_BLUE	0xf339
#define	C64_YELLOW	0xfee8
#define	C64_ORANGE	0xf853
#define	C64_BROWN	0xf531
#define	C64_LIGHTRED	0xfb77
#define	C64_DARKGREY	0xf444
#define	C64_GREY	0xf777
#define	C64_LIGHTGREEN	0xfbfa
#define	C64_LIGHTBLUE	0xf67d
#define	C64_LIGHTGREY	0xfaaa

#define	E64_BLUE_01	0xf113
#define	E64_BLUE_03	0xf339
#define	E64_BLUE_08	0xfbbf
#define	E64_BLUE_09	0xfddf

#define	ASCII_CURSOR_RIGHT	0x1d

void	pokeb(u32 address, u8 byte);
u8	peekb(u32 address);
void	pokew(u32 address, u16 word);
u16	peekw(u32 address);
void	pokel(u32 address, u32 longword);
u32	peekl(u32 address);

void	init_kernel();
u16	get_interrupt_mask();
void	set_interrupt_mask(u16 value);

#endif
