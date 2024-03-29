/*
 * cia.h
 * E64-ROM
 *
 * Copyright © 2022-2023 elmerucr. All rights reserved.
 */

#ifndef	CIA_H
#define	CIA_H

#include "kernel.h"

#define	CIA		((struct cia_ic *)0x00000a00)
#define CIA_KEYSTATES	((u8 *)0x00000a80)

#define CIA_KEY_EMPTY	0x00
#define CIA_KEY_ESCAPE	0x01
#define CIA_KEY_F1	0x02
// etc...
//

#define	CIA_CMD_GENERATE_EVENTS		0x01
#define	CIA_CMD_CLEAR_EVENT_LIST	0x80

struct cia_ic {
	u8 status_register;
	u8 control_register;
	u8 keyboard_repeat_delay;
	u8 keyboard_repeat_speed;
	u8 next_char;
};

#endif
