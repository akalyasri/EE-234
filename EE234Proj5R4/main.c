#include "proj5.h"
#include "uart.h"
#include "interrupts.h"
#include "GPIO.h"
#include "GTC.h"
#include <xil_exception.h>

#define UART1_INT_ID 82
#define GPIO_INT_ID 52
#define TTC_INT_ID 27

volatile int btn_4_flag;
volatile int btn_5_flag;
volatile int uart_flag;
/*
 * uart flag 1: UART
 * uart flag 2: GPIO
 * uart flag 3: TTC
 */

void my_handler();

int main(void)
{
	// Initialize flags: btn4 and btn5 needed because flags need to be cleared for interrupt return for requirement 2
	uart_flag = 0;
	btn_4_flag = 0;
	btn_5_flag = 0;

	// Needed for requirement 3
	int count = 0;
	char countArr[15] = { '\0' }; // initialize empty string

	//setup UART - Uncomment for requirement 1 and 3
	configure_uart1();

	// setup RGB - Uncomment for requirement 2
	//init_GPIO_RGB();

	//setup GTC - Uncomment for requirement 3
	configure_gtc_interrupt();

	//configure interrupt system below
	disable_arm_interrupts();
	Xil_ExceptionRegisterHandler(5, my_handler, NULL);
	//configure_GIC_interrupt82(); // Uncomment for req 1
	//configure_GIC_interrupt52(); // Uncomment for req 2
	configure_GIC_interrupt27(); // Uncomment for req 3
	//configure_button_interrupts(); // Uncomment for req 2
	configure_uart1_interrupt(); // Uncomment for req 1 and 3
	enable_arm_interrupts();

	//endless loop
	while(1) {
		switch(uart_flag) {
		case 1:
			service_uart1_int();
			uart_flag = 0;
			break;
		case 2:
			if (btn_4_flag != 0) { // on
				rgb_on();
			} else if (btn_5_flag != 0) { // off
				rgb_off();
			}
			uart_flag = 0;
			break;
		case 3:
			// send count value over UART
			// increment counter
			sprintf(countArr, "%d", count); // convert current count to string
			uart1_sendstr(countArr);
			uart1_sendchar('\n');
			count++;
			uart_flag = 0;

			break;
		default:
			break;
		}
	}
}

void my_handler()
{

	uint32_t id;
	//get interrupt id
	id = ICCIAR;

	switch(id) {

	case UART1_INT_ID:
		uart_flag = 1;
		clear_uart1_int_flags();	//clear flags
		break;

	case GPIO_INT_ID:
		uart_flag = 2;
		btn_4_flag = get_btn4_flag();
		btn_5_flag = get_btn5_flag();
		clear_btn4_flag();
		clear_btn5_flag();
		break;

	case TTC_INT_ID:
		uart_flag = 3;
		clear_gtc_int_flags();
		break;

	default:
		break;
	}


	//inform GIC that this interrupt has ended
	ICCEOIR = id;
}
