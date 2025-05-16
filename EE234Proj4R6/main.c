#include "uart.h"

char unknown_string[128];

int main(void) {
    configure_uart1();

    // Receive a string via UART and store it in unknown_string
    int chars_copied = uart1_getln(unknown_string, 127);

    // Send the received string back through UART
    uart1_sendstr(unknown_string);

    for (;;); // Infinite loop

    return 1;
}
