#define LCD_LIBONLY
.include "lcd.asm"


.cseg

start:
    inc r16
    rjmp start