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
**     Filename    : uart.c/h
**     Processor   : MPC57xx
**     Abstract    :
**         Uart module.
**         This module contains uart initialization.
**     Settings    :
**     Contents    :
**         No public methods
**
** ###################################################################*/
/*!
** @file uart.c/h
** @version 01.00
** @brief
**         Port module.
**         This module contains uart initialization.
*/

/*******************************************************************************
 * Includes
 ******************************************************************************/
 
#include "uart.h"

#include <stdio.h>

#include "linflexd_uart1.h"

/*******************************************************************************
 * Code
 ******************************************************************************/

/*FUNCTION**********************************************************************
 *
 * Function Name : UART_Init
 * Description   : Initialize uart driver.
 * baudrate = 115200 bps, RX PD[13], TX PD[14].
 *
 * Implements    : UART_Init_Activity
 *END**************************************************************************/
status_t UART_Init(void)
{
    return LINFLEXD_UART_DRV_Init(INST_LINFLEXD_UART1, 
                                  &linflexd_uart1_State, 
                                  &linflexd_uart1_InitConfig0);
}   /*UART_Init()*/

char UART_Getc(void)
{
    char c = 0;

    LINFLEXD_UART_DRV_ReceiveData(INST_LINFLEXD_UART1, (uint8_t*)&c, 1);
    while (STATUS_SUCCESS != 
           LINFLEXD_UART_DRV_GetReceiveStatus(INST_LINFLEXD_UART1, NULL)) 
        continue;

    return c;
}   /*UART_Getc()*/

void UART_Putc(const char c)
{
    LINFLEXD_UART_DRV_SendData(INST_LINFLEXD_UART1, (const uint8_t*)&c, 1);
    while (STATUS_SUCCESS != 
           LINFLEXD_UART_DRV_GetTransmitStatus(INST_LINFLEXD_UART1, NULL)) 
        continue;
}   /*UART_Putc()*/

void UART_Print(const char * s)
{
    if (s == NULL) return;

    while (*s) 
    {
        UART_Putc(*s);
        ++s;
    }
}   /*UART_Print()*/

int UART_Printf(const char * format, ...) 
{
    int len;
    va_list argptr;
    char string[128];

    va_start(argptr, format);
    len = vsprintf(string, format, argptr);
    UART_Print(string);
    va_end(argptr);

    return len;
}   /*UART_Printf()*/

/*FUNCTION**********************************************************************
 *
 * Function Name : UART_Task
 * Description   : Print information periodically with UART.
 *
 * Implements    : UART_Task_Activity
 *END**************************************************************************/
void UART_Task(void)
{
#define BIN_WELCOME "\r\nWelcome to mpc5746r uart demo task "
#define BIN_VERSION "20190111-1.0.0"

    UART_Printf(BIN_WELCOME);
    UART_Printf(BIN_VERSION);
    UART_Printf("\r\nBuild Date: %s, %s\r\n", __DATE__, __TIME__);
    
    for (;;)
    {
        UART_Printf("This is an uart demo task.\r\n");
        OSIF_TimeDelay(1000);
    }
}   /*UART_Task()*/

/*******************************************************************************
 * EOF
 ******************************************************************************/
