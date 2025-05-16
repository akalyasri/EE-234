.global enable_svn_seg
.global write_digit
.global transfer_and_shift
.global disable_dp

enable_svn_seg:
    mov r0,#1
    str r0,[r6]
bx lr

write_digit: // r0 - switches, r2 - digits
push {r1, r3, r4, lr} // push non-parameter registers
    cmp r2,#1 // compare if digits input is valid
    bxlt lr
    cmp r2,#4
    bxgt lr // branch back to main if not

    sub r2,#1 // subtract 1 from r2 (for shifting)

    mov r3,#8
	mul r2,r2,r3 // r2 = shift value

	mov r4,#0b1111 // move 1111 into r4
	lsl r4,r2 // shift 1's to correct location
	lsl r0,r2 // shift new value to proper location

	mvn r4,r4 // invert r4 for mask
	ldr r1, [r7] // load current value of 7segctrl into r1
	ands r1,r1,r4 // AND value of 7segctrl with invert mask
	orrs r0,r0,r1 // OR shifted switch value w/ current 7segctrl value

	// Note the purpose of this is the mask out a 4-bit block so that the
	// new value will truly replace any old digit value.

    str r0, [r7] // stores r0 at r7
pop {r1, r3, r4, lr}
bx lr

transfer_and_shift: // takes large bit # (r1) and shifts left by 4: 4 'shifted off'
// values are then captured into another register (r0).
push {r3}
	mov r3,#0b1111
	mov r0,r1 // move large bit # into r0
	and r0,r3 // mask out all but lowest 4 bits of r0
	lsr r1,#4 // shift out value returned in r0
pop {r3}
bx lr

disable_dp:
push {r1, r3, r7}
	movw r3,#0x8080
	movt r3,#0x8080
	ldr r1, [r7]
	orrs r1,r3
	str r1, [r7]
pop {r1, r3, r7}
bx lr
