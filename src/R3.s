.text
.global main

.equ LED_DATA, 0x41210000
.equ SW_DATA, 0x41220000

main:
	loop:
		ldr r0,=#256
		ldr r2,=SW_DATA
		ldr r1,[r2]
		bl soft_pwm
	b loop

soft_pwm:
							@count from r0 to 0
	mov r6,lr 				@backup lr to r6
	cmp r1,#0 				@check switch is not 0
	ble terminate
	subs r0,r0,#1
		mov r4,r0 			@back up r0 to r4
		mov r5,r1 			@back up r1 to r5
		cmp r0,r1 			@compare counter to our period r0 < r1
			mov r14,r15 	@ lr = pc
			blt led0_on
			mov r14,r15 	@lr = pc
			bge led0_off
		mov lr,r6 			@restore lr
		mov r0,r4
		mov r1,r5 			@restore r0 and r1
		cmp r0,#0
	bne soft_pwm 			@if not 0, branch back to soft_pwm
	bx lr

terminate:
	bl led0_off
	b loop

led0_on:
	ldr r1, =LED_DATA
	ldr r0, [r1]	@ get current value
	orr r0,r0,#1	@ set the first bit (don't affect other bits)
	str r0, [r1]	@ write back to LED_DATA
	bx lr			@ return from subroutine

led0_off:
	ldr r1, =LED_DATA
	ldr r0, [r1]	@ get current value
	mov r0,#0		@ set the first bit (don't affect other bits)
	str r0, [r1]	@ write back to LED_DATA
	bx lr			@ return from subroutine

led0_toggle:
	ldr r1, =LED_DATA
	ldr r0, [r1]	@ get current value
	eor r0,r0,#1
	str r0, [r1]	@ write back to LED_DATA
	bx lr			@ return from subroutine

.end
