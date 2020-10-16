;
; CSc 230 Assignment 1 
; Question 2
;

; This program should calculate:
; R0 = R16 + R17
; if the sum of R16 and R17 is > 255 (ie. there was a carry)
; then R1 = 1, otherwise R1 = 0
;

;--*1 Do not change anything between here and the line starting with *--
.cseg
	ldi	r16, 0xF0
	ldi r17, 0x31
;*--1 Do not change anything above this line to the --*

;***
; Your code goes here:
;
.def sum = r0
.def carry = r1
.def temp = r18
	
	clr sum
	clr carry
	clr temp

	MOV sum, r16
	ADD sum, r17
	BRCS yesCarry
	rjmp noCarry

yesCarry:
	LDI temp, 1
	MOV carry, temp
	rjmp done

noCarry:
	LDI temp, 0
	MOV carry, temp
	rjmp done

;****
;--*2 Do not change anything between here and the line starting with *--
done:	jmp done
;*--2 Do not change anything above this line to the --*


