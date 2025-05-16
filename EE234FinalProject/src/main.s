.cpu cortex-a9
.global _start
.text

@ PWM Registers
.equ PWM_BASE,   0x43C00000
.equ PWM_OFFSET, 0x10
.equ PWM_CTRL,   0x00
.equ PWM_PERIOD, 0x04
.equ PWM_WIDTH,  0x08

@ Inputs
.equ XADC_BASE,  0x43C50000
.equ XADC_CR0,   0x43C50300
.equ XADC_VP,    0x43C5020C
.equ SW_DATA,    0x41220000
.equ DELAY_CONST, 0x1FFFFF

@ UART
.equ UART1_CR, 0xE0001000
.equ UART1_MR, 0xE0001004
.equ UART1_BAUDGEN, 0xE0001018
.equ UART1_BAUDDIV, 0xE0001034
.equ UART1_SR, 0xE000102C
.equ UART1_FIFO, 0xE0001030

.data
prompt:
    .asciz "Enter blue brightness (0–255):\r\n"

.comm unknown_string, 128

.text
_start:
    bl configure_uart1

    ldr r1, =prompt
    bl send_string

    ldr r1, =unknown_string
    mov r3, #0x7F
    bl receive_string

    ldr r1, =unknown_string
    bl parse_ascii_to_r10

    mov r14, #0              @ prev_sw1 state

main:
    bl read_switches
    mov r2, r0

    bl read_potentiometer
    mov r11, r0              @ RED brightness from POT

    @ RED LED -> PWM2
    tst r2, #0x1
    beq red_off
    mov r1, r11
    mov r6, #2
    bl set_pwm_simple
    b red_done
red_off:
    mov r1, #0
    mov r6, #2
    bl set_pwm_simple
red_done:

    @ BLUE LED -> PWM0 with SW1-triggered prompt
    tst r2, #0x2
    moveq r3, #0
    movne r3, #1

    cmp r14, #0
    bne blue_check_done
    cmp r3, #1
    bne blue_check_done

    ldr r1, =prompt
    bl send_string

    ldr r1, =unknown_string
    mov r3, #0x7F
    bl receive_string

    ldr r1, =unknown_string
    bl parse_ascii_to_r10

blue_check_done:
    mov r14, r3

    tst r2, #0x2
    beq blue_off
    mov r1, r10
    mov r6, #0
    bl set_pwm_simple
    b blue_done
blue_off:
    mov r1, #0
    mov r6, #0
    bl set_pwm_simple
blue_done:

    @ GREEN LED -> PWM1
    tst r2, #0x4
    beq green_off
    mov r6, #1
    mov r12, r2
    lsr r12, r12, #3
    and r1, r12, #0xFF
    bl set_pwm_simple
    b green_done
green_off:
    mov r1, #0
    mov r6, #1
    bl set_pwm_simple
green_done:

    bl delay
    b main

set_pwm_simple:
    ldr r0, =PWM_BASE
    mov r7, #PWM_OFFSET
    mul r8, r6, r7
    add r0, r0, r8

    mov r9, #0xFF
    str r9, [r0, #PWM_PERIOD]
    mov r13, #1
    str r13, [r0]
    str r1, [r0, #PWM_WIDTH]
    bx lr

read_potentiometer:
    ldr r1, =XADC_CR0
    ldr r0, [r1]
    bic r0, r0, #0x1F         @ Clear bits [4:0]
    orr r0, r0, #0x03         @ Set channel 3 (VP)
    str r0, [r1]              @ Select VP channel

    ldr r1, =XADC_VP
    ldr r0, [r1]              @ Read raw 12-bit sample in top bits
    lsr r0, r0, #4
    and r0, r0, #0xFF         @ Convert to 8-bit value
    bx lr

read_switches:
    ldr r1, =SW_DATA
    ldr r0, [r1]
    bx lr

configure_uart1:
    push {lr}
    bl reset_uart1
    ldr r1, =UART1_MR
    mov r0, #0x20
    str r0, [r1]
    ldr r1, =UART1_CR
    mov r0, #0x4
    orr r0, r0, #0x10
    str r0, [r1]
    ldr r1, =UART1_BAUDGEN
    mov r0, #0x7C
    str r0, [r1]
    ldr r1, =UART1_BAUDDIV
    mov r0, #6
    str r0, [r1]
    pop {lr}
    bx lr

reset_uart1:
    ldr r1, =UART1_CR
    mov r0, #3
    str r0, [r1]
reset_loop:
    ldr r0, [r1]
    ands r0, r0, #3
    bne reset_loop
    bx lr

send_string:
    push {lr}
send_loop:
    ldrb r0, [r1], #1
    cmp r0, #0
    beq send_done
    bl uart1_send_char
    b send_loop
send_done:
    pop {lr}
    bx lr

receive_string:
    push {lr}
recv_loop:
    push {r1}
    bl uart1_receive_char
    cmp r3, #0
    pop {r1}
    strneb r0, [r1], #1
    subnes r3, r3, #1
    cmp r0, #13
    bne recv_loop
    mov r0, #0
    strb r0, [r1], #1
    pop {lr}
    bx lr

parse_ascii_to_r10:
    ldr r1, =unknown_string
    mov r10, #0
    mov r4, #10
parse_loop:
    ldrb r0, [r1], #1
    cmp r0, #0
    beq parse_done
    sub r0, r0, #'0'
    cmp r0, #9
    bhi parse_done
    mul r10, r10, r4
    add r10, r10, r0
    b parse_loop
parse_done:
    bx lr

uart1_receive_char:
    ldr r1, =UART1_SR
wait_uart_rx:
    ldr r2, [r1]
    and r2, r2, #0b10
    cmp r2, #0b10
    beq wait_uart_rx
    ldr r1, =UART1_FIFO
    ldr r0, [r1]
    bx lr

uart1_send_char:
    push {r1, r2, lr}
    ldr r1, =UART1_SR
wait_uart_tx:
    ldr r2, [r1]
    and r2, r2, #0x10
    cmp r2, #0x10
    beq wait_uart_tx
    ldr r1, =UART1_FIFO
    str r0, [r1]
    pop {r1, r2, lr}
    bx lr

delay:
    ldr r0, =DELAY_CONST
wait_loop:
    subs r0, r0, #1
    bne wait_loop
    bx lr
