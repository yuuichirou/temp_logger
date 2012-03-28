#
#  makefile
#  This file is part of the temp-logger project.
#
#  Copyright (C) 2012 Krzysztof Kozik
#
#  This set is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330,
#  Boston, MA 02111-1307, USA.
#

TARGET          = termometr

#------------------------- Hardware options -----------------------------------
export TARGET_MCU      = atmega8
export F_CPU           = 11059200

#------------------------- Sources --------------------------------------------
sources         = src/main.c

# put object files in place where are source files
objects = $(subst .c,.o,$(sources))

#------------------------- Libraries ------------------------------------------
libraries       = 

#------------------------- C Preprocessor options -----------------------------
CPPFLAGS        = -DF_CPU=$(F_CPU)UL -std=gnu89 -Wextra -pedantic
CPPFLAGS       += -Wall -Wunused-macros -Wsystem-headers

#------------------------- C Compiler options ---------------------------------
export OPT             = 1
CFLAGS          = -gdwarf-2 -O$(OPT) -mmcu=$(TARGET_MCU) $(CPPFLAGS)
CFLAGS         += -funsigned-char -funsigned-bitfields
CFLAGS         += -fshort-enums -fpack-struct -mshort-calls
CFLAGS         += -Wall -Wundef -Wsign-compare -Wstrict-prototypes
CFLAGS         += -Wmissing-parameter-type -Wmissing-prototypes
CFLAGS         += -Wmissing-declarations -Winline -Wunreachable-code

#------------------------- Linker options -------------------------------------
LDFLAGS         = -Wl,-Map=$@.map,--cref $(addprefix -L,$(dir $(libraries)))
#_libraries     += -lm
_libraries     += $(addprefix -l,$(basename $(patsubst lib%,%,$(notdir $(libraries)))))

#------------------------- Output files options -------------------------------
FLASHFLAGS      = --only-section=.text --only-section=.data
EEPROMFLAGS     = --only-section=.eeprom
EEPROMFLAGS    += --change-section-lma .eeprom=0 --no-change-warnings
EEPROMFLAGS    += --set-section-flags .eeprom="alloc,load"

#------------------------- Programming Options (avrdude) ----------------------
AVRDUDE_PROGRAMMER   = pony-stk200
AVRDUDEFLAGS         = -p $(TARGET_MCU) -c $(AVRDUDE_PROGRAMMER)
AVRDUDEFLAGS        += -e -E noreset -P /dev/parport0 -y
AVRDUDE_WRITE_FLASH  = -U flash:w:flash.hex:i
AVRDUDE_WRITE_EEPROM = -U eeprom:w:eeprom.hex:i

#------------------------- Programs -------------------------------------------
SHELL           = /bin/sh
CC              = avr-gcc
LD              = avr-ld
OBJCOPY         = avr-objcopy
AVRDUDE         = avrdude
SIZE            = avr-size

#------------------------- Rules ----------------------------------------------

# do not show commands
.SILENT:

.PHONY: no_target
no_target:
	echo "Usage: make <target>\nfor more info type make help"


HELP_ECHO = "Usage: make <target>\
\ntarget:\
\n  help                     Show this screen\
\n  all                      Compile and link project\
\n  compile                  Compile source files\
\n  link                     Compile if necessary and link object files\
\n  program                  Make project and program microcontroller\
\n  clean                    Delete all files created by building project\
\n  flash                    Prepare flash memory content\
\n  eeprom                   Prepare eeprom memory content\
\n  upload                   Only program microcontroler with flash.hex\
\n                           and eeprom.hex\
\n  cleanall                 Delete all files created by building project,\
\n                           dependency and debug files\
\n  toolsversion             Show tools version numbers\
\n  savetoolsversion         Dump tools version numbers to file 'toolsversion'\
\n  debug                    Create debug files by objdump, nm, size, readelf\
\n  cleandebug               Delete all files created by debugging rule\
\n  lib                      Create libraries\
\n  cleanlibs                Delete all libraries used by this makefile (use\
\n                           only when you want rebuild libraries)\
\n"

.PHONY: help
help:
	echo $(HELP_ECHO)


.PHONY: compile
compile: $(objects)

%.o: %.c makefile
	echo "compiling a file: $@"
	$(CC) -c $(CFLAGS) $< -o $@


.PHONY: lib
lib: $(libraries)
	
%.a:
	$(MAKE) --directory=$(dir $@) lib


.PHONY: link
link: lib $(TARGET).elf

$(TARGET).elf: $(objects)
	echo "linking files: $^"
	$(CC) $(CFLAGS) $(LDFLAGS) $^ $(_libraries) -o $@
	$(SIZE) --mcu=$(TARGET_MCU) --format=avr $@


.PHONY: flash
flash: flash.hex

flash.hex: $(TARGET).elf makefile
	echo "preparing flash memory content"
	$(OBJCOPY) -O ihex $(FLASHFLAGS) $< $@

.PHONY: eeprom
eeprom: eeprom.hex

eeprom.hex: $(TARGET).elf makefile
	echo "preparing eeprom memory content"
	$(OBJCOPY) -O ihex  $(EEPROMFLAGS) $< $@


.PHONY: all
all: compile lib link flash eeprom


.PHONY: program
program: upload

.PHONY: upload
upload: flash eeprom
	echo "programming $(TARGET_MCU) with flash.hex and eeprom.hex"
	$(AVRDUDE) $(AVRDUDEFLAGS) \
	$(AVRDUDE_WRITE_FLASH) $(AVRDUDE_WRITE_EEPROM)


ifeq ($(filter-out no_target help %toolsversion clean%,$(MAKECMDGOALS)),)
else
-include $(subst .c,.d,$(sources))
endif

%.d: %.c
	echo "generating dependencies for file: $<"
	set -e; rm -f $@;\
	$(CC) -MM $(CFLAGS) $< -MF $@.$$$$;\
	sed 's|$(notdir $*).o|$*.o $*.d|' <$@.$$$$ >$@;\
	rm -f $@.$$$$


.PHONY: toolsversion
toolsversion:
	echo ------------------------------
	$(CC) --version
	echo ------------------------------
	$(LD) --version
	echo ------------------------------
	$(OBJCOPY) --version
	echo ------------------------------
	$(AVRDUDE) 2>&1 | tail -n 1
	echo ------------------------------
	LANG=EN make --version
	echo ------------------------------
	echo binutils-avr package `dpkg -p binutils-avr | grep Version`
	echo ------------------------------

.PHONY: savetoolsversion
savetoolsversion:
	rm -f toolsversion
	$(CC) --version         | head -n 1     >> toolsversion
	$(LD) --version         | head -n 1     >> toolsversion
	$(OBJCOPY) --version    | head -n 1     >> toolsversion
	$(AVRDUDE) 2>&1         | tail -n 1     >> toolsversion
	LANG=EN make --version  | head -n 1     >> toolsversion
	echo binutils-avr package `dpkg -p binutils-avr | grep Version`\
                                                >> toolsversion


.PHONY: debug
debug: $(addsuffix .debug, $(objects) $(TARGET).elf)

%.debug: % makefile
	echo "creating debug files: $@.*"
#	avr-objdump -W -w -z    $< > $@.objdump_W
#	avr-objdump -t -w -z    $< > $@.objdump_t
#	avr-objdump -d -w -z    $< > $@.objdump_d
	avr-objdump -S -w -z    $< > $@.objdump_S
#	avr-objdump -s -w -z    $< > $@.objdump_s
#	avr-objdump -h -w -z    $< > $@.objdump_h
	avr-nm -a -f sysv -l    $< > $@.nm_a_fsysv
#	avr-nm -a -S -l         $< > $@.nm_a_S
	avr-size -A --common    $< > $@.size_A
#	avr-size -B --common -t $< > $@.size_B_t
#	avr-readelf -w -W -a    $< > $@.readelf


.PHONY: clean
clean:
	echo "removing files needed to complete project"
	rm -rf src/*.o
	rm -f *.elf *.hex *.bin *.map *.o


.PHONY: cleandep
cleandep:
	echo "removing dependency files"
	rm -f $(subst .c,.d,$(sources))


directories = $(dir $(objects) $(TARGET).elf)

.PHONY: cleandebug
cleandebug:
	echo "removing all files created by debugging rule"
	$(foreach directory,$(directories),rm -f $(directory)*.debug.*;)


.PHONY: cleanall
cleanall: cleanall_echo clean cleandebug cleandep

.PHONY: cleanall_echo
cleanall_echo:
	echo "removing all files that can be regenerated by make"


.PHONY: cleanlibs
cleanlibs:
	echo "removing all libraries"
	rm -f $(libraries)
