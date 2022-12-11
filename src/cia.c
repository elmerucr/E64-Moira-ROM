#include "cia.h"

void cia_init_keyboard()
{
	CIA->control_register = CIA_CMD_CLEAR_EVENT_LIST;
	CIA->control_register = CIA_CMD_GENERATE_EVENTS;
	CIA->keyboard_repeat_delay = 50;	// 50 * 10ms = 0.5s keyboard repeat delay
	CIA->keyboard_repeat_speed = 5;		// 5 * 10ms = 50ms repeat speed
}
