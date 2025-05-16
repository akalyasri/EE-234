.text
.global main

@uart1 control register
.equ UART1_CR, 0xE0001000
@uart1 mode register
.equ UART1_MR, 0xE0001004
.equ UART1_BAUDGEN,	0xE0001018
.equ UART1_BAUDDIV,	0xE0001034
.equ UART1_SR, 0xE000102C
.equ UART1_FIFO, 0xE0001030

main:
	bl configure_uart1

	mov r0,#'F'	//copy ascii 'F' to r0
	bl uart1_send_char	@send the data in r0 over uart

	b .	@endless loop

configure_uart1:
	push {lr}

	bl reset_uart1
	ldr r1, =UART1_MR
	mov r0, #0x20
	str r0,[r1]
	ldr r1, =UART1_CR
	mov r0,#4 // enable tx
	orr r0,r0,#16 //enable rx
	str r0,[r1] //store to CR

	// Generate baudgen 115200
	ldr r1, =UART1_BAUDGEN
	mov r0, #0x7C

	str r0,[r1]

	ldr r1, =UART1_BAUDDIV
	mov r0, #6

	str r0,[r1]

	pop {lr}
	bx lr


uart1_send_char:
	ldr r1,=UART1_SR // load status register
	
    // Need to check bit 4 (TFS) is not 1
	ldr r2,[r1] // load current value of SR to r2
	and r2,#0x10 // mask
	cmp r2,#0x10 // if equal, FIFO is full, branch back
	beq uart1_send_char

	ldr r1,=UART1_FIFO
	str r0,[r1] // store character into FIFO

	bx lr

reset_uart1:
	ldr r1,=UART1_CR

	mov r0, #3	@assert reset
	str r0,[r1]

	reset_loop:
		ldr r0,[r1]	@get current CR val
		ands r0,#3
		bne reset_loop	@branch if either set

	bx lr

.end
