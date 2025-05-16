#include <stdint.h>
#include <stdio.h>

extern void receive_string(char c1, char dest[], char c2, int max_size);
extern void send_string(char c, char src[]);

char unknown_string[128];

int main(void) {

	receive_string('\0', unknown_string, '\0', 127);
	send_string('\0', unknown_string);
	
    for(;;);	

	return 1;
}
