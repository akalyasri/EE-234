#include "GTC.h"

void disable_gtc_out(void) {
	GTC_CR = 0; // disable output
}

void enable_gtc_out(void) {
	// enables interrupts and output 5, 7, 15
	GTC_CR = 15;
}

void write_gtc_compare(void) {
	GTC_COMP0 = 0x13DE4355; // 333333333 to compare value (counts to this value in approx. 1 sec)
}

void write_gtc_auto(void) {
	GTC_AI = 0x13DE4355; // auto-increment by same amt, ~1s delay between interrupts
}

void reset_gtc_count(void) {
	GTC_DR0 = 0;
}

//clears all GTC interrupt flags
void clear_gtc_int_flags(void)
{
	GTC_ISR = GTC_ISR;
}

void configure_gtc_interrupt(void) {
	disable_gtc_out(); // disables gtc for config
	write_gtc_compare();
	write_gtc_auto();
	enable_gtc_out();
}
