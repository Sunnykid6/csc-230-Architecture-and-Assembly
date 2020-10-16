;
; a2q4.asm
;
; Fix the button subroutine program so that it returns
; a different value for each button
;
		; initialize the Analog to Digital conversion

		ldi r16, 0x87
		sts ADCSRA, r16
		ldi r16, 0x40
		sts ADMUX, r16

		; initialize PORTB and PORTL for ouput
		ldi	r16, 0xFF
		out DDRB,r16
		sts DDRL,r16

		clr r0
		call display
lp:
		call check_button
		tst r24
		breq lp
		mov	r0, r24

		call display
		ldi r20, 99
		call delay
		ldi r20, 0
		mov r0, r20
		call display
		rjmp lp

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

		; put your new logic here:
		clr r24
		cpi r17, 0x03
		breq checkNoPress
return:	cpi r17, 0x00
		breq checkUpRightPress
		cpi r17, 0x01
		breq checkDownPress
		cpi r17, 0x02
		breq checkLeftPress
		cpi r17, 0x03
		breq checkSelectPress
		

checkNoPress:
		cpi r16, 0xE8
		BRSH noButton
		rjmp return
		

checkUpRightPress:
		cpi r16, 0x33
		BRLO rightButton
		cpi r16, 0xC4
		BRLO upButton
		
checkDownPress:
		cpi r16, 0x7D
		BRLO downButton
		

checkLeftPress:
		cpi r16, 0x2C
		BRLO leftButton

checkSelectPress:
		cpi r16, 0x17
		BRLO select

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
		ldi r24, 0x10
		rjmp skip


skip:
		ret

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
		ldi r21,0xFF
del2:		nop
		ldi r22, 0xFF
del3:		nop
		dec r22
		brne del3
		dec r21
		brne del2
		dec r20
		brne del1	
		ret

;
; display
; 
; display the value in r0 on the 6 bit LED strip
;
; registers used:
;	r0 - value to display
;
display:
		CLR r18
		CLR r19
		mov r23, r0
		; copy your code from a2q2.asm here
		ANDI r23, 0b00000001
		CPI r23, 0b00000001
		BREQ number1
back:	mov r23, r0
		ANDI r23, 0b00000010
		CPI r23, 0b00000010
		BREQ number2
back2:	mov r23, r0
		ANDI r23, 0b00000100
		CPI r23, 0b00000100
		BREQ number4
back3:	mov r23, r0
		ANDI r23, 0b00001000
		CPI r23, 0b00001000
		BREQ number8
back4:	mov r23, r0
		ANDI r23, 0b00010000
		CPI r23, 0b00010000
		BREQ number16 
back5:	mov r23, r0
		ANDI r23, 0b00100000
		CPI r23, 0b00100000
		BREQ number32
		rjmp lights

number1:
	ORI r18, 0b10000000
	rjmp back

number2:
	ORI r18, 0b00100000
	rjmp back2

number4:
	ORI r18, 0b00001000
	rjmp back3

number8:
	ORI r18, 0b00000010
	rjmp back4

number16:
	ORI r19, 0b00001000
	rjmp back5

number32:
	ORI r19, 0b00000010
	rjmp lights

lights:
	;mov r16, r17
	sts PORTL, r18
	;mov r16, r18
	out PORTB, r19
	clr r18
	clr r19

		ret

