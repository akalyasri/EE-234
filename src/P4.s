.text
.global main

@ Write a program that will illuminate the first LED if the value
@ of the switches is equal to your age, and the second LED if all switches are ‘1’.

.equ LED_CTL, 0x41210000	@ led control register address
.equ SW_DATA, 0x41220000	@ switch register address
.equ AGE, 20
.equ ALL_ON, 0xFF

main:
    ldr r1, =SW_DATA       @ load switch address
    ldr r2, =LED_CTL       @ load led control address

loop:
    ldr r0, [r1]           @ load switch value into r0
    cmp r0, #AGE           @ compare switch value with my age
    beq led_age            @ if equal, branch to led_age
    cmp r0, #ALL_ON        @ compare switch value with all switches on
    beq led_all_on         @ if equal, branch to led_all_on

led_off:
    mov r3, #0             @ turn off LEDs
    str r3, [r2]           @ store 0 to LED register
    b loop                 @ loop back

led_age:
    mov r3, #1             @ first led on (0000 0001)
    str r3, [r2]           @ store value to LED register
    b loop                 @ loop back

led_all_on:
    mov r3, #2             @ second led on (0000 0010)
    str r3, [r2]           @ store value to LED register
    b loop                 @ loop back

.end
