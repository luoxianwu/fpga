/*
 * ADC128S102 8-Channel, 500-ksps to 1-Msps, 12-Bit A/D Converter
 */
#include "sys_platform.h"
#include "spi_master.h"
#include "adc128.h"
#include <stdio.h>
#include "ispace.h"

SPI_Registers spi_mast_regs;


/*
 * there are 32 channel Max.
 */

int adc128_read_rtd(int channel, unsigned short* rx_buf ){
	ASSERT(channel<32); // valid 0--31, corespons to 32 RTDs
	//each ADC128 red 8 channels, assume RTD is on channel 0,1,2,3
	int chip_select = channel/8;
	SPI->CHP_SEL_REG = 1 << chip_select;

	int channel_in_chip = channel%8;
	uint16_t slave_addr = channel_in_chip << 11;	  //spi slave address

	SPI->INT_ENABLE_REG = 0x80; // transfer complete

	//set word count
	SPI->TGT_WORD_CNT_REG = 1; // 2 bytes (16 bits) per channel

	//reset word count
	SPI->WORD_CNT_RST_REG = 0xFF;

	//clean spi tx, rx fifo buffer
	SPI->FIFO_RST_REG = 0b11;

	SPI->RDWR_DATA_REG = slave_addr;
	//SPI->RDWR_DATA_REG = slave_addr;
/*
	//while( SPI->FIFO_STATUS_REG & RX_FIFO_EMPTY ); // wait for data in
	while( (SPI->INT_STATUS_REG & INT_ENABLE_TR_CMP_EN) == 0);
	uint32_t v = SPI->RDWR_DATA_REG;
	SPI->INT_SET_REG = 0; // clean intr status
*/

	printf("int status = 0x%x\n", SPI->INT_STATUS_REG);

	// deselect chip
	SPI->CHP_SEL_REG = 0;

	return 0;
}




