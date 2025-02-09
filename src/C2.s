.text
.global main

@ Use buttons to latch a binary value
@ Treat the first 8 switches as an 8-bit binary value,
@ and ‘latch’ the value of the switches to an internal memory location
@ when one of the buttons is pressed. Show the latched value on the first eight LEDs,
@ and demonstrate that changing the switches does not change the LED value until
@ the latch button is pressed again. Clear the value (set the value to zero)
@ when a different button is pressed.

.equ LED_CTL,  0x41210000  @ LED control address
.equ SW_DATA,  0x41220000  @ Switch input address
.equ BTN_DATA, 0x41200000  @ Button input address
.equ MASK,     0xFF        @ Mask for the first 8 bits (1111 1111)

.data
latched_value: .word 0      @ Store the latched value in memory

main:
    ldr r1, =SW_DATA        @ Load switch address
    ldr r2, =BTN_DATA       @ Load button address
    ldr r3, =LED_CTL        @ Load LED control address
    ldr r4, =latched_value  @ Load address of latched value

loop:
    ldr r5, [r2]            @ Read button state
    and r5, r5, #0x3        @ Mask only BTN0 (bit 0) and BTN1 (bit 1)

    cmp r5, #1              @ Check if BTN0 is pressed
    beq latch_value         @ If yes, store switch value

    cmp r5, #2              @ Check if BTN1 is pressed
    beq clear_value         @ If yes, reset the latched value

    ldr r6, [r4]            @ Load latched value
    str r6, [r3]            @ Update LED display
    b loop                  @ Repeat loop

latch_value:
    ldr r6, [r1]            @ Read switch values
    and r6, r6, #MASK       @ Mask out only the first 8 switches
    str r6, [r4]            @ Store the value in memory
    b loop

clear_value:
    mov r6, #0              @ Clear the latched value
    str r6, [r4]            @ Store 0 in memory
    b loop

.end
