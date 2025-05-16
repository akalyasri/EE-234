#include "GPIO.h"
#include <stdio.h>

void set_GPIO_output(int n, uint32_t mask)
{
	GPIO_DIRM(n) |= mask;
}

//sets the channels in the mask, in bank n, as inputs
void set_GPIO_input(int n, uint32_t mask)
{
	GPIO_DIRM(n) &= ~mask;
}

//gets the value of only the bits in the mask
int read_GPIO_input(int n, uint32_t mask)
{
	return (GPIO_DATA_RO(n) & mask);
}


//disables interrupts for channels set in the mask, for the given bank
void disable_GPIO_interrupt(int bank, uint32_t mask)
{
	GPIO_INT_DIS(bank) = mask;
}

//enables interrupts for channels set in the mask, for the given bank
void enable_GPIO_interrupt(int bank, uint32_t mask)
{
	GPIO_INT_EN(bank) = mask;
}

//sets int sensitivity of the channels set in the mask to level-sensitive
void set_GPIO_int_level_sens(int bank, uint32_t mask)
{
	GPIO_INT_TYPE(bank) &= ~mask;
}
//sets int sensitivity of the channels set in the mask to edge-sensitive
void set_GPIO_int_edge_sens(int bank, uint32_t mask)
{
	GPIO_INT_TYPE(bank) |= mask;
}

//sets polarity of the channels set in the mask to high
void set_GPIO_int_pol_high(int bank, uint32_t mask)
{
	GPIO_INT_POL(bank) |= mask;
}

//sets polarity of the channels set in the mask to high
void set_GPIO_int_pol_low(int bank, uint32_t mask)
{
	GPIO_INT_POL(bank) &= ~mask;
}

//sets edges of the channels set in the mask to both (if edge sensitive)
void set_GPIO_int_any_edge(int bank, uint32_t mask)
{
	GPIO_INT_ANY(bank) |= mask;
}

//sets edges of the channels set in the mask to only specified edge [from pol] (if edge sensitive)
void clear_GPIO_int_any_edge(int bank, uint32_t mask)
{
	GPIO_INT_ANY(bank) &= ~mask;
}

//clears the fields in given bank's int flag reg, based on the mask
void clear_GPIO_int_status(int bank, uint32_t mask)
{
	GPIO_INT_STAT(bank) = mask;
}

// returns the given bank's interrupt flags, masked by the 2nd parameter
uint32_t get_GPIO_int_status(int bank, uint32_t mask)
{
	return GPIO_INT_STAT(bank) & mask;
}

//returns 1 if btn4 interrupt flag is high, 0 if low
int get_btn4_flag()
{
	return 0!=get_GPIO_int_status(BT4_BANK, BT4_MASK);
}

//returns 1 if btn5 interrupt flag is high, 0 if low
int get_btn5_flag()
{
	return 0!=get_GPIO_int_status(BT5_BANK, BT5_MASK);
}

void clear_btn4_flag()
{
	clear_GPIO_int_status(BT4_BANK, BT4_MASK);
}

//same as above, just writing directly to register
void clear_btn5_flag()
{
	clear_GPIO_int_status(BT5_BANK, BT5_MASK);
}

//configures the GPIO module to generate interrupts for
void configure_button_interrupts()
{


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

//configures MIO 16,17,18 as outputs
void set_GPIO_RGB_output()
{
	GPIO_DIRM(0) = RGB_MASK ;
}

//configures MIO 16,17,18 as inputs
void set_GPIO_RGB_input()
{
	GPIO_DIRM(0) &= ~RGB_MASK ;
}

//enables the output of bank0 16,17,18
void en_GPIO_RGB_output(){

	GPIO_OEN(0) |= RGB_MASK ;
}

//disables output of bank0 16-18
void dis_GPIO_RGB_output()
{
	GPIO_OEN(0) &= ~RGB_MASK;
}

//writes the passed value into the 3 outputs for the RGB LED's
void write_GPIO_RGB(uint32_t val)
{
	val = (0x7&val)<<16;	//use only bottom 3 bits, and shift to place
	GPIO_DATA(0) = (GPIO_DATA(0)&~RGB_MASK) | val;	//change only RGB bits
}

//TODO: fix, reading logic is broken
int read_GPIO_RGB(void) {
	return (GPIO_DATA(0)&RGB_MASK)>>16;
}

//Configures RGB Connected GPIO as outputs on channels
//initializes value to zero and enables output
void init_GPIO_RGB()
{
	dis_GPIO_RGB_output();
	set_GPIO_RGB_output();	//configure as output
	write_GPIO_RGB(0);	//clear value of RGBs
	en_GPIO_RGB_output();
}

void rgb_on() {
	write_GPIO_RGB(255);
}

void rgb_off() {
	write_GPIO_RGB(0);
}

void rgb_toggle() {
	if (read_GPIO_RGB() != 0) { // turn off
		write_GPIO_RGB(0);
	} else { // turn on
		write_GPIO_RGB(1);
	}
}

