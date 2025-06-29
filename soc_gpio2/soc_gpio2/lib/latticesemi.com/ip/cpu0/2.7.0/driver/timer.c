/*   ==================================================================

     >>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
     ------------------------------------------------------------------
     Copyright (c) 2019-2020 by Lattice Semiconductor Corporation
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
#include "timer.h"
#include "pic.h"
#include "reg_access.h"

//struct interrupt_entry intTimer;
extern struct interrupt_entry int_table[S_INT_NUM];

static void timer_isr(void *context)
{
	struct timer_instance *ctx = (struct timer_instance *) context;

	if (ctx->callback) {
		ctx->callback(ctx->userCtx);
	}
	if (ctx->periodic) {
		timer_reload(ctx, ctx->delay);
	}
}

uint8_t timer_init(struct timer_instance *this_timer,
			 uint32_t base_addr, uint32_t cpu_freq)
{
	uint64_t tmp = 1;
	if (NULL == this_timer) {
		return 1;
	}
	this_timer->base_address = base_addr;
	this_timer->cpu_freq = cpu_freq;
	timer_set_mtime(this_timer, tmp);
	return 0;
}

uint8_t timer_start(struct timer_instance *this_timer,
			  void (*callback) (void *), void *userCtx,
			  uint32_t periodic, uint32_t count)
{

	/* Check initial condition */
	uint32_t mie;
	if (NULL == this_timer) {
		return 1;
	}
	this_timer->periodic = periodic;
	this_timer->callback = callback;
	this_timer->userCtx = userCtx;

	int_table[S_INT_TIMER].isr = timer_isr;
	int_table[S_INT_TIMER].context = this_timer;

	this_timer->delay = count;
	timer_reload(this_timer, count);
	/* Enable interrupt */
	//__asm__ __volatile__("csrsi mie, 8");
	__asm__ __volatile__("csrr  %0, mie":"=r"(mie));
	mie = mie | 0x80;
	__asm__ __volatile__("csrw mie, %0"::"r"(mie));

	return 0;
}

uint8_t timer_stop()
{
	uint32_t mie;

	int_table[S_INT_TIMER].isr = NULL;
	int_table[S_INT_TIMER].context = NULL;
	__asm__ __volatile__("csrr  %0, mie":"=r"(mie));
	mie = mie & 0xff7f;
	__asm__ __volatile__("csrw mie, %0"::"r"(mie));
	return 0;
}

uint8_t timer_get_mtime(struct timer_instance *this_timer,
		uint64_t *value)
{
	uint32_t mtime_lo;
	uint32_t mtime_hi;
	uint32_t mtime_hi_check;
	if (NULL == this_timer) {
		return 1;
	}

	while(1)
	{
		reg_32b_read(this_timer->base_address | TIMER_MTIME_HIGH,
				&mtime_hi);
		reg_32b_read(this_timer->base_address | TIMER_MTIME_LOW,
				&mtime_lo);
		reg_32b_read(this_timer->base_address | TIMER_MTIME_HIGH,
				&mtime_hi_check);
		if(mtime_hi == mtime_hi_check)
		{
			*value = ((uint64_t) mtime_hi << 32) | mtime_lo;
			return 0;
		}
	}

	return 0;
}

uint8_t timer_set_mtime(struct timer_instance *this_timer,
		uint64_t value)
{

	uint32_t mtime_lo;
	uint32_t mtime_hi;
	if (NULL == this_timer) {
		return 1;
	}
	mtime_hi = (value >> 32) & 0xffffffff;
	mtime_lo = value & 0xffffffff;
	reg_32b_write(this_timer->base_address | TIMER_MTIME_LOW,
		      mtime_lo);
	reg_32b_write(this_timer->base_address | TIMER_MTIME_HIGH,
		      mtime_hi);

	return 0;
}

uint8_t timer_get_mtimecmp(struct timer_instance *this_timer,
		uint64_t *value)
{
	uint32_t mtimecmp_lo;
	uint32_t mtimecmp_hi;
	if (NULL == this_timer) {
		return 1;
	}
	reg_32b_read(this_timer->base_address | TIMER_MTIMECMP_LOW,
		     &mtimecmp_lo);
	reg_32b_read(this_timer->base_address | TIMER_MTIMECMP_HIGH,
		     &mtimecmp_hi);

	*value =
	    ((uint64_t) mtimecmp_hi << 32) | mtimecmp_lo;

	return 0;
}

uint8_t timer_set_mtimecmp(struct timer_instance *this_timer,
		uint64_t value)
{

	uint32_t mtimecmp_lo;
	uint32_t mtimecmp_hi;
	if (NULL == this_timer) {
		return 1;
	}
	mtimecmp_hi = (value >> 32) & 0xffffffff;
	mtimecmp_lo = value & 0xffffffff;
	reg_32b_write(this_timer->base_address | TIMER_MTIMECMP_LOW,
		      mtimecmp_lo);
	reg_32b_write(this_timer->base_address | TIMER_MTIMECMP_HIGH,
		      mtimecmp_hi);

	return 0;
}

uint8_t timer_reload(struct timer_instance *this_timer,
			   uint32_t delay)
{
	uint64_t tmp;
	if (NULL == this_timer) {
		return 1;
	}
	timer_get_mtimecmp(this_timer, &tmp);
	// 1ms * delay
	tmp += (this_timer->cpu_freq / 1000) * delay;
	timer_set_mtimecmp(this_timer, tmp);

	return 0;
}
