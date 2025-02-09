.text
.global main

.equ LED_DATA, 0x41210000
@

main:
	loop:
		bl led0_on
		bl led0_off
		bl led0_toggle
		bl led0_toggle



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
