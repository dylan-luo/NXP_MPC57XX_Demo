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
**     Filename    : ramcode.c/h
**     Processor   : MPC57xx
**     Abstract    :
**         ramcode module.
**         This module contains ramcode example.
**     Settings    :
**     Contents    :
**         No public methods
**
** ###################################################################*/
/*!
** @file ramcode.c/h
** @version 01.00
** @brief
**         ramcode module.
**         This module contains ramcode example.
*/

/*******************************************************************************
 * Includes
 ******************************************************************************/
 
#include "ramcode.h"

#include <stdint.h>
#include "s32_core_e200.h"

#include "uart.h"

/*******************************************************************************
 * Definitions
 ******************************************************************************/

#define BIN_WELCOME "\r\nWelcome to mpc5746r ramcode demo task "
#define BIN_VERSION "20190128-1.0.3"

/*FUNCTION**********************************************************************
 *
 * Function Name : RAMCODE_Task
 * Description   : The Whole function is put into the local_imem section, 
 * increment a counter.
 *
 * Implements    : RAMCODE_Task_Activity
 *END**************************************************************************/
START_FUNCTION_DECLARATION_RAMSECTION
void RAMCODE_Task(void)
{
    static uint8_t s_count = 0;

    UART_Printf(BIN_WELCOME);
    UART_Printf(BIN_VERSION);
    UART_Printf("\r\nBuild Date: %s, %s\r\n", __DATE__, __TIME__);
    
    for (;;)
    {
        ++s_count;
    }
}   /*RAMCODE_Task()*/

/*******************************************************************************
 * EOF
 ******************************************************************************/
