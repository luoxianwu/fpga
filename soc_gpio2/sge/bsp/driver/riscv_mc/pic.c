/*   ==================================================================

     >>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
     ------------------------------------------------------------------
     Copyright (c) 2019-2025 by Lattice Semiconductor Corporation
     ALL RIGHTS RESERVED
     ------------------------------------------------------------------

       IMPORTANT: THIS FILE IS USED BY OR GENERATED BY the LATTICE PROPEL™
       DEVELOPMENT SUITE, WHICH INCLUDES PROPEL BUILDER AND PROPEL SDK.

       Lattice grants permission to use this code pursuant to the
       terms of the Lattice Propel License Agreement.

     DISCLAIMER:

    LATTICE MAKES NO WARRANTIES ON THIS FILE OR ITS CONTENTS,
    WHETHER EXPRESSED, IMPLIED, STATUTORY,
    OR IN ANY PROVISION OF THE LATTICE PROPEL LICENSE AGREEMENT OR
    COMMUNICATION WITH LICENSEE,
    AND LATTICE SPECIFICALLY DISCLAIMS ANY IMPLIED WARRANTY OF
    MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.
    LATTICE DOES NOT WARRANT THAT THE FUNCTIONS CONTAINED HEREIN WILL MEET
    LICENSEE 'S REQUIREMENTS, OR THAT LICENSEE' S OPERATION OF ANY DEVICE,
    SOFTWARE OR SYSTEM USING THIS FILE OR ITS CONTENTS WILL BE
    UNINTERRUPTED OR ERROR FREE,
    OR THAT DEFECTS HEREIN WILL BE CORRECTED.
    LICENSEE ASSUMES RESPONSIBILITY FOR SELECTION OF MATERIALS TO ACHIEVE
    ITS INTENDED RESULTS, AND FOR THE PROPER INSTALLATION, USE,
    AND RESULTS OBTAINED THEREFROM.
    LICENSEE ASSUMES THE ENTIRE RISK OF THE FILE AND ITS CONTENTS PROVING
    DEFECTIVE OR FAILING TO PERFORM PROPERLY AND IN SUCH EVENT,
    LICENSEE SHALL ASSUME THE ENTIRE COST AND RISK OF ANY REPAIR, SERVICE,
    CORRECTION,
    OR ANY OTHER LIABILITIES OR DAMAGES CAUSED BY OR ASSOCIATED WITH THE
    SOFTWARE.IN NO EVENT SHALL LATTICE BE LIABLE TO ANY PARTY FOR DIRECT,
    INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES,
    INCLUDING LOST PROFITS,
    ARISING OUT OF THE USE OF THIS FILE OR ITS CONTENTS,
    EVEN IF LATTICE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
    LATTICE 'S SOLE LIABILITY, AND LICENSEE' S SOLE REMEDY,
    IS SET FORTH ABOVE.
    LATTICE DOES NOT WARRANT OR REPRESENT THAT THIS FILE,
    ITS CONTENTS OR USE THEREOF DOES NOT INFRINGE ON THIRD PARTIES'
    INTELLECTUAL PROPERTY RIGHTS, INCLUDING ANY PATENT. IT IS THE USER' S
    RESPONSIBILITY TO VERIFY THE USER SOFTWARE DESIGN FOR CONSISTENCY AND
    FUNCTIONALITY THROUGH THE USE OF FORMAL SOFTWARE VALIDATION METHODS.
     ------------------------------------------------------------------

     ================================================================== */

#include "pic.h"
#include "reg_access.h"

volatile struct pic_reg *pic_dev;
struct interrupt_entry int_table[S_INT_NUM];

uint8_t pic_init(uint32_t base)
{
	uint32_t idx;
	pic_dev = (struct pic_reg *) base;

	/* init interrupt table */
	for (idx = 0; idx < S_INT_NUM; idx++) {
		int_table[idx].context = NULL;
		int_table[idx].isr = NULL;
	}

	/*disable/clear all of the external interrupts */
	pic_dev->pic_status = 0xffffffff;
	pic_dev->pic_en = 0;

	/* enable external interrupt */
	__asm__ __volatile__("csrw mie, %0"::"r"(0x800));

	/* enable interrupts */
	__asm__ __volatile__("csrw mstatus, %0"::"r"(0x1808));
	return 0;
}

uint8_t pic_int_enable(uint8_t src)
{
	pic_dev->pic_en |= 1 << (src);
	return 0;
}

uint8_t pic_int_disable(uint8_t src)
{
	pic_dev->pic_en &= (~(1 << src));
	return 0;
}

uint8_t pic_int_clear(uint8_t src)
{
	pic_dev->pic_status = 1 << (src);
	return 0;
}

uint8_t pic_int_pending(uint8_t src)
{
	uint32_t ifr = pic_dev->pic_status;

	if (ifr & (1 << src)) {
		return 1;
	}

	return 0;
}

uint8_t pic_int_polarity_set(uint8_t src, uint8_t bit)
{
	/* bit 1 means active low, otherwise,active high */
	if (bit) {
		pic_dev->pic_pol = 0 << src;
	} else {
		pic_dev->pic_pol = 1 << src;
	}
	return 0;
}

uint8_t pic_int_polarity_get(uint8_t src, uint8_t *pol)
{

	*pol = (pic_dev->pic_pol >> src) & 0x01;
	return 0;
}

uint8_t pic_int_status_get(uint32_t *status)
{
	*status = pic_dev->pic_status;
	return 0;
}

uint8_t pic_isr_register(uint8_t src, void (*isr) (void *),
			       void *context)
{
	if (src >= S_INT_NUM) {
		return 1;
	}
	if (NULL == context) {
		return 1;
	}

	/* register on the isr */
	int_table[src].isr = isr;
	int_table[src].context = context;

	/* mask on the interrupt source */
	pic_int_enable(src);

	return 0;
}
