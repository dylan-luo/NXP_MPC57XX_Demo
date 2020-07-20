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
#ifndef UART_H_
#define UART_H_

/*******************************************************************************
 * Includes
 ******************************************************************************/

#include "status.h"

/*******************************************************************************
 * API
 ******************************************************************************/

/*!
 * @brief Initialize uart driver.
 *  baudrate = 115200 bps, RX PD[13], TX PD[14].
 *
 * @param   None
 * @return  STATUS_SUCCESS if successful;
 *          STATUS_BUSY if a resource is busy.
 */
status_t UART_Init(void);
char UART_Getc(void);
void UART_Putc(const char c);
void UART_Print(const char * s);
int  UART_Printf(const char * format, ...);
/*!
 * @brief Print information periodically with UART.
 *
 * @param   None
 * @return  None
 */
void UART_Task(void);

#endif /*#ifndef UART_H_*/

/*******************************************************************************
 * EOF
 ******************************************************************************/
