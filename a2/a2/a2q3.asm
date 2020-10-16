.cseg
        ldi     r16, 0xFF
		out SPL, r16
		ldi r16, 0x21
		out SPH, r16

		ldi r16, 04
		push r16
		ldi r23, 5
		push r23
		ldi r24, 1
		call check_stuff
		pop r23
		pop r16
		jmp done

done: jmp done

check_stuff:
		clr r16
		in ZH, SPH
		in ZL, SPL

		ldd r16, Z + 4
		tst r16
		breq return_1
		mul r24, r16
		dec r16
		std z + 4, r16
		push r16
		call check_stuff
		pop r16
		ret

return_1:
		ret
