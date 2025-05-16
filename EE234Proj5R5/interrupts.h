#ifndef SRC_INTERRUPTS_H_
#define SRC_INTERRUPTS_H_

#include <stdint.h>

//definitions for GIC configuration registers
#define ICCPMR	*((uint32_t *) 0xF8F00104)	//Priority mask reg
#define ICCICR	*((uint32_t *) 0xF8F00100)	//CPU interface control reg
#define ICDDCR	*((uint32_t *) 0xF8F01000)	//Distributor Control reg
#define ICDISER(n)	*(((uint32_t *) 0xF8F01100) + n )	//Int. set enable reg
#define ICDICER(n)	*(((uint32_t *) 0xF8F01180) + n )	//Int. Clear Enable reg
#define ICDIPR(n)	*(((uint32_t *) 0xF8F01400) + n )	//Int. Priority reg
#define ICDIPTR(n)	*(((uint32_t *) 0xF8F01800) + n )	//Int. Processor Targets reg
#define ICDICFR(n)	*(((uint32_t *) 0xF8F01C00) + n )	//Int. Configuration reg

#define ICCIAR *((uint32_t *) 0xF8F0010C)
#define ICCEOIR *((uint32_t *) 0xF8F00110)

#define UART1_IER	*((uint32_t *) 0xE0001008)
#define UART1_IDR	*((uint32_t *) 0xE000100C)
#define UART1_ISR	*((uint32_t *) 0xE0001014)
#define UART1_RXTG	*((uint32_t *) 0xE0001020)

void disable_arm_interrupts(void);
void enable_arm_interrupts(void);
void configure_GIC_interrupt52(void);
void configure_GIC_interrupt82(void);
void configure_GIC_interrupt27(void);
void configure_uart1_interrupt(void);
void clear_uart1_int_flags(void);
void service_uart1_int(void);

// disable and enable specific GIC interrupts
void disable_interrupt27(void); // GTC
void disable_interrupt52(void); // GPIO
void disable_interrupt82(void); // UART
void enable_interrupt27(void); // GTC
void enable_interrupt52(void); // GPIO
void enable_interrupt82(void); // UART

#endif /* SRC_INTERRUPTS_H_ */
