.text
.global main

.equ LED_DATA, 0x41210000
.equ SW_DATA, 0x41220000

@blinks the led!
main:
	blinky_loop:
		bl led0_toggle
		ldr r1,=SW_DATA
		ldr r0,[r1]
		mov r0,r0,lsl #20 		@bit shift register 0 by 20 places
		add r0,#1 				@ensure delay is at least '1'
		bl delay
	b blinky_loop

delay:
	subs r0,r0,#1
	bne delay
	bx lr

led0_on:
	ldr r1, =LED_DATA
	ldr r0, [r1]	@get current value
	orr r0,r0,#1	@set the first bit (don't affect other bits)
	str r0, [r1]	@write back to LED_DATA
	bx lr			@return from subroutine

led0_off:
	ldr r1, =LED_DATA
	ldr r0, [r1]	@get current value
	mov r0,#0		@set the first bit (don't affect other bits)
	str r0, [r1]	@write back to LED_DATA
	bx lr			@return from subroutine

led0_toggle:
	ldr r1, =LED_DATA
	ldr r0, [r1]	@get current value
	eor r0,r0,#1
	str r0, [r1]	@write back to LED_DATA
	bx lr			@return from subroutine

.end
