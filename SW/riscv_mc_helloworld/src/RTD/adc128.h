

#ifndef __ADC128__
#define __ADC128__

#include <stdint.h>

typedef struct {
    volatile uint32_t RDWR_DATA_REG;       // 0x0000 Read & Write Data Register
    volatile uint32_t CHP_SEL_REG;         // 0x0004 Chip Select Register (RW)
    volatile uint32_t CFG_REG;             // 0x0008 Configuration Register (RW)
    volatile uint32_t CLK_PRESCL_REG;      // 0x000C Clock Prescaler Lower Register (RW)
    volatile uint32_t CLK_PRESCH_REG;      // 0x0010 Clock Prescaler Higher Register (RW)
    volatile uint32_t INT_STATUS_REG;      // 0x0014 Interrupt Status Register (RW)
    volatile uint32_t INT_ENABLE_REG;      // 0x0018 Interrupt Enable Register (RW)
    volatile uint32_t INT_SET_REG;         // 0x001C Interrupt Set Register (WO)
    volatile const uint32_t WORD_CNT_REG;  // 0x0020 Word Count Register (RO)
    volatile uint32_t WORD_CNT_RST_REG;    // 0x0024 Word Count Reset Register (WO)
    volatile uint32_t TGT_WORD_CNT_REG;    // 0x0028 Target Word Count Register (RW)
    volatile uint32_t FIFO_RST_REG;        // 0x002C FIFO Reset Register (WO)
    volatile uint32_t CHP_SEL_POL_REG;     // 0x0030 Chip Select Polarity Register (RW)
    volatile const uint32_t FIFO_STATUS_REG; // 0x0034 FIFO Status Register (RO)
    volatile uint32_t SPI_ENABLE_REG;      // 0x0038 SPI Enable Register (RW)
} SPI_Registers;


// Bit masks for FIFO_STATUS_REG
#define RX_FIFO_EMPTY   (1 << 0)
#define RX_FIFO_AFULL   (1 << 1)
#define RX_FIFO_FULL    (1 << 2)
#define TX_FIFO_EMPTY   (1 << 3)
#define TX_FIFO_AEMPTY  (1 << 4)
#define TX_FIFO_FULL    (1 << 5)

int adc128_read(int channel, uint16_t* rx_buf, int cnt );


#endif //__ADC128__
