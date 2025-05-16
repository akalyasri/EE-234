#include "proj5.h"
#include "uart.h"
#include "interrupts.h"
#include "GPIO.h"
#include "GTC.h"
#include <xil_exception.h>

#define UART1_INT_ID 82
#define GPIO_INT_ID 52
#define TTC_INT_ID 27

volatile int count;
char countArr[15] = { '\0' }; // initialize empty string

void my_handler();

int main(void)
{
	//setup UART
	configure_uart1();

	// setup RGB
	//init_GPIO_RGB();

	//setup GTC
	configure_gtc_interrupt();

	//configure interrupt system below
	disable_arm_interrupts();
	Xil_ExceptionRegisterHandler(5, my_handler, NULL);
	configure_GIC_interrupt27();
	//configure_button_interrupts();
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

	case TTC_INT_ID:
		// send count value over UART
		// increment counter
		sprintf(countArr, "%d", count); // convert current count to string
		uart1_sendstr(countArr);
		uart1_sendchar('\n');
		count++;
		//reset_gtc_count();
		clear_gtc_int_flags();
		break;

	default:
		break;
	}


	//inform GIC that this interrupt has ended
	ICCEOIR = id;
}
