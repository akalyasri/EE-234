#ifndef SRC_GPIO_H_
#define SRC_GPIO_H_

#include <stdint.h>

//GPIO Configuration registers
//output data register
#define GPIO_DATA(n)		*(((uint32_t*) 0xE000A040)+n)
//input data register
#define GPIO_DATA_RO(n) 	*(((uint32_t*) 0xE000A060)+n)
//direction register
#define GPIO_DIRM(n) 		*(((uint32_t*) 0xE000A204) + 16*n)
//output enable register
#define GPIO_OEN(n) 		*(((uint32_t*) 0xE000A208) + 16*n)
//RGB LED channels are bits 16-18, in bank 0
#define RGB_MASK 0x70000

//interrupt mask readonly reg
#define GPIO_INT_MASK(n)	*(((uint32_t *) 0xE000A20C) + 16*(n))
//interrupt enable
#define GPIO_INT_EN(n)		*(((uint32_t *) 0xE000A210) + 16*(n))
//interrupt disable
#define GPIO_INT_DIS(n)		*(((uint32_t *) 0xE000A214) + 16*(n))
//interrupt status register
#define GPIO_INT_STAT(n)	*(((uint32_t *) 0xE000A218) + 16*(n))
//interrupt edge/level sensitivity register
#define GPIO_INT_TYPE(n)	*(((uint32_t *) 0xE000A21C) + 16*(n))
//interrupt polarity register
#define GPIO_INT_POL(n)		*(((uint32_t *) 0xE000A220) + 16*(n))
//interrupt any edge register
#define GPIO_INT_ANY(n)		*(((uint32_t *) 0xE000A224) + 16*(n))

//btn4 is 18 in bank 1, btn5 is 19 in bank 1
//define bit masks for easy access in banks
#define BT4_MASK 0x40000
#define BT5_MASK 0x80000
//define the bank the buttons are in
#define BT4_BANK 1
#define BT5_BANK 1

#define RGB_LED 0x43C00000

int get_btn4_flag();

int get_btn5_flag();

void clear_btn4_flag();

void clear_btn5_flag();

void configure_button_interrupts();

uint32_t get_GPIO_int_status(int bank, uint32_t mask);

void clear_GPIO_int_status(int bank, uint32_t mask);

void init_GPIO_RGB();

void rgb_on();

void rgb_off();


#endif /* SRC_GPIO_H_ */
