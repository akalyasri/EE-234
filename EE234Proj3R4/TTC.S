.global ttc0_clk_conf
.global ttc0_set_div
.global tcc0_clk_setup
.global tcc0_reset
.global tcc0_en_itvl
.global tcc0_set_itvl
.global ttc0_en_itvl_int
.global poll_timer
.global init_ttc_stopwatch

@ Addresses
.equ TTC0_BASE, 	0xF8001000	@ ttc0 clock control reg
.equ TTC0_CLKCTL_OFF,	0x0
.equ TTC0_CNTCTL_OFF,	0xC		@ ttc0 count 1 control
.equ TTC0_ITVL_OFF,	0x24		@ ttc0 interval 1 reg
.equ TTC0_IER_OFF,	0x60		@ ttc0 IER (interrupt enable)
.equ TTC0_ISR_OFF,	0x54		@ ttc0 ISR (interrupt status)

@ Constants used to setup timer
.equ div_mask,	0xFFFFFFE1 	@ mask to clear only bits 4:1
.equ cnt_dis_rst, 0x11		@ settings to disable and reset counter
.equ cnt_en_itvl, 0x22		@ settings to enable counter in interval mode
.equ intvl_int_en, 0x1		@ settings to enable interrupt signal so it can be read
.equ prescale, 0x9
.equ interval, 0x6C

@ configures TTC0 to use prescale and pclk
@ sets div_value to 0 (div pclk by 2)
ttc0_clk_conf:
	ldr r1, =(TTC0_BASE+TTC0_CLKCTL_OFF)	@ load address of clock control reg
	mov r0, #1
	str r0, [r1]
	bx lr

@ sets the clock divider for
@ takes r0 as 4-bit prescale value
@ sets bits 4:1 in the TTC clock control register
ttc0_set_div:
	ldr r2, =TTC0_BASE
	ldr r1, [r2] 		@ get current conf
	ldr r3, =div_mask	@ load mask
	and r1, r3, r1 		@ mask out div bits
	and r0, r0, #0xF	@ mask out all but 4 LSB
	lsl r0,r0, #1		@ shift left one (align div bits)
	orr r1,r0, r1		@ combine r0,r1
	str r1, [r2]		@ write new conf
	bx lr

@ NOTE: The above two code segments illustrate how individual
@ bit fields in control registers can be set without inadvertently
@ changing bits in neighboring fields. In this project, you can set
@ the seven bits in the CLK_CNTRL register to "0010011" to enable prescale,
@ set a prescale divide constant of 9, and select the positive edge of the PC
@ clock as the clock source. The code below does this in a simplified fashion.
ttc0_clk_setup:
	ldr r1, =TTC0_BASE	@ load TTC0 base register address into R1
	mov r0, #0b0010011	@ r0 <- bit settings to divide PC clock by 2^10
	str r0, [r1]		@ store bits into TTC0 base register
	bx lr

@ resets and disables TTC0 counter 1
@ the counter must be reenabled manually
ttc0_reset:
	ldr r1, =(TTC0_BASE + TTC0_CNTCTL_OFF)
	mov r0, #cnt_dis_rst	@ assert reset
	str r0,[r1]		@ store constant
	bx lr

@ sets TTC0 counter 1 as enabled in interval mode
ttc0_en_itvl:
	ldr r1, =(TTC0_BASE + TTC0_CNTCTL_OFF)
	mov r0, #cnt_en_itvl	@ enable interval mode
	str r0, [r1]
	bx lr

@ takes in interval value (16-bit) as parameter
@ in r0, writes to itvl register
ttc0_set_itvl:
	ldr r1,=(TTC0_BASE+TTC0_ITVL_OFF)
	str r0, [r1]	@ store value
	bx lr

@ enables ttc0 interval interrupts
@ no parameter
ttc0_en_itvl_int:
	ldr r1, =(TTC0_BASE+TTC0_IER_OFF)
	mov r0, #intvl_int_en
	str r0, [r1]
	bx lr

poll_timer:
	ldr r3,=(TTC0_BASE+TTC0_ISR_OFF)
	ldr r1,[r3]
	and r1,#0b1 // mask r1 only for LSB
poll_secondary:
	ldr r2,[r3]
	and r2,#0b1 // mask r2 only for LSB
	cmp r1,r2
	beq poll_secondary
	bx lr

init_ttc_stopwatch:
push {r0-r3, lr}
	bl ttc0_reset // disable counter
	bl ttc0_clk_conf // configure timer clock
	mov r0, #prescale
	bl ttc0_set_div // set prescale
	ldr r0, =interval
	bl ttc0_set_itvl // set interval
	bl ttc0_en_itvl_int // enable interrupt flag
	bl ttc0_en_itvl // enable timer in interval mode
	pop {r0-r3, lr}
	bx lr
