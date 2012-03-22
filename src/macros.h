/*
 * macros.h
 * This file is part of the set of functions to handle Dallas "One Wire"
 * protocol and devices.
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

#ifndef _MACROS_H_
#define _MACROS_H_


/* sfr_defs.h contains "#define _BV (bit) (1 <<(bit))" */
#define BIT(x) (1 << (x))


/* sets or clears more than one bit */
#define SETBITS(x,y)   ((x) |=   (y))
#define CLEARBITS(x,y) ((x) &= (~(y)))


/* sets or clears only one bit */
#define SETBIT(x,y)   SETBITS  ((x), (BIT((y))))
#define CLEARBIT(x,y) CLEARBITS((x), (BIT((y))))


/* check whether the bit is set BITSET or reset BITCLEAR
   similar macros bit_is_set and bit_is_clear contains sfr_defs.h
   returns zero or nonzero */
#define BITSET(x,y) ((x) & (BIT(y)))
#define BITCLEAR(x,y) !BITSET((x), (y))


/* returns zero or one
   after optimization no longer returns the value zero and one,
   only zero and nonzero */
#define BITVAL(x,y) (((x)>>(y)) & 1)


/* sets pin y of port x as input or output */
#define PIN_OUTPUT(x,y) SETBIT(_SFR_IO8(_SFR_IO_ADDR(x)-1), y)
#define PIN_INPUT(x,y)  CLEARBIT(_SFR_IO8(_SFR_IO_ADDR(x)-1), y)


/* sets more than one pin of port x as input or output */
#define PINS_OUTPUT(x,y) SETBITS(_SFR_IO8(_SFR_IO_ADDR(x)-1), y)
#define PINS_INPUT(x,y)  CLEARBITS(_SFR_IO8(_SFR_IO_ADDR(x)-1), y)


#define TRUE  1
#define FALSE 0


#define HI    1
#define LO    0

#endif /* _MACROS_H_ */

