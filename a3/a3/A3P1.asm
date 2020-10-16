/*
 * AsmFile1.asm
 *
 *  Created: 11/16/2018 9:48:38 AM
 *   Author: trave
 */ 
 #define LCD_LIBONLY
 .include "lcd.asm"
 .cseg

 call lcd_init
 call lcd_clr
 call init_strings
 call init_ptrs
 ;call load_line1
 call load_line2
 call display_strings

; loop:
	; lcd_clr
	;call load_line
	
	 ;jmp loop

 done: jmp done
init_strings:
	push r16
	; copy strings from program memory to data memory
	/*ldi r16, high(msg1)		; address of the destination string in data memory
	push r16
	ldi r16, low(msg1)
	push r16
	ldi r16, high(msg1_p << 1) ; address the source string in program memory
	push r16
	ldi r16, low(msg1_p << 1)
	push r16
	call str_init			; copy from program to data
	pop r16					; remove the parameters from the stack
	pop r16
	pop r16
	pop r16*/

	ldi r16, high(msg2)
	push r16
	ldi r16, low(msg2)
	push r16
	ldi r16, high(msg2_p << 1)
	push r16
	ldi r16, low(msg2_p << 1)
	push r16
	call str_init
	pop r16
	pop r16
	pop r16
	pop r16

	pop r16
	ret
/*load_line1:

	push r16
	push r17
	push ZH
	push ZL
	push XH
	push XL
	
	ldi ZL, low(line1)
	ldi ZH, high(line1)
	
	lds XL, l1ptr
	lds XH, l1ptr+1

	ldi r17, 16
	store1:
	ld r16, X+
		st Z+, r16
		dec r17
		cpi r17,0
		brne store1
		ldi r16, 0
		st X+, r16
	pop XL
	pop XH
	pop ZL
	pop ZH
	pop r17
	pop r16	
	
	ret*/

load_line2:
	push r16
	push r17
	push ZH
	push ZL
	push XH
	push XL

	ldi ZL , low(line2)
	ldi ZH, high(line2)
	
	lds XL, l2ptr
	lds XH, l2ptr+1

	ldi r17, 16
store2:
	ld r16, X+
		st Z+, r16
		dec r17
		cpi r17,0
		brne store2
		ldi r16, 0
		st X, r16

	pop XL
	pop XH
	pop ZL
	pop ZH
	pop r17
	pop r16	
	
	ret

init_ptrs:
	push r16
	
	ldi r16, low(msg1)
	sts l1ptr, r16
	ldi r16, high(msg1)
	sts l1ptr+1, r16

	ldi r16, low(msg2)
	sts l2ptr, r16
	ldi r16, high(msg2)
	sts l2ptr+1, r16

	pop r16
	ret
clear_line:
	
	ret
delay:
	ret
copy_ptr1:
	ret
display:
	ret
move_pointers:
	ret

display_strings:

	; This subroutine sets the position the next
	; character will be on the lcd
	;
	; The first parameter pushed on the stack is the Y (row) position
	; 
	; The second parameter pushed on the stack is the X (column) position
	; 
	; This call moves the cursor to the top left corner (ie. 0,0)
	; subroutines used are defined in lcd.asm in the following lines:
	; The string to be displayed must be stored in the data memory
	; - lcd_clr at line 661
	; - lcd_gotoxy at line 589
	; - lcd_puts at line 538
	push r16

	call lcd_clr

/*	ldi r16, 0x00
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display msg1 on the first line
	ldi r16, high(line1)
	push r16
	ldi r16, low(line1)
	push r16
	call lcd_puts
	pop r16
	pop r16*/

	; Now move the cursor to the second line (ie. 0,1)
	ldi r16, 0x01
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display msg1 on the second line
	ldi r16, high(line2)
	push r16
	ldi r16, low(line2)
	push r16
	call lcd_puts
	pop r16
	pop r16

	pop r16
	ret



msg1_p: .db "this is a message", 0
msg2_p: .db "different message", 0

.dseg 

 msg_1: .byte 200
 msg2: .byte 200
 
line1: .byte 17
line2: .byte 17 ; one byte for each char plus one for the null char at end of string?

l1ptr: .byte 2 
l2ptr: .byte 2