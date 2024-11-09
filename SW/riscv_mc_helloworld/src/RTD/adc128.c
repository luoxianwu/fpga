/*
 * ADC128S102 8-Channel, 500-ksps to 1-Msps, 12-Bit A/D Converter
 */
#include "sys_platform.h"
#include "spi_master.h"
#include "adc128.h"
#include <stdio.h>
#include "ispace.h"

SPI_Registers spi_mast_regs;


#define SPI ((SPI_Registers *)SPI_INST_BASE_ADDR)

int adc128_read(int channel, unsigned short* rx_buf, int cnt ){
	ASSERT(channel<32); // valid 0--31, corespons to 32 RTDs
	//each ADC128 red 8 channels,
	int chip_select = channel/8;
	SPI->CHP_SEL_REG = 1 << chip_select;

	int channel_in_chip = channel%8;
	uint16_t slave_addr = channel_in_chip << 11;	  //spi slave address
	//clean spi tx, rx fifo buffer
	SPI->FIFO_RST_REG = 0b11; SPI->FIFO_RST_REG = 0; //?
	//reset word count
	SPI->WORD_CNT_RST_REG = 0xff;
	//set word count
	SPI->TGT_WORD_CNT_REG = 2; //?

	uint32_t st = SPI->FIFO_STATUS_REG;
	uint32_t ct = SPI->WORD_CNT_REG;
	printf("fifo_st = 0x%x\n", st);
	printf("word_ct = %d\n", ct);

	for( int i = 0; i < 32; i++ ){
		SPI->RDWR_DATA_REG = i;
		while( SPI->FIFO_STATUS_REG & RX_FIFO_EMPTY ); // wait for data in
		uint32_t v = SPI->RDWR_DATA_REG;
		st = SPI->FIFO_STATUS_REG;
		ct = SPI->WORD_CNT_REG;
		printf("v == 0x%x\n", v);
		printf("fifo_st = 0x%x\n", st);
		printf("word_ct = %d\n", ct);
	}


	st = SPI->FIFO_STATUS_REG;
	ct = SPI->WORD_CNT_REG;
	printf("fifo_st = 0x%x\n", st);
	printf("word_ct = %d\n", ct);

	uint32_t ret = SPI->RDWR_DATA_REG;
	printf("read back = 0x%d\n", ret);
	rx_buf[0] = (uint16_t)ret;

	// deselect chip
	SPI->CHP_SEL_REG = 0;

	return 0;
}
