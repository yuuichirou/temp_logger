#include <avr/io.h>
#include "macros.h"
#include "lcd/src/lcd.h"
#include "one_wire/src/one_wire.h"


uint16_t lcd_status ;


int main (void)
{
  lcd_init () ;
  lcd_goto_xy (3, 1) ;
  lcd_print ("TEMPERATURE") ;
  lcd_goto_xy (6, 2) ;
  lcd_print ("LOGGER") ;
  _delay_ms (2000) ;
  lcd_clear_display () ;

  while (1)
  {
    
  }
  return 0 ;
}

