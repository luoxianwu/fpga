/*
 *
 */

#ifndef __ISPACE__
#define __ISPACE__

//external interrupt connected. see cpu0_inst in HW design,
//and PIC_STATUS register
#define EXT_INT_STATUS_UART   (1<<0)
#define EXT_INT_STATUS_GPIO   (1<<1)
#define EXT_INT_STATUS_SPI    (1<<2)
#define EXT_INT_TOTAL  3

#define ASSERT(x) \
    if(!(x)) {printf(#x ", assert failed!\n");while(1);}

#define LOG_X(v) printf("%s = 0x%x\n", #v, v)

#endif //__ISPACE__
