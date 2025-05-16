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
.equ DELAY_CONST, 0x7AE147

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

    loop:
		//ldr r8,=DELAY_CONST

        //bl delay

        // function check_input: returns in r0 and r1:
        // r2 = return value, * if persist state, 1 if increment, 2 if clear
        bl poll_increment
        bl init_counter_and_offset // r1 --> sw, r3 --> -4*(sw+1)
        cmp r2,#1
		bleq increment_digit
		cmp r2,#2
		bleq clear_stack

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
    b loop

poll_increment:
	ldr r0,[r5]
poll_inc_next:
	ldr r1,[r5]
	cmp r0,r1
	beq poll_inc_next
	mov r2,r1 // if r1 = 1, increment, r1 =< 2, clear
bx lr

button_polling:
	and r2,#0 // clear r0, return 0 if nothing else
	ldr r0,[r5] // load buttons (first time)
button_second:
	ldr r1,[r5] // load buttons (second time)

	cmp r0,#2
	movge r2,#2
	bxge lr // return if clear is set

	and r0,#0b01
	and r1,#0b01
	eors r2,r0,r1
	cmp r2,#1
	bne button_second
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

increment_digit_address: // treats r1 as a counter, r0 as switches, r3 as address
push {r2}
	cmp r0,#3 // compare switches to max value of shift, digit 3 (default: shift LSP)
	bxgt lr
	add r0,#1 // add 1 to r0 (1-4)
	mov r1,r0 // switches + 1 --> counter
	mov r2,#-4 // move -4 immediate into r2 register for mul
	mul r3,r0,r2 // r0 --> r3, correct address shift for stack
pop {r2}
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

.end
