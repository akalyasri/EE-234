#include "proj5.h"
#include "uart.h"
#include "interrupts.h"
#include "GPIO.h"
#include <xil_exception.h>

#define UART1_INT_ID 82
#define GPIO_INT_ID 52

void my_handler();

int main(void)
{
	//setup UART
	configure_uart1();

	// setup RGB
	init_GPIO_RGB();

	//configure interrupt system below
	disable_arm_interrupts();
	Xil_ExceptionRegisterHandler(5, my_handler, NULL);
	//configure_GIC_interrupt82();
	configure_GIC_interrupt52();
	configure_button_interrupts();
	//configure_uart1_interrupt();
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

	case GPIO_INT_ID:
		if (get_btn4_flag() != 0) { // on
			rgb_on();
		} else if (get_btn5_flag() != 0) { // off
			rgb_off();
		}
		clear_btn4_flag();
		clear_btn5_flag();
		break;
	default:
		break;
	}


	//inform GIC that this interrupt has ended
	ICCEOIR = id;
}
