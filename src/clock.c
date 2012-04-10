/*
 * clock.c
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

#include <avr/io.h>
#include "clock.h"
#include "macros.h"
#include <avr/interrupt.h>

uint8_t                     hour ;
uint8_t                     minute ;
volatile uint8_t            second ;
volatile uint8_t            decsecond ;


void clock_timer_init (void)
{
  TCCR0 = PRESCALER_1024 ;
  TCNT0 = 256 - T0_PERIOD ;
  TIMSK |= _BV(TOIE0) ;
}

ISR (TIMER0_OVF_vect)
{
  TCNT0 = 256 - T0_PERIOD ;
  decsecond++ ;
  if (decsecond > 99)
  {
    second++ ;
    decsecond = 0 ;
  }
}

void clock(void)
{
  if (second > 59)
  {
    minute++ ;
    second = 0 ;
  }
  if (minute > 59)
  {
    hour++ ;
    minute = 0 ;
  }
  if (hour > 23)
  {
    /*day++ ;*/
    hour = 0 ;
  }
}

