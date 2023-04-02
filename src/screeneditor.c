/*
 * screeneditor.c
 * E64-ROM
 *
 * Copyright © 2022-2023 elmerucr. All rights reserved.
 */

#include "screeneditor.h"
#include "blitter.h"

extern u8 current_blit;
u8 old_cursor_position;
