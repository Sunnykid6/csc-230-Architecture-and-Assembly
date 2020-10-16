;
; a2.asm
;
; Created: 2018-10-24 12:06:31 AM
; Author : Victor Sun
;


; Replace with your application code
		ldi r16, 0xFF
		out DDRB, r16		; PORTB all output
		sts DDRL, r16		; PORTL all output

		ldi r16, 0x33		; display the value
		mov r0, r16			; in r0 on the LEDs

; Your code here
	ldi r16, 0b10100000
	sts PORTL, r16
	ldi r16, 0b00000010
	out PORTB, r16
;
; Don't change anything below here
;
done:	jmp done