/*
 * screeneditor.h
 * E64-ROM
 *
 * Copyright © 2022-2023 elmerucr. All rights reserved.
 */

#ifndef SCREENEDITOR_H
#define SCREENEDITOR_H

#include "kernel.h"

void se_add_top_row();
void se_add_bottom_row();

extern u8 old_cursor_position;

#endif
