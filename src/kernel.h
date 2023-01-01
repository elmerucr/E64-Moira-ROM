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
