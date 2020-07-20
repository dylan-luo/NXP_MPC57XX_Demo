/*
 * Copyright (c) 2013 - 2015, Freescale Semiconductor, Inc.
 * Copyright 2016-2019 NXP
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED BY NXP "AS IS" AND ANY EXPRESSED OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL NXP OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */
/* ###################################################################
**     Filename    : clk.c/h
**     Processor   : MPC57xx
**     Abstract    :
**         Clock module.
**         This module contains clock initialization.
**     Settings    :
**     Contents    :
**         No public methods
**
** ###################################################################*/
/*!
** @file clk.c/h
** @version 01.01
** @brief
**         Clock module.
**         Added user callback function during clocks change.
** @version 01.00
** @brief
**         Clock module.
**         This module contains clock initialization.
*/

/*******************************************************************************
 * Includes
 ******************************************************************************/
 
#include "clk.h"

#include "clockMan1.h"

/*FUNCTION**********************************************************************
 *
 * Function Name : clockMan1_StaticCallback0
 * Description   : User callback function during clocks change.
 *
 * Implements    : clockMan1_StaticCallback0_Activity
 *END**************************************************************************/
status_t clockMan1_StaticCallback0(clock_notify_struct_t * notify, 
                                   void * callbackData)
{
    status_t ret = STATUS_SUCCESS;
    static uint8_t s_clock_error_count = 0;

    /* Write your code here */
    ++s_clock_error_count;

    return ret;
}   /*clockMan1_StaticCallback0()*/

/*FUNCTION**********************************************************************
 *
 * Function Name : CLOCK_Init
 * Description   : Initialize and configure clocks.
 * Setup system clocks, dividers.
 * Configure all used peripherals clock.
 *
 * Implements    : CLOCK_Init_Activity
 *END**************************************************************************/
status_t CLOCK_Init(void)
{
	status_t ret = STATUS_SUCCESS;

    /*SYS_CLK = 150MHz, output with PJ[1]*/
    /*FXBAR_CLK = 2*SXBAR_CLK*/
    /*SXBAR_CLK = 2*PBRIDGEx_CLK*/
    /*LIN_CLK   = 2*PBRIDGEx_CLK*/
	ret = CLOCK_SYS_Init(g_clockManConfigsArr, CLOCK_MANAGER_CONFIG_CNT,
                   	     g_clockManCallbacksArr, CLOCK_MANAGER_CALLBACK_CNT);
	if (STATUS_SUCCESS == ret)
	{
		ret = CLOCK_SYS_UpdateConfiguration(0U, CLOCK_MANAGER_POLICY_FORCIBLE);
	}

	return ret;
}   /*CLOCK_Init()*/

/*******************************************************************************
 * EOF
 ******************************************************************************/
