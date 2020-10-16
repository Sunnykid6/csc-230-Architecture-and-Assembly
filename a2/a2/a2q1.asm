;
; a2q1.asm
;
; Write a program that displays the binary value in r16
; on the LEDs.
;
; See the assignment PDF for details on the pin numbers and ports.
;


		ldi r16, 0xFF
		out DDRB, r16		; PORTB all output
		sts DDRL, r16		; PORTL all output

		ldi r16, 0x33		; display the value
		mov r0, r16			; in r0 on the LEDs

; Your code here
		clr r17
		clr r18
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
	sts PORTL, r17
	mov r16, r18
	out PORTB, r16
;
; Don't change anything below here
;
done:	jmp done
