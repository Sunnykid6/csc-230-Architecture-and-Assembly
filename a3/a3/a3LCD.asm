#define LCD_LIBONLY
.include "lcd.asm"

.cseg
	
	call lcd_init
	call init_strings
	call init_ptr1
	call init_ptr2

	
	ldi r16, 0x87
	sts ADCSRA, r16
	ldi r16, 0x40
	sts ADMUX, r16



loop:
	call lcd_clr		
	call display_string1	
	call display_string2	
	call copy_message1
	call copy_message2
	call display_string1
	call display_string2
	call move_ptr1
	call move_ptr2
	ldi r20, 0x40
	call delay
	rjmp loop


done:
	rjmp done



;---------------------------------------------------------------------------------------------------------------
;Beginning of all the subroutines for the loop above!
init_strings:
	push r16
	; copy strings from program memory to data memory
	ldi r16, high(msg1)		; this the destination
	push r16
	ldi r16, low(msg1)
	push r16
	ldi r16, high(msg1_p << 1) ; this is the source
	push r16
	ldi r16, low(msg1_p << 1)
	push r16
	call str_init			; copy from program to data
	pop r16					; remove the parameters from the stack
	pop r16
	pop r16
	pop r16

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
;---------------------------------------------------------------------------------------------------------------
; This subroutine sets the position the next
; character will be output on the lcd
;
; The first parameter pushed on the stack is the Y position
; 
; The second parameter pushed on the stack is the X position
; 
; This call moves the cursor to the top left (ie. 0,0)
display_string1:
	push r16

	call lcd_clr

	ldi r16, 0x00
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
	pop r16

	pop r16
	ret
;---------------------------------------------------------------------------------------------------------------
; This subroutine sets the position the next
; character will be output on the lcd
;
; The first parameter pushed on the stack is the Y position
; 
; The second parameter pushed on the stack is the X position
; 
; This call moves the cursor to the top left (ie. 0,0)
display_string2:
	push r17
	; Now move the cursor to the second line (ie. 0,1)
	ldi r17, 0x01
	push r17
	ldi r17, 0x00
	push r17
	call lcd_gotoxy
	pop r17
	pop r17

	; Now display msg1 on the second line
	ldi r17, high(line2)
	push r17
	ldi r17, low(line2)
	push r17
	call lcd_puts
	pop r17
	pop r17

	pop r17
	ret
;---------------------------------------------------------------------------------------------------------------
;Initialize the line 1 pointer to msg1
init_ptr1:
	push r16

	ldi r16, low(msg1)
	sts l1ptr, r16
	ldi r16, high(msg1)
	sts l1ptr+1, r16

	pop r16
	ret
;---------------------------------------------------------------------------------------------------------------
;Initialize the line 1 pointer to msg2
init_ptr2:
	push r16

	ldi r16, low(msg2)
	sts l2ptr, r16
	ldi r16, high(msg2)
	sts l2ptr + 1, r16

	pop r16
	ret
;---------------------------------------------------------------------------------------------------------------
;Copies msg1 into line 1
copy_message1:
	push XH
	push XL
	push YH
	push YL
	push r17
	push r18

	clr r17
	ldi r18, 0x00
	ldi XH, high(line1) ;set x to line 1
	ldi XL, low(line1)
	lds YL, l1ptr; set Y to point to what line 1 pointer is pointing to
	lds YH, l1ptr + 1

charCopy:
	ld r17, Y+;load whatever Y is pointing to into r17
	cpi r17, 0x00
	breq nullTermFound;if null terminator found, reset y pointer to msg1
	rjmp noNullTermFound;if not go to store value loop.

nulltermFound:
	ldi YH, high(msg1)
	ldi YL, low(msg1)
	ld r17, Y+;load the first character of message 2 into r17

noNullTermFound:
	st X+, r17;store r17 into x which is the line copy
	inc r18
	cpi r18, 16
	breq doneCharCopy
	rjmp charCopy

doneCharCopy:
	ldi r18, 0x00;setting the null terminator
	st X, r18

	pop r18
	pop r17
	pop YL
	pop YH
	pop XL
	pop XH

	ret
;---------------------------------------------------------------------------------------------------------------
;Copies msg1 into line 2
copy_message2:
	push XH
	push XL
	push YH
	push YL
	push r17
	push r18

	clr r17
	ldi r18, 0x00
	ldi XH, high(line2) ;set x to line 2
	ldi XL, low(line2)
	lds YL, l2ptr; set Y to point to what line 1 pointer is pointing to
	lds YH, l2ptr + 1

charCopy2:
	ld r17, Y+;load whatever Y is pointing to into r17
	cpi r17, 0x00
	breq nullTermFound2;if null terminator found, reset y pointer to msg1
	rjmp noNullTermFound2;if not go to store value loop.

nullTermFound2:
	ldi YH, high(msg2)
	ldi YL, low(msg2)
	ld r17, Y+;load the first character of message 2 into r17

noNullTermFound2:
	st X+, r17;store r17 into x which is the line copy
	inc r18
	cpi r18, 16
	breq doneCharCopy2
	rjmp charCopy2

doneCharCopy2:
	ldi r18, 0x00;setting the null terminator
	st X, r18

	pop r18
	pop r17
	pop YL
	pop YH
	pop XL
	pop XH

	ret
;---------------------------------------------------------------------------------------------------------------
;increments/moves the l1ptr one ahead
move_ptr1:

	push XH
	push XL
	push r17

	lds XL,l1ptr;setting X to point to what line 1 pointer is pointing to
	lds XH, l1ptr +1 
	adiw XH:XL, 1;increment the pointer by 1

	ld r17, X; load whatever is in X into r17
	cpi r17, 0
	breq nullTerm; if its the null term reinitialize the pointer reset the pointer to the beginning 
	rjmp noNullTerm; if not null term, store new X into line 1 pointer

nullTerm:
	call init_ptr1
	rjmp doneMove

noNullTerm:
	sts l1ptr, XL;store new X into line 1 pointer
	sts l1ptr + 1, XH
	rjmp doneMove

doneMove:
	pop r17
	pop XL
	pop XH

	ret
;---------------------------------------------------------------------------------------------------------------
;increments/moves the l1ptr one ahead
move_ptr2:

	push XH
	push XL
	push r17

	lds XL,l2ptr;setting X to point to what line 1 pointer is pointing to
	lds XH, l2ptr +1 
	adiw XH:XL, 1;increment the pointer by 1

	ld r17, X; load whatever is in X into r17
	cpi r17, 0
	breq nullTerm2; if its the null term reinitialize the pointer reset the pointer to the beginning 
	rjmp noNullTerm2; if not null term, store new X into line 1 pointer

nullTerm2:
	call init_ptr2
	rjmp doneMove2

noNullTerm2:
	sts l2ptr, XL;store new X into line 1 pointer
	sts l2ptr + 1, XH
	rjmp doneMove2

doneMove2:
	pop r17
	pop XL
	pop XH

	ret
;---------------------------------------------------------------------------------------------------------------
;
; delay
;
; set r20 before calling this function
; r20 = 0x40 is approximately 1 second delay
;
; this function uses registers:
;
;	r20
;	r21
;	r22
;
delay:	
del1:		nop
		ldi r21,0x07
del2:		nop
		ldi r22, 0x10
del3:	
		call check_button
		cpi r24, 2
		breq pauseScroll
		cpi r24, 1
		breq splitScroll1
		cpi r24, 8
		breq splitScroll2
		dec r22
		brne del3
		dec r21
		brne del2
		dec r20
		brne del1	
resumeScroll:	
		ret

;---------------------------------------------------------------------------------------------------------------
;Pauses the scrolling for both
;
pauseScroll:	
	call check_button
	cpi r24, 4
	breq resumeScroll
	rjmp pauseScroll

;---------------------------------------------------------------------------------------------------------------
;Pauses the scrolling for line1
;
pauseSplitScroll1:	
	call check_button
	cpi r24, 4
	breq resumeSplitScroll1
	rjmp pauseSplitScroll1


;---------------------------------------------------------------------------------------------------------------
;Only scrolls and shows first line
;
splitScroll1:
	call lcd_clr			
	call display_string1	
	call copy_message1
	call display_string1
	call move_ptr1
	ldi r20, 0x40
indel1:		nop
		ldi r21,0x07
indel2:		nop
		ldi r22, 0x10
indel3:	
		call check_button
		cpi r24, 2
		breq pauseSplitScroll1
		cpi r24, 1
		breq splitScroll1
		cpi r24, 8
		breq splitScroll2
		cpi r24, 16
		breq resumeDoubleScroll
		dec r22
		brne indel3
		dec r21
		brne indel2
		dec r20
		brne indel1	
resumeSplitScroll1:	
	rjmp splitScroll1

;---------------------------------------------------------------------------------------------------------------
;When select button hit, resume both scrolls
;
resumeDoubleScroll:
	rjmp resumeScroll


;---------------------------------------------------------------------------------------------------------------
;Only scrolls and shows second line
;
splitScroll2:
	call lcd_clr		
	call display_string2	
	call copy_message2
	call display_string2
	call move_ptr2
	ldi r20, 0x40
indelay1:		nop
		ldi r21,0x07
indelay2:		nop
		ldi r22, 0x10
indelay3:	
		call check_button
		cpi r24, 2
		breq pauseSplitScroll2
		cpi r24, 1
		breq splitScroll1
		cpi r24, 8
		breq splitScroll2
		cpi r24, 16
		breq resumeDoubleScroll
		dec r22
		brne indelay3
		dec r21
		brne indelay2
		dec r20
		brne indelay1	
resumeSplitScroll2:	
	rjmp splitScroll2

;---------------------------------------------------------------------------------------------------------------
;Pauses the scrolling for line2
;
pauseSplitScroll2:	
	call check_button
	cpi r24, 4
	breq resumeSplitScroll2
	rjmp pauseSplitScroll2

;---------------------------------------------------------------------------------------------------------------
; An improved version of the button test subroutine
;
; Returns in r24:
;	0 - no button pressed
;	1 - right button pressed
;	2 - up button pressed
;	4 - down button pressed
;	8 - left button pressed
;	16- select button pressed
;
; this function uses registers:
;	r24
;
; if you consider the word:
;	 value = (ADCH << 8) +  ADCL
; then:
;
; value > 0x3E8 - no button pressed
;
; Otherwise:
; value < 0x032 - right button pressed
; value < 0x0C3 - up button pressed
; value < 0x17C - down button pressed
; value < 0x22B - left button pressed
; value < 0x316 - select button pressed
; 
check_button:
	push r16
	push r17

	lds	r16, ADCSRA	
	ori r16, 0x40
	sts	ADCSRA, r16

wait:	
	lds r16, ADCSRA
	andi r16, 0x40
	brne wait

	lds r16, ADCL
	lds r17, ADCH

	clr r24
		cpi r17, 3
		breq checkNoPress
		cpi r17, 0
		breq checkUpRightPress
		cpi r17, 1
		breq checkDownPress

		

checkNoPress:
		cpi r16, 0xE8
		BRSH noButton
		rjmp select

checkUpRightPress:
		cpi r16, 0x33
		BRLO rightButton
		cpi r16, 0xC4
		BRLO upButton
		

checkDownPress:
		cpi r16, 0x7C
		BRSH leftButton
		rjmp downButton

noButton:
		ldi r24, 0
		rjmp skip

rightButton:
		ldi r24, 1
		rjmp skip

upButton:
		ldi r24, 2
		rjmp skip

downButton:
		ldi r24, 4
		rjmp skip

leftButton:
		ldi r24, 8
		rjmp skip

select:
		ldi r24, 16
		rjmp skip


skip:

	pop r17
	pop r16
	
	ret
;---------------------------------------------------------------------------------------------------------------
;End of Subroutines. Below is initializing the strings, string copy, and pointers
msg1_p:	.db "Vegeta, what does the scouter say about his power level? ", 0	
msg2_p: .db "Its over 9000! ", 0

.dseg


msg1:	.byte 200 
msg2:	.byte 200 

;Message copy
line1:	.byte 17 
line2:	.byte 17 

;Pointer to keep track of where we are in the string 
l1ptr:	.byte 2 
l2ptr:	.byte 2 