#include "uart.h"

//configures UART1 for 115200 baud, 8-data bits, no parity, 1 stop bit.
void configure_uart1() {
	uint32_t *datapath;
	reset_uart1(); // reused assembly subroutine
	datapath = (uint32_t *)UART1_MR;
	*datapath = 32; // write 32 to UART1_MR
	datapath = (uint32_t *)UART1_CR;
	*datapath = 20; // enable tx and rx

	// Generate baudgen 115200
	datapath = (uint32_t *)UART1_BAUDGEN;
	*datapath = 124; // 0x7C

	datapath = (uint32_t *)UART1_BAUDDIV;
	*datapath = 6;
}

//returns next received character from uart.
//Blocks until character available.
char uart1_getchar() {
	uint32_t *datapath;
	uint32_t temp_data;
	do {
		datapath = (uint32_t *)UART1_SR;
		temp_data = *datapath;
		temp_data &= 2; // clear all but second bit
	} while (temp_data == 2);
	datapath = (uint32_t *)UART1_FIFO;
	temp_data = *datapath;
	return temp_data; // load character from FIFO
}

//Sends 'data' over uart.
//Blocks until data is placed in transmit FIFO.
void uart1_sendchar(char data) {
	uint32_t *datapath;
	uint32_t temp_data;
	do {
		datapath = (uint32_t *)UART1_SR;
		temp_data = *datapath;
		temp_data &= 16; // clear all but 4th bit
	} while (temp_data == 16);
	datapath = (uint32_t *)UART1_FIFO;
	*datapath = data; // write data to address
}

//sends the null-terminated string in 'buffer' through uart1
void uart1_sendstr(char buffer[]) {
	int i = 0;
	while (buffer[i] != '\0') {
		uart1_sendchar(buffer[i]);
		i++;
	}
	// last character should be null and is also stored
	//uart1_sendchar(buffer[i]);
}

/***
* Receives characters from uart and copies into 'buffer'.
* Returns when a newline is encountered or the max
* number of characters, 'max', have been received.
* Newline is not copied and string is always
* terminated with a null character.
* Function returns the number of characters copied
***/
int uart1_getln(char buffer[], int max) {
	int i = 0;
	for (; i < max; i++) {
		char process = uart1_getchar();
		if (process != 13) {
			buffer[i] = process;
		} else {
			buffer[i] = '\0';
			break;
		}
	}
	return i;
}
