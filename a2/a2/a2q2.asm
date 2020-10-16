;
; a2q2.asm
;
;
; Turn the code you wrote in a2q1.asm into a subroutine
; and then use that subroutine with the delay subroutine
; to have the LEDs count up in binary.

		ldi r16, 0xFF
		out DDRB, r16		; PORTB all output
		sts DDRL, r16		; PORTL all output

; Your code here
; Be sure that your code is an infite loop
		
		clr r17
		clr r18
start:	
		ldi r16, 0x00
		mov r0, r16
		ldi r19, 0x3F

loop:
		ldi r20, 0x40
		call display
		call delay
		cp r0, r19
		breq start
		inc r0
		mov r16, r0
		rjmp loop

done:		jmp done	; if you get here, you're doing it wrong

;
; display
; 
; display the value in r0 on the 6 bit LED strip
;
; registers used:
;	r0 - value to display
;
display:
		ANDI r16, 0b00000001
		CPI r16, 0b00000001
		BREQ number1
back:	mov r16, r0
		ANDI r16, 0b00000010
		CPI r16, 0b00000010
		BREQ number2
back2:	mov r16, r0
		ANDI r16, 0b00000100
		CPI r16, 0b00000100
		BREQ number4
back3:	mov r16, r0
		ANDI r16, 0b00001000
		CPI r16, 0b00001000
		BREQ number8
back4:	mov r16, r0
		ANDI r16, 0b00010000
		CPI r16, 0b00010000
		BREQ number16 
back5:	mov r16, r0
		ANDI r16, 0b00100000
		CPI r16, 0b00100000
		BREQ number32
		rjmp lights

number1:
	ORI r17, 0b10000000
	rjmp back

number2:
	ORI r17, 0b00100000
	rjmp back2

number4:
	ORI r17, 0b00001000
	rjmp back3

number8:
	ORI r17, 0b00000010
	rjmp back4

number16:
	ORI r18, 0b00001000
	rjmp back5

number32:
	ORI r18, 0b00000010
	rjmp lights

lights:
	mov r16, r17
	sts PORTL, r16
	mov r16, r18
	out PORTB, r16
	clr r17
	clr r18

		ret
;
; delay
;
; set r20 before calling this function
; r20 = 0x40 is approximately 1 second delay
;
; registers used:
;	r20
;	r21
;	r22
;
delay:	
del1:	nop
		ldi r21,0xFF
del2:	nop
		ldi r22, 0xFF
del3:	nop
		dec r22
		brne del3
		dec r21
		brne del2
		dec r20
		brne del1	
		ret
