.text
.global main

.equ LED_DATA, 0x41210000
.equ SW_DATA, 0x41220000
.equ PWM_BASE, 0x43C00000
.equ PWM_OFFSET, 0x10  @ offset between each pwm channel
.equ PWM_PERIOD, 0x04  @ offset for period register
.equ PWM_WIDTH,  0x08  @ offset for width register

main:
    loop:
        bl disable_pwm_channel
        bl enable_pwm_channel
        bl set_pwm_window
        bl set_pwm_duty
        b loop

enable_pwm_channel:  @selected PWM channel
    ldr r2, =SW_DATA
    ldr r0, [r2]
    and r0, r0, #0x1C00  @ mask sw9-sw11
    lsr r0, r0, #9

    cmp r0, #3
    bge return           @ return if invalid

    mov r1, #1
    ldr r3, =PWM_BASE
    add r3, r3, r0, LSL #4
    str r1, [r3]         @ enable PWM channel
    bx lr

disable_pwm_channel:  	@ disable all channels
    ldr r2, =PWM_BASE
    mov r1, #0
    mov r0, #0

disable_loop:
    add r3, r2, r0, LSL #4
    str r1, [r3]
    add r0, r0, #1
    cmp r0, #3
    blt disable_loop
    bx lr

set_pwm_window:   		@ set the pwm window width
    ldr r1, =0x1000000
    ldr r2, =PWM_BASE
    mov r0, #0

set_window_loop:
    add r3, r2, r0, LSL #4
    add r3, r3, #PWM_PERIOD
    str r1, [r3]
    add r0, r0, #1
    cmp r0, #3
    blt set_window_loop
    bx lr

set_pwm_duty:
    ldr r2, =SW_DATA
    ldr r0, [r2]

    and r0, r0, #0xFF   @ extract lower 8 bits for brightness
    lsr r0, r0, #1      @ shift right to align brightness scale

    ldr r1, =PWM_BASE
    ldr r2, =SW_DATA
    ldr r3, [r2]
    and r3, r3, #0x1C00
    lsr r3, r3, #9

    cmp r3, #3
    bge return

    add r1, r1, r3, LSL #4
    add r1, r1, #PWM_WIDTH
    str r0, [r1]         @ set the PWM duty for selected LED
    bx lr

return:
    bx lr
