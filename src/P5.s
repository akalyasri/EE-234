.text
.global main

@ The first 4 switches as a binary number,
@ Light up the first 4 LED’s individually if the number falls in a certain range:
@ Light LED0 if the value of the switches is from 0 to 3;
@ LED 1 if the value is between 4 and 7; LED 2 if the value is between 8 and 11;
@ and LED 3 if the value is between 12 and 15.
@ Only one LED should be lit at any time.

.equ LED_CTL, 0x41210000	@ led control register address
.equ SW_DATA, 0x41220000	@ switch register address
.equ ONLY, 0xF				@ help with only using the first four switches as input

main:
    ldr r1, =SW_DATA       @ load switch address
    ldr r2, =LED_CTL       @ load led control address

loop:
	ldr r0,[r1]				@ load switch value
	and r0, r0, #ONLY		@ gets only the first four switches

	cmp r0, #3
	ble led0_HIGH			@ if r0 (the switches) <= 3 ; turn led 0 on

	cmp r0, #7
	ble led1_HIGH			@ if 4 <= r0 (the switches) <= 7 ; turn led 1 on

	cmp r0, #11
	ble led2_HIGH			@ if 8 <= r0 (the switches) <= 11 ; turn led 2 on

	cmp r0, #15
	ble led3_HIGH			@ if 12 <= r0 (the switches) <= 15 ; turn led 3 on

led_OFF:
	mov r3, #0
	str r3, [r2]
	b loop

led0_HIGH:
	mov r3, #1
	str r3, [r2]
	b loop

led1_HIGH:
	mov r3, #2
	str r3, [r2]
	b loop

led2_HIGH:
	mov r3, #4
	str r3, [r2]
	b loop

led3_HIGH:
	mov r3, #8
	str r3, [r2]
	b loop


.end
