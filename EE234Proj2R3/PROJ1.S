.text
.global main

.extern enable_svn_seg
.extern write_digit
.extern transfer_and_shift
.extern disable_dp

.equ LED_DATA, 0x41210000
.equ BTN_DATA, 0x41200000
.equ SW_DATA, 0x41220000
.equ SVN_SEG_CTRL, 0x43C10000
.equ SVN_SEG_DATA, 0x43C10004
.equ DELAY_CONST, 0xC49BA

/*
	Ones place: 	[fp,#-4]
	Tenths: 		[fp,#-8]
	Hundredths: 	[fp,#-12]
	Thousandths: 	[fp,#-16]
*/

main:
    ldr r4,=SW_DATA
    ldr r5,=BTN_DATA
    ldr r6,=SVN_SEG_CTRL
    ldr r7,=SVN_SEG_DATA

    bl enable_svn_seg
	bl disable_dp
	bl init_stack

	and r0,#0 // stop by default

    loop:
		cmp r0,#0
		bleq stop
		cmp r0,#1
		bleq start
		cmp r0,#1 // ensure r0 can never not be 0 or 1
		movgt r0,#0
    b loop

start:
push {lr}
	// "running" loop
	ldr r8,=DELAY_CONST // load ms delay into r8
    bl delay // dummy delay loop
	bl increment // increment regardless
	bl get_buttons
	cmp r2,#0b100
	eoreq r0,#1
	bl process_function
	bl write_digits // write digits regardless
pop {lr}
bx lr

stop:
push {lr}
	// "stopped" loop
stop_poll:
	bl get_buttons
	//cmp r2,#0
	//bne stop_poll
stop_poll_2:
	ldr r1,[r5] //r1 and r2 are buttons
	cmp r1,#0b100
	eoreq r0,#1
	cmp r1,r2
	beq stop_poll_2
	cmp r2,#1
	bleq increment
	bl process_function
	bl write_digits
pop {lr}
bx lr

process_function:
push {lr}
	// genericized function to process start/stop, clear
	//ldr r1,[r5] // button values -> r1
	cmp r2,#0b010
	bleq clear_stack
pop {lr}
bx lr

poll_increment:
push {r0, lr}
	ldr r0,[r5]
	and r0,#1
poll_inc_next:
	ldr r1,[r5]
	cmp r0,r1
	beq poll_inc_next
	mov r2,r1 // if r1 = 1, increment
pop {r0, lr}
bx lr

increment:
push {r0, lr}
	bl init_counter_and_offset // initialize r1 -> 0, offset -> -4 (first digit)
	bl increment_digit // increment regardless
pop {r0, lr}
bx lr

write_digits:
push {r0, lr}
	// Ones Digit
    ldr r0, [fp,#-4]
    mov r2,#1
    bl write_digit

	// Tenths Digit
    ldr r0, [fp,#-8]
    mov r2,#2
    bl write_digit

	// Hundredths Digit
    ldr r0, [fp,#-12]
    mov r2,#3
    bl write_digit


	// Thousandths Digit
    ldr r0, [fp,#-16]
    mov r2,#4
    bl write_digit
pop {r0, lr}
bx lr

delay:
	subs r8,r8,#1
	bne delay
bx lr

init_counter_and_offset:
	and r1,#0 // clear r1
	and r3,#0 // clear r3
	mov r3,#-4 // initial value of r3 should be for first digit, [fp,#-4]
	ldr r10,[r4] // switches
	cmp r10,#3
	bxgt lr
	mov r1,r10 // switch value 0-3 is now in r1
	adds r10,#1 // value 1-4 now in r10
	mul r3,r3,r10 // set r3 address offset correctly
bx lr

init_stack:
push {r0, fp, lr}
	mov fp,sp
	sub sp,sp,#0x10 // 4 words * 4 = 16, 0x10
	mov r0,#0
	str r0,[fp,#-4]
	and r0,#0 // clear r0
	str r0,[fp,#-8]
	str r0,[fp,#-12]
	str r0,[fp,#-16]
bx lr

clear_stack:
	and r0,#0 // clear r0
	str r0,[fp,#-4]
	str r0,[fp,#-8]
	str r0,[fp,#-12]
	str r0,[fp,#-16]
bx lr

increment_digit: // r0 is the current digit value, r1 is a counter, r3 as address offset
push {lr}
	ldr r0,[fp,r3]
	cmp r0,#9
		addne r0,r0,#1
		moveq r0,#0
		streq r0,[fp,r3]
		bleq increment_next
	str r0,[fp,r3]
pop {lr}
bx lr

increment_next: // r1 as a counter, r3 as the address offset
push {lr}
	add r1,r1,#1
	cmp r1,#4
	bxge lr // return if 4 or greater
	sub r3,#4 // move address to next digit (subtract by 4)
	blne increment_digit
pop {lr}
bx lr

get_buttons:
	ldr r2,[r5]
bx lr

.end
