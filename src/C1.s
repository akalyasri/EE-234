.text
.global main


@ Treat the first four LED’s as a function of the first 4 switches and
@ the four buttons, and light an LEDs when its corresponding switch or
@ button is activated, but not when both are activated.

.equ LED_CTL, 0x41210000	@ led control register address
.equ SW_DATA, 0x41220000	@ switch register address
.equ PB_DATA, 0x41200000	@ push button register address
.equ ONLY, 0xF				@ for first four bits (0000 1111)

main:
	ldr r1, =SW_DATA		@ load switch address into r1
    ldr r2, =PB_DATA		@ load button address into r2
    ldr r3, =LED_CTL		@ load LED control address into r3

loop:
	ldr r4, [r1]			@ load switch values
	and r4, r4, #ONLY		@ get only first four switches

	ldr r5, [r2]			@ load button values into r5
	and r5, r5, #ONLY		@ get only first four buttons

	eor r6, r4, r5			@ xor switches and button
	str r6, [r3]			@ result to led

	b loop					@ repeat

.end


