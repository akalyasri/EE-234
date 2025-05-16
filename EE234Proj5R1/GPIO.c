#include "GPIO.h"

void set_GPIO_output(int n, uint32_t mask) {
	GPIO_DIRM(n) |= mask;
}

//sets the channels in the mask, in bank n, as inputs
void set_GPIO_input(int n, uint32_t mask) {
	GPIO_DIRM(n) &= ~mask;
}

//gets the value of only the bits in the mask
int read_GPIO_input(int n, uint32_t mask) {
	return (GPIO_DATA_RO(n) & mask);
}


//disables interrupts for channels set in the mask, for the given bank
void disable_GPIO_interrupt(int bank, uint32_t mask) {
	GPIO_INT_DIS(bank) = mask;
}

//enables interrupts for channels set in the mask, for the given bank
void enable_GPIO_interrupt(int bank, uint32_t mask) {
	GPIO_INT_EN(bank) = mask;
}

//sets int sensitivity of the channels set in the mask to level-sensitive
void set_GPIO_int_level_sens(int bank, uint32_t mask) {
	GPIO_INT_TYPE(bank) &= ~mask;
}
//sets int sensitivity of the channels set in the mask to edge-sensitive
void set_GPIO_int_edge_sens(int bank, uint32_t mask) {
	GPIO_INT_TYPE(bank) |= mask;
}

//sets polarity of the channels set in the mask to high
void set_GPIO_int_pol_high(int bank, uint32_t mask) {
	GPIO_INT_POL(bank) |= mask;
}

//sets polarity of the channels set in the mask to high
void set_GPIO_int_pol_low(int bank, uint32_t mask) {
	GPIO_INT_POL(bank) &= ~mask;
}

//sets edges of the channels set in the mask to both (if edge sensitive)
void set_GPIO_int_any_edge(int bank, uint32_t mask) {
	GPIO_INT_ANY(bank) |= mask;
}

//sets edges of the channels set in the mask to only specified edge [from pol] (if edge sensitive)
void clear_GPIO_int_any_edge(int bank, uint32_t mask) {
	GPIO_INT_ANY(bank) &= ~mask;
}

//clears the fields in given bank's int flag reg, based on the mask
void clear_GPIO_int_status(int bank, uint32_t mask) {
	GPIO_INT_STAT(bank) = mask;
}

// returns the given bank's interrupt flags, masked by the 2nd parameter
uint32_t get_GPIO_int_status(int bank, uint32_t mask) {
	return GPIO_INT_STAT(bank) & mask;
}




//configures the GPIO module to generate interrupts for
void configure_button_interrupts() {


	//disable all GPIO interrupts
	disable_GPIO_interrupt(BT4_BANK, BT4_MASK | BT5_MASK);


	//set buttons 4 and 5 to edge sensitive
	set_GPIO_int_edge_sens(BT4_BANK, BT4_MASK | BT5_MASK);

	//set button 4 to rising edge interrupts
	set_GPIO_int_pol_high(BT4_BANK, BT4_MASK);

	//set button 5 to falling edge interrupts
	set_GPIO_int_pol_low(BT5_BANK, BT5_MASK);

	//set so only use the defined edge
	clear_GPIO_int_any_edge(BT4_BANK, BT4_MASK | BT5_MASK);

	//clear interrupt flags for button 4 and 5
	clear_GPIO_int_status(BT4_BANK, BT4_MASK | BT5_MASK);

	//enable interrupts for button 4 and 5
	enable_GPIO_interrupt(BT4_BANK, BT4_MASK|BT5_MASK);
}
