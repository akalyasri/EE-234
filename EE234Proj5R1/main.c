#include "proj5.h"
#include "uart.h"
#include "interrupts.h"
#include "GPIO.h"
#include <xil_exception.h>

#define UART1_INT_ID 82

void my_handler();

int main(void)
{
	//setup UART
	configure_uart1();


	//configure interrupt system below
	disable_arm_interrupts();
	Xil_ExceptionRegisterHandler(5, my_handler, NULL);
	configure_GIC_interrupt82();
	configure_uart1_interrupt();
	enable_arm_interrupts();


	//endless loop
	for(;;);
}

void my_handler()
{
	uint32_t id;

	//get interrupt id
	id = ICCIAR;

	switch(id) {

	case UART1_INT_ID:
		service_uart1_int();
		break;

	default:
		break;
	}


	//inform GIC that this interrupt has ended
	ICCEOIR = id;
}
