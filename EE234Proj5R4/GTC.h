#ifndef GTC_H
#define GTC_H

#include <stdint.h>

#define GTC_DR0	*((uint32_t *) 0xF8F00200)
#define GTC_DR1	*((uint32_t *) 0xF8F00204)
#define GTC_CR	*((uint32_t *) 0xF8F00208)
#define GTC_ISR	*((uint32_t *) 0xF8F0020C)
#define GTC_COMP0	*((uint32_t *) 0xF8F00210)
#define GTC_COMP1	*((uint32_t *) 0xF8F00214)
#define GTC_AI	*((uint32_t *) 0xF8F00218)

#define TTC0_CLKCNTL	*((uint32_t *) 0xF8001000)
#define TTC0_CNTL		*((uint32_t *) 0xF800100C)
#define TTC0_CNTVAL		*((uint32_t *) 0xF8001018)
#define TTC0_INTVAL		*((uint32_t *) 0xF8001024)
#define TTC0_MATCH		*((uint32_t *) 0xF8001030)
#define TTC0_ISR		*((uint32_t *) 0xF8001054)
#define TTC0_IER		*((uint32_t *) 0xF8001060)
#define TTC0_EVNTCNTL	*((uint32_t *) 0xF800106C)
#define TTC0_EVENT		*((uint32_t *) 0xF8001078)

void configure_gtc_interrupt(void);

void clear_gtc_int_flags(void);

void reset_gtc_count(void);

#endif
