.global main

.data
// Store 5 bytes for my name, Z-a-c-h-\0
name:
.byte 90,97,99,104,0

//.comm unknown_string, 128

.text
.global receive_string
.global send_string
.global reset_uart1

// Hardware addresses
.equ LED_DATA, 0x41210000

@uart1 control register
.equ UART1_CR, 0xE0001000
@uart1 mode register
.equ UART1_MR, 0xE0001004
.equ UART1_BAUDGEN,	0xE0001018
.equ UART1_BAUDDIV,	0xE0001034
.equ UART1_SR, 0xE000102C
.equ UART1_FIFO, 0xE0001030

/*
main:
	bl configure_uart1

	ldr r1, =unknown_string
	mov r3, #0x7F // 128 bytes of storage at r1

	bl receive_string

	ldr r1, =unknown_string

	bl send_string

b . // end program
*/

receive_string: //r1 is pointer in memory
push {lr}
r_loop:
push {r1} // maintain address at r1
	bl uart1_receive_char // receive character from UART
	cmp r3,#0 // check if enough space in memory at r1 (r2 != 0)
pop {r1} // pop address at r1
	strneb r0,[r1],#1 // store at location in memory
	subnes r3,r3,#1 // r3--
	cmp r0,#13 // compare if newline
	bne r_loop // only loop if not newline
	mov r0,#0 // move 0 into r0 (null)
	strb r0,[r1],#1
pop {lr}
bx lr

send_string: // r0 with base address as parameter
push {lr}
	ldrb r0,[r1],#1 // load r0 with current byte from data
	cmp r0,#0 // until null
	blne uart1_send_char
	bne send_string
pop {lr}
bx lr

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

	str r0,[r1] // store into r0

	pop {lr}
	bx lr

uart1_receive_char:
	ldr r1,=UART1_SR // load status register
	// Need to check bit 1 of status (RES)
	ldr r2,[r1] // current value of SR to r2
	and r2,#0b10 // mask
	cmp r2,#0b10 // check if FIFO receive is empty
	beq uart1_receive_char // branch back if empty

	ldr r1,=UART1_FIFO
	ldr r0,[r1] // load character from FIFO

	bx lr

uart1_send_char:
	push {r1, r2, lr}
	ldr r1,=UART1_SR // load status register
	// Need to check bit 4 (TFS) is not 1
	ldr r2,[r1] // load current value of SR to r2
	and r2,#0x10 // mask
	cmp r2,#0x10 // if equal, FIFO is full, branch back
	beq uart1_send_char

	ldr r1,=UART1_FIFO
	str r0,[r1] // store character into FIFO

	pop {r1, r2, lr}
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
