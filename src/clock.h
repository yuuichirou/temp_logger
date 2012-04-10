/*
 * clock.h
 * This file is part of the temp-logger project.
 *
 * Copyright (C) 2012 Krzysztof Kozik
 *
 * This set is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307, USA.
 */

#ifndef _CLOCK_H_
#define _CLOCK_H_

#include <stdint.h>
#include "clock_config.h"

extern uint8_t              hour ;
extern uint8_t              minute ;
extern volatile uint8_t     second ;
extern volatile uint8_t     decsecond ;

enum T_SETTINGS { NO_CLOCK,
                  NO_PRECALER,
                  PRESCALER_8,
                  PRESCALER_64,
                  PRESCALER_256,
                  PRESCALER_1024,
                  EXT_CLOCK_FALING,
                  EXT_CLOCK_RISING } ;

#define T0_PERIOD               F_CPU/T0_PRESCALER/T0_FREQUENCY

void clock_timer_init (void) ;
void clock (void) ;

#endif /* _CLOCK_H_ */

