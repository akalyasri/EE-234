.cpu cortex-a9
.global _start
.text

@ --------------------------------------------------------------------------
@ Hardware addresses
@ --------------------------------------------------------------------------
.equ LED_DATA,     0x41210000   @ RGB LED output
.equ SW_DATA,      0x41220000   @ Slide switches
.equ UART_FIFO,    0xE0001030   @ UART1 FIFO
.equ UART_SR,      0xE000102C   @ UART1 Status Reg
.equ UART_RXFULL,  0x00000002
.equ XADC_BASE,    0xF8007100   @ XADC data reg
.equ DELAY_CONST,  0x1FFFFF

@ --------------------------------------------------------------------------
@ Start
@ --------------------------------------------------------------------------
_start:
main:
    bl read_switches        @ r0 = all switches
    mov r1, r0              @ copy to r1
    lsr r2, r1, #3          @ shift SW3–SW5 to bits 0–2
    and r2, r2, #0x7        @ r2 = on/off mask (R/G/B)

    lsr r3, r1, #6
    and r3, r3, #0xFF       @ r3 = brightness from SW6–13

    bl read_potentiometer
    mov r4, r0              @ r4 = red brightness

    bl read_uart_byte
    mov r5, r0              @ r5 = blue brightness

    mov r6, #0              @ final output

    tst r2, #1              @ RED on?
    orrne r6, r6, r4, lsl #0

    tst r2, #2              @ GREEN on?
    orrne r6, r6, r3, lsl #1

    tst r2, #4              @ BLUE on?
    orrne r6, r6, r5, lsl #2

    ldr r7, =LED_DATA
    str r6, [r7]            @ write to LED

    bl delay
    b main

@ --------------------------------------------------------------------------
@ Read slide switches → r0
@ --------------------------------------------------------------------------
read_switches:
    ldr r1, =SW_DATA
    ldr r0, [r1]
    bx lr

@ --------------------------------------------------------------------------
@ Read potentiometer → r0 (8-bit)
@ --------------------------------------------------------------------------
read_potentiometer:
    ldr r1, =XADC_BASE
    ldr r0, [r1]
    lsr r0, r0, #4
    and r0, r0, #0xFF
    bx lr

@ --------------------------------------------------------------------------
@ Read byte from UART → r0
@ --------------------------------------------------------------------------
read_uart_byte:
wait_uart:
    ldr r1, =UART_SR
    ldr r2, [r1]
    ands r2, r2, #UART_RXFULL
    beq wait_uart
    ldr r1, =UART_FIFO
    ldr r0, [r1]
    and r0, r0, #0xFF
    bx lr

@ --------------------------------------------------------------------------
@ Simple delay
@ --------------------------------------------------------------------------
delay:
    ldr r0, =DELAY_CONST
loop:
    subs r0, r0, #1
    bne loop
    bx lr
