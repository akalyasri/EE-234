#include "proj5.h"
#include "uart.h"
#include "interrupts.h"
#include "GPIO.h"
#include "GTC.h"
#include <xil_exception.h>

#define UART1_INT_ID 82
#define GPIO_INT_ID 52
#define TTC_INT_ID 27

volatile int max_n_cycles;
volatile int cycle_counter;
volatile int running;

void my_handler();
int get_cycles(void);

int main(void)
{

	max_n_cycles = 0;
	cycle_counter = 0;
	running = 0;

	//configure interrupt system below
	disable_arm_interrupts();
	Xil_ExceptionRegisterHandler(5, my_handler, NULL);

	init_GPIO_RGB();
	configure_uart1();

	uart1_sendstr("Enter how many times the button should turn on [1-9]: ");

	configure_button_interrupts(); // Uncomment for req 2
	configure_uart1_interrupt(); // Uncomment for req 1 and 3
	configure_gtc_interrupt();

	configure_GIC_interrupt82(); // Uncomment for req 1
	configure_GIC_interrupt52(); // Uncomment for req 2
	configure_GIC_interrupt27(); // Uncomment for req 3

	enable_arm_interrupts();

	disable_interrupt27(); // disable timer interrupts to start

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
		max_n_cycles = get_cycles();
		cycle_counter = max_n_cycles * 2; // cycle counter decrements every toggle, so needs twice the max
		clear_uart1_int_flags();	//clear flags
		//configure_GIC_interrupt52(); // configure for GPIO interrupts, enable GPIO interrupts?
		disable_interrupt27();
		disable_interrupt82();
		// disable UART interrupts?
		break;

	case GPIO_INT_ID:
		if ((get_btn4_flag() != 0) && (!running)) { // start button is pressed, system is stopped
			running = 1;
		}
		if ((get_btn5_flag() != 0) && (running)) { // stop button is pressed, system is running
			running = 0;
		}
		if (running && cycle_counter != 0) {
			// enable TTC
			enable_interrupt27();
		} else if (!running || cycle_counter == 0) { // manually stopped
			// disable TTC
			uart1_sendstr("Stopped blinking\n");
			disable_interrupt27();
			cycle_counter = max_n_cycles * 2; // reset cycle counter
			rgb_off();
			running = 0;
		}
		clear_btn4_flag();
		clear_btn5_flag();
		break;

	case TTC_INT_ID:
		if (cycle_counter == max_n_cycles * 2) {
			uart1_sendstr("Started blinking\n");
		}
		if (cycle_counter == 0) { // reached end of cycle counter
			uart1_sendstr("Stopped blinking\n");
			cycle_counter = max_n_cycles * 2; // reset cycle counter
			disable_interrupt27(); // only do this once
			running = 0;
			break;
		}
		rgb_toggle();
		cycle_counter--;
		clear_gtc_int_flags();
		break;

	default:
		break;
	}


	//inform GIC that this interrupt has ended
	ICCEOIR = id;
}

int get_cycles(void) {
	char num_cycles = uart1_getchar();
	if (num_cycles == 13) { // ignore newlines
		return max_n_cycles;
	}
	uart1_sendchar(num_cycles);
	uart1_sendchar('\n');
	uart1_sendstr("Press btn4 to start, btn5 to stop.\n");
	return (num_cycles - 48); // return integer equivalent of ASCII
}
