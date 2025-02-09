.text
.global main

@ Make the first green LED turn on when the first button is pressed
@ and turn off when the button is pressed again. The LED should not change state
@ when the button is released or if the button is held down.


.equ LED_CTL,  0x41210000  @ LED control address
.equ BTN_DATA, 0x41200000  @ Button input address
.equ LED_MASK, 0x1         @ Mask for LED0 (0000 0001)
.equ BTN_MASK, 0x1         @ Mask for BTN0 (0000 0001)

.data
led_state: .word 0         @ Store current LED state (0 = off, 1 = on)
prev_btn:  .word 0         @ Store previous button state (0 = released, 1 = pressed)

main:
    ldr r1, =BTN_DATA      @ Load button address
    ldr r2, =LED_CTL       @ Load LED address
    ldr r3, =led_state     @ Load address of LED state
    ldr r4, =prev_btn      @ Load address of previous button state

loop:
    ldr r5, [r1]           @ Read button state
    and r5, r5, #BTN_MASK  @ Mask only BTN0 (bit 0)

    ldr r6, [r4]           @ Load previous button state
    cmp r5, #1             @ Is the button currently pressed?
    bne no_toggle          @ If not, skip toggle logic

    cmp r6, #0             @ Was the button previously released?
    bne no_toggle          @ If it was already pressed, skip toggle

    ldr r7, [r3]           @ Load current LED state
    eor r7, r7, #LED_MASK  @ Toggle LED state (XOR with 1)
    str r7, [r3]           @ Store new LED state
    str r7, [r2]           @ Update LED output

no_toggle:
    str r5, [r4]           @ Update previous button state
    b loop                 @ Repeat loop

.end
