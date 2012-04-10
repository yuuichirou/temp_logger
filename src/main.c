/*
 * main.c
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
#include "macros.h"
#include "lcd/src/lcd.h"
#include "one_wire/src/one_wire.h"
#include <avr/interrupt.h>
#include "clock.h"
#include "config.h"
#include <string.h>


uint16_t lcd_status ;
char buf[16] ;


int main (void)
{
  lcd_init () ;
  lcd_goto_xy (3, 1) ;
  lcd_print ("TEMPERATURE") ;
  lcd_goto_xy (6, 2) ;
  lcd_print ("LOGGER") ;
  _delay_ms (2000) ;
  lcd_clear_display () ;
  clock_timer_init () ; sei () ;
  while (1)
  {
    clock () ;
    lcd_clear_display () ;
    lcd_goto_xy (CLOCK_X_POS,CLOCK_Y_POS) ;
    strcpy (buf, "") ;
    time_to_string_g (buf) ;
    lcd_print (buf) ;
    _delay_ms(100);
  }
  return 0 ;
}

