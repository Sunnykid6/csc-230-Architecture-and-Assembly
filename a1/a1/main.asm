;
; CSc 230 Assignment 1 Part 2
; Question 5  Credits: J. Corless
;  
; Michael Reiter
; V00831568
;
.include "m2560def.inc"
; This program should sum 3 numbers together: (valueA), (valueB), and (valueC)
;
; The result should be stored in (result).
;
; Where:
;
;   (valueA) refers to the byte stored at memory location valueA in data memory 
;   (valueB) refers to the byte stored at memory location valueB in data memory 
;   (valueC) refers to the byte stored at memory location valueC in data memory 
;   (result) refers to the byte stored at memory location result in data memory
;
; In the AVR there is no way to automatically initialize data memory
; with constant values.  This is why this supplied code initializes data
; memory from program memory.
;

;--*1 Do not change anything between here and the line starting with *--
;
; You don't need to understand this code, we will get to it later
;
; But, if you are keen -- I am using the Z register as a pointer into
; program memory and X as a pointer into data memory
;
.cseg
	ldi ZH,high(init<<1)	; initialize Z to point to init
	ldi ZL,low(init<<1)
	lpm r0,Z				; get the first byte and increment Z
	sts valueA,r0			; store into A
	ldi	r16, 0x07			; an immediate value
	add r0,r16				; create a new value
	sts valueB, r0			; store into B
	and r0,r16				; create a new value
	sts valueC, r0			; store into C
;*--1 Do not change anything above this line to the --*

;***
	clr r0				;clear the first register
	lds r0, valueA		;load valueA into r0
	lds r17, valueB		;load valueB into r17
	lds r18, valueC		;load valueC into r18
	add r0, r17			;add r0 and r17 then store in r0
	add r0, r18			;add r0 and r18 then store in r0
	sts result, r0		;store r0 in result
;****

;--*2 Do not change anything between here and the line starting with *--
done:	jmp done
;*--2

;--*3 Do not change anything between here and the line starting with *--
; This is the constant to initialize value to
; Program memory must be specified in words (2 bytes) which
; is why there is a 2nd byte (0x00) at the end.
init:	.db 0x05, 0x03
;*--3
;--*4 Do not change anything between here and the line starting with *--
; This is in the data segment (ie. SRAM)
; The first real memory location in SRAM starts at location 0x200 on
; the ATMega 2560 processor.  Locations less than 0x200 are special
; and will be discussed much more later
;
.dseg
.org 0x200
valueA:	.byte 1
valueB:	.byte 1
valueC:	.byte 1
result:	.byte 1
;*--4