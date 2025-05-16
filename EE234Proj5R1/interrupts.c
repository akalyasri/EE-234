#include "interrupts.h"
#include "uart.h"


//disables the GIC distributor
void disable_gic_dist() { (ICDDCR = 0); };

//enables the GIC distributor
void enable_gic_dist() { (ICDDCR = 1); };

//Drive IRQ from the GIC
void disable_IRQ_passthrough() { (ICCICR =0x3); };

//sets the priority mask to the passed value 'priority'
void set_gic_pmr(uint32_t priority) { ICCPMR = (priority & 0xFF); };

//disables interrupt ID 52
void disable_interrupt52(void)
{
	ICDIPTR(13) &= ~0x3; //remove processors from interrupt
	ICDICER(1) = 0x00100000; //disable interrupts from GPIO module
}

//enables interrupt 52
void enable_interrupt52()
{
	ICDIPTR(13) |= 1; //set bit 1 of ICDIPTR13 (enable for cpu0)
	ICDISER(1) = 0x00100000;
}

//sets the interrupt priority of 52 to ‘priority_val’
void set_interrupt52_priority(uint8_t priority_val)
{
	ICDIPR(13) &= ~0xFF; //clear priority bits for interrupt 52
	ICDIPR(13) |= (priority_val) & 0xF8; //set top 5 bits based on passed value
}

//sets interrupt sensitivity of interrupt52 to ‘sens’
void set_interrupt52_sensitivity(uint8_t sens)
{
	ICDICFR(3) &= ~0x300;
	ICDICFR(3) |= (sens&0x3)<<8;
}


void configure_GIC_interrupt52(void)
{

	//disable and configure GIC
	disable_gic_dist(); //disable GIC interrupt generation
	disable_IRQ_passthrough();	//drive IRQ from GIC

	set_gic_pmr(0xFF); //set priority mask

	//disable and configure interrupt 52
	disable_interrupt52();
	set_interrupt52_priority(0xA0); //set 52’s priority to 160
	set_interrupt52_sensitivity(1); //set to high level

	enable_interrupt52();	//reenable interrupt52

	enable_gic_dist();		//reenable distributor

}

//disables interrupt ID 82
void disable_interrupt82(void)
{
	ICDIPTR(20) &= ~0x30000; //remove processors from interrupt
	ICDICER(2) = 0x00040000; //disable interrupts from GPIO module, bit 18 of 2
}

//enables interrupt 82
void enable_interrupt82()
{
	ICDIPTR(20) |= 0x00010000; //set bit 16 of ICDIPTR20 (enable for cpu0)
	ICDISER(2) = 0x00040000; // bit 18 of 2
}

//sets the interrupt priority of 82 to ‘priority_val’
void set_interrupt82_priority(uint8_t priority_val)
{
	ICDIPR(20) &= ~0xFF0000; //clear priority bits for interrupt 82
	ICDIPR(20) |= (priority_val) & 0xF80000; //set top 5 bits based on passed value
}

//sets interrupt sensitivity of interrupt82 to ‘sens’
void set_interrupt82_sensitivity(uint8_t sens)
{
	ICDICFR(5) &= ~0x30;
	ICDICFR(5) |= (sens&0x3)<<4; // shift 4 to bits 4 and 5 of reg 5
}

void configure_GIC_interrupt82(void)
{

	//disable and configure GIC
	disable_gic_dist(); //disable GIC interrupt generation
	disable_IRQ_passthrough();	//drive IRQ from GIC

	set_gic_pmr(0xFF); //set priority mask

	//disable and configure interrupt 82
	disable_interrupt82();
	set_interrupt82_priority(0xA0); //set 82’s priority to 160
	set_interrupt82_sensitivity(1); //set to high level

	enable_interrupt82();	//reenable interrupt82

	enable_gic_dist();		//reenable distributor

}

void disable_arm_interrupts(void)
{
	uint32_t cpsr_val =0;

	asm("mrs %0, cpsr\n" : "=r" (cpsr_val) );	//get current cpsr

	cpsr_val &= ~(0xFF);	//clear lower 8 bits
	cpsr_val |= 0xDF;	//set all bits but the 'T' bit


	asm("msr cpsr, %0\n" : : "r" (cpsr_val));	//writeback modified value

	return;

}


void enable_arm_interrupts(void)
{

	uint32_t cpsr_val =0;

	asm("mrs %0, cpsr\n" : "=r" (cpsr_val) );	//get current cpsr value

	cpsr_val &= ~(0xFF);	//clear lower 8 bits
	cpsr_val |= 0x5F;	//set all bits but 'T' and 'I' bit


	asm("msr cpsr, %0\n" : : "r" (cpsr_val));	//writeback modified value

	return;

}

void set_uart1_rx_trigger(uint32_t n)
{
	UART1_RXTG = n;
}

void unmask_uart1_rxtg_int(void)
{
	UART1_IER=1;
}

void mask_uart1_rxtg_int(void)
{
	UART1_IDR=1;
}

void enable_uart1_byte_rx_int(void)
{
	set_uart1_rx_trigger(1);
	unmask_uart1_rxtg_int();
}

void configure_uart1_interrupt(void) {
	enable_uart1_byte_rx_int();
}

//clears all UART1 interrupt flags
void clear_uart1_int_flags(void)
{
	UART1_ISR = UART1_ISR;
}

void service_uart1_int(void)
{
	//read until FIFO is empty
	//place in dummy character
	char dummy = uart1_getchar();
	uart1_sendchar(dummy);
	clear_uart1_int_flags();	//clear flags

}
