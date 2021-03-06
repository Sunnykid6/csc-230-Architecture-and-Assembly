; Student: Camille Janicki
; a3.asm
; This program takes two messages from program to data memory and displays them on the LCD screen.
; For part 2 of the assignment, the up botton pauses the scrolling, the bottom button resumes scrolling,
; the right button increases scrolling and the left button decreases scrolling.

#define LCD_LIBONLY
.include "lcd.asm"


.cseg

	;Definitions for using the Analog to Digital Conversion
	ldi r16, 0x87
	sts ADCSRA, r16
	ldi r16, 0x40 
	sts ADMUX, r16


	call lcd_init			; call lcd_init to Initialize the LCD
	call init_strings		; copy string from program to data memory

	call init_pointer1		; Set pointer 1 to point at the start of the display string
	call init_pointer2		; Set pointer 2 to point at the start of the display string
	ldi r20, 0x40			; Initializing scroll_speed global variable
	sts scroll_speed, r20	; Setting the global variable for scroll speed


lp:
	call clear_buffers			; Loads zeros into the buffers to clear lcd screen
	call display_buffers		; Displays what is in the buffers onto the lcd screen
	call fill_buffers			; Fills buffers with message 1 and message 2
	call display_buffers		; Displays what is in the buffers onto the lcd screen
	call mov_pointers			; Moves pointers in message 1 and message 2 to simulate scrolling
	call delay					

	jmp lp

done: jmp done

; init_strings subroutine
; Copies msg1 and msg2 from program to data memory
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

; init_pointer1 subroutine
; Sets line1ptr to point at the start of the display string
init_pointer1:

	push XH
	push XL
	push r17

	ldi	XH, high(l1ptr)		;Setting X to line1ptr
	ldi XL, low(l1ptr)

	;storing in little endian
	ldi r17, low(msg1)	;putting low byte address of msg1 in l1ptr	
	st X+, r17
	ldi r17, high(msg1)	;putting the high byte address of msg1 in l1ptr
	st X, r17 

	pop r17
	pop XL
	pop XH

	ret

; init_pointer2	subroutine
; Sets line2ptr to point at the start of the display string
init_pointer2:

	push XH
	push XL
	push r17

	ldi	XH, high(l2ptr)		;Setting X to line2ptr
	ldi XL, low(l2ptr)
	
	;storing in little endian
	ldi r17, low(msg2)	;putting low byte address of msg2 in l2ptr	
	st X+, r17
	ldi r17, high(msg2)	;putting the high byte address of msg2 in l2ptr
	st X, r17 

	pop r17
	pop XL
	pop XH

	ret

; display_buffers subroutine
display_buffers:

	; This subroutine sets the position the next
	; character will be output on the lcd
	;
	; The first parameter pushed on the stack is the Y position
	; 
	; The second parameter pushed on the stack is the X position
	; 
	; This call moves the cursor to the top left (ie. 0,0)

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

; clear_buffers subroutine
; This subroutine loads zeros into the buffers
clear_buffers:
	push XH
	push XL
	push YH
	push YL
	push r16
	push r17 ;counter

	ldi r16, 0x00
	ldi r17, 0x00

	ldi XH, high(line1)	;Pointer to line1
	ldi XL, low(line1)

	ldi YH, high(line2)	;Pointer to line2
	ldi YL, low(line2)

;Loop 17 times to load 17 zeros into both line1 and line2
buff_lp:
	ld r16, X+	
	ld r16, Y+
	
	inc r17
	cpi r17, 0x11
	brne buff_lp	


	pop r17
	pop r16
	pop YL
	pop YH
	pop XL
	pop XH
	ret

	

; fill_buffers subroutine
; Copies msg1 and msg2 into line1 and line2 by using l1ptr and l2ptr
fill_buffers:

	push XL
	push XH
	push YL
	push YH
	push ZL
	push ZH
	push r17
	push r18

	clr r17
	clr r18
	ldi r18, 0x00	;counter 

;First Line
	ldi	ZH, high(line1)		;Setting Z to line1
	ldi ZL, low(line1)

	; Getting what is contained in l1ptr
	lds YL, l1ptr		;Setting the Y pointer to what l1ptr is pointing to (First byte of msg1)
	lds YH, l1ptr+1

buffer_lp1:
	ld r17, Y+			;Loading what Y is pointing to into r17 (byte of msg1)
	cpi r17, 0x00	
	brne next1			;Breaks if null terminator is not reached

	;wrap
	ldi YH, high(msg1)	;Re-initializing Y pointer
	ldi YL, low(msg1)
	ld r17, Y+
	
next1:	
	st Z+, r17			;Storing the char from msg1 into line1
	inc r18
	cpi r18, 16
	brne buffer_lp1

	
	ldi r18, 0x00
	st Z, r18			;Setting the null terminator


;Second Line
	ldi	ZH, high(line2)		;Setting Z to line2
	ldi ZL, low(line2)

	; Getting what is contained in l2ptr
	lds YL, l2ptr		;Setting the Y pointer to what l2ptr is pointing to (First byte of msg2)
	lds YH, l2ptr+1

buffer_lp2:
	ld r17, Y+			;Loading what Y is pointing to into r17 (byte of msg2)
	cpi r17, 0x00	
	brne next2			;Breaks if null terminator is not reached

	;wrap
	ldi YH, high(msg2)	;Re-initializing Y pointer
	ldi YL, low(msg2)
	ld r17, Y+
	
next2:	
	st Z+, r17			;Storing the char from msg2 into line2
	inc r18
	cpi r18, 16
	brne buffer_lp2
	
	ldi r18, 0x00
	st Z, r18		;Setting the null terminator


	pop r18
	pop r17
	pop ZH
	pop ZL
	pop YH
	pop YL
	pop XH
	pop XL
	ret

; mov_pointers subroutine
; Moving l1ptr and l2ptr through msg1 and msg2 to imitate "scrolling"
mov_pointers:

	push ZH
	push ZL
	push r16

;First Line

	; Getting what is contained in l1ptr
	lds ZL, l1ptr		;Setting the Z pointer to what l1ptr is pointing to (First byte of msg1)
	lds ZH, l1ptr+1

	adiw ZH:ZL, 0x01	;Incrementing the Z pointer (by 1) through msg1

	ld r16, Z
	cpi r16, 0x00	
	brne normal			;Breaks if null terminator is not reached

	ldi	ZH, high(l1ptr)		;Re-initializing Z pointer
	ldi ZL, low(l1ptr)

	;storing in little endian
	ldi r16, low(msg1)	;putting low byte address of msg1 in l1ptr	
	st Z+, r16
	ldi r16, high(msg1)	;putting the high byte address of msg1 in l1ptr
	st Z, r16 
	jmp finish1

normal:
	sts l1ptr, ZL		;Storing new address of msg1 in l1ptr
	sts l1ptr+1, ZH

finish1:

;Second line

	; Getting what is contained in l2ptr
	lds ZL, l2ptr		;Setting the Z pointer to what l2ptr is pointing to (First byte of msg2)
	lds ZH, l2ptr+1

	adiw ZH:ZL, 0x01	;Incrementing the Z pointer (by 1) through msg2

	ld r16, Z
	cpi r16, 0x00		
	brne normal2		;Breaks if null terminator is not reached

	ldi	ZH, high(l2ptr)		;Re-initializing Z pointer
	ldi ZL, low(l2ptr)

;storing in little endian
	ldi r16, low(msg2)	;putting low byte address of msg2 in l2ptr	
	st Z+, r16
	ldi r16, high(msg2)	;putting the high byte address of msg2 in l2ptr
	st Z, r16 
	jmp finish2

normal2:
	sts l2ptr, ZL		;Storing new address of msg2 in l2ptr
	sts l2ptr+1, ZH

finish2:

	pop r16
	pop ZL
	pop ZH

	ret


; delay subroutine
delay:
	push r16
	push r17	 
	push r20
	push r21
	push r22
	push XH
	push XL


	lds r20, scroll_speed	;initializing r20 with global variable

del1:	nop
		ldi r21,0x7

del2:	nop
		ldi r22, 0x10
del3:
		call check_button		
		call button_react		;Reacting to a button press
		
		
		dec r22
		brne del3
		dec r21
		brne del2
		dec r20
		brne del1

	pop XL
	pop XH
	pop r22
	pop r21
	pop r20
	pop r17
	pop r16
			
		ret

;button_react subroutine
;Reacts to button presses 
button_react:

		push r16
		push r17

		; Junmping to different labels depending on what button is being pressed
		cpi r24, 1
		breq right
		cpi r24, 2
		breq uppushed
		cpi r24, 8
		breq left
		; No buttons pressed
		jmp finish_react

	

uppushed:
	call check_button
	cpi r24, 4
	breq finish_react	;the down button has been pressed
	jmp uppushed		;infinite loop until down is pressed


right:	
	lds r16, scroll_speed		;decreasing scroll_speed global variable to increase the speed
	ldi r17, 0x20
	sub r16, r17
	brcs right_max				;branching if carry flag is set
	jmp check_right

right_max:
	ldi r16, 1				;To prevent int overflow
	jmp check_right

check_right:
	call check_button		;Check that the right button has been released
	cpi r24, 0x00
	breq cont_right
	jmp check_right

cont_right:
	sts scroll_speed, r16
	jmp finish_react


left:
	lds r16, scroll_speed		;increasing scroll_speed global variable to decrease speed
	ldi r17, 0x20
	add r16, r17
	brcs left_max				;branching if carry flag is set
	jmp check_left

left_max:
	ldi r16, 0xFF			;To prevent int overflow
	jmp check_left
	
check_left:
	call check_button		;Check that the left button has been released
	cpi r24, 0x00
	breq cont_left
	jmp check_left		

cont_left:
	sts scroll_speed, r16	
	jmp finish_react


finish_react:

		pop r17
		pop r16
		ret
;
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
;	r16
;	r17
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
		
		; start a2d
		lds	r16, ADCSRA	
		ori r16, 0x40
		sts	ADCSRA, r16

		; wait for it to complete
wait:	lds r16, ADCSRA
		andi r16, 0x40
		brne wait

		; read the value
		lds r16, ADCL
		lds r17, ADCH

		clr r24
		cpi r17, 3			;  if > 0x3E8, no button pressed 
		brne bsk1		    ;  
		cpi r16, 0xE8		; 
		brsh bsk_done		; 
bsk1:	tst r17				; if ADCH is 0, might be right or up  
		brne bsk2			; 
		cpi r16, 0x32		; < 0x32 is right
		brsh bsk3
		ldi r24, 0x01		; right button
		rjmp bsk_done
bsk3:	cpi r16, 0xC3		
		brsh bsk4	
		ldi r24, 0x02		; up			
		rjmp bsk_done
bsk4:	ldi r24, 0x04		; down (can happen in two tests)
		rjmp bsk_done
bsk2:	cpi r17, 0x01		; could be up,down, left or select
		brne bsk5
		cpi r16, 0x7c		; 
		brsh bsk7
		ldi r24, 0x04		; other possiblity for down
		rjmp bsk_done
bsk7:	ldi r24, 0x08		; left
		rjmp bsk_done
bsk5:	cpi r17, 0x02
		brne bsk6
		cpi r16, 0x2b
		brsh bsk6
		ldi r24, 0x08
		rjmp bsk_done
bsk6:	ldi r24, 0x10
bsk_done:
		pop r17
		pop r16
		ret

; These are in program memory 
msg1_p: .db "Hello there, looping?  ", 0
msg2_p: .db "Second Line  ", 0 

.dseg 

scroll_speed: .byte 1
; 
; The program copies the strings from program memory 
; into data memory. 
; l1ptr and l2ptr index into these strings 
; 
msg1:	.byte 200 
msg2:	.byte 200 
; These strings contain the 16 characters to be displayed on the LCD
; Each time through the loop, the pointers l1ptr and l2ptr are incremented
; and then 16 characters are copied into these memory locations
line1:	.byte 17 
line2:	.byte 17 
; These keep track of where in the string each line currently is
l1ptr:	.byte 2 
l2ptr:	.byte 2 