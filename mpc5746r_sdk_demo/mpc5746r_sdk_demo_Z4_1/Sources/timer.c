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
**     Filename    : timer.c/h
**     Processor   : MPC57xx
**     Abstract    :
**         Timer module.
**         This module contains timer initialization.
**     Settings    :
**     Contents    :
**         No public methods
**
** ###################################################################*/
/*!
** @file timer.c/h
** @version 01.00
** @brief
**         Timer module.
**         This module contains timer initialization.
*/

/*******************************************************************************
 * Includes
 ******************************************************************************/
 
#include "timer.h"

#include <stdint.h>
#include <stdbool.h>

#include "pit1.h"
#include "uart.h"
#include "pins_driver.h"

/*******************************************************************************
 * Definitions
 ******************************************************************************/

#define BIN_WELCOME "\r\nWelcome to mpc5746r timer demo task "
#define BIN_VERSION "20190114-1.0.1"

#define TIMER_PORT PTJ
#define TIMER_PIN  0

/*******************************************************************************
 * Local Variables
 ******************************************************************************/

static uint32_t s_timer = 0;

/*******************************************************************************
 * Code
 ******************************************************************************/

/*FUNCTION**********************************************************************
 *
 * Function Name : PIT0_TFLG0_IRQHandler
 * Description   : PIT0 channel 0 interrupt handler, 1 ms interrupt.
 *
 * Implements    : PIT0_TFLG0_IRQHandler_Activity
 *END**************************************************************************/
void PIT0_TFLG0_IRQHandler(void)
{
    ++s_timer;
    /*Output with PJ[0] per ms*/
    PINS_DRV_TogglePins(TIMER_PORT, 1 << TIMER_PIN);
    /* Clear channel 0 interrupt flag */
    PIT_DRV_ClearStatusFlags(INST_PIT1, pit1_ChnConfig0.hwChannel);
}   /*PIT0_TFLG0_IRQHandler()*/

/*FUNCTION**********************************************************************
 *
 * Function Name : TIMER_Init
 * Description   : Initialize timer driver.
 * 1s interrupt.
 *
 * Implements    : TIMER_Init_Activity
 *END**************************************************************************/
status_t TIMER_Init(void)
{
    status_t ret;

    /* Initialize PIT */
    PIT_DRV_Init(INST_PIT1, &pit1_InitConfig);
    /* Initialize channel 0 */
    ret = PIT_DRV_InitChannel(INST_PIT1, &pit1_ChnConfig0);
    if (STATUS_SUCCESS == ret)
    {
        /* Start channel 0 counting */
        PIT_DRV_StartChannel(INST_PIT1, pit1_ChnConfig0.hwChannel);
    }

    return ret;
}   /*TIMER_Init()*/

/*FUNCTION**********************************************************************
 *
 * Function Name : TIMER_Task
 * Description   : Print the timer count value per second.
 *
 * Implements    : TIMER_Task_Activity
 *END**************************************************************************/
void TIMER_Task(void)
{
    UART_Printf(BIN_WELCOME);
    UART_Printf(BIN_VERSION);
    UART_Printf("\r\nBuild Date: %s, %s\r\n", __DATE__, __TIME__);
    
    for (;;)
    {
        UART_Printf("second count: %d.\r\n", s_timer);
        OSIF_TimeDelay(1000);
    }
}   /*TIMER_Task()*/

/*******************************************************************************
 * EOF
 ******************************************************************************/
