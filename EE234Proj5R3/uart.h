#ifndef UART_H
#define UART_H

#include <stdint.h>

#define LED_CTL			0x4BB00000
#define UART1_CR		0xE0001000
#define UART1_MR		0xE0001004
#define UART1_BAUDGEN	0xE0001018
#define UART1_BAUDDIV	0xE0001034
#define UART1_SR 		0xE000102C
#define UART1_FIFO		0xE0001030

#define UART1_INT_ID 82

extern void reset_uart1();

//configures UART1 for 115200 baud, 8-data bits, no parity, 1 stop bit.
void configure_uart1();

//returns next received character from uart.
//Blocks until character available.
char uart1_getchar();

//Sends 'data' over uart.
//Blocks until data is placed in transmit FIFO.
void uart1_sendchar(char data);

//sends the null-terminated string in 'buffer' through uart1
void uart1_sendstr(char buffer[]);

/***
* Receives characters from uart and copies into 'buffer'.
* Returns when a newline is encountered or the max
* number of characters, 'max', have been received.
* Newline is not copied and string is always
* terminated with a null character.
* Function returns the number of characters copied
***/
int uart1_getln(char buffer[], int max);

void my_handler();

#endif /* UART_H */
