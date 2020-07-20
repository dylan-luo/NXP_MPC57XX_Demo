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
**     Filename    : can.c/h
**     Processor   : MPC57xx
**     Abstract    :
**         CAN module.
**         This module contains CAN initialization.
**     Settings    :
**     Contents    :
**         No public methods
**
** ###################################################################*/
/*!
** @file can.c/h
** @version 01.00
** @brief
**         CAN module.
**         This module contains CAN initialization.
*/
#ifndef CAN_H_
#define CAN_H_

/*******************************************************************************
 * Includes
 ******************************************************************************/

#include "flexcan_driver.h"

/*******************************************************************************
 * API
 ******************************************************************************/

/*!
 * @brief Initialize CAN driver.
 *  bitrate = 500 kbit/s, RX PF[13], TX PF[12]
 *
 * @param   None
 * @return  STATUS_SUCCESS if successful;
 *          STATUS_CAN_BUFF_OUT_OF_RANGE if the index of a message buffer is invalid;
 *          STATUS_ERROR if other error occurred
 */
status_t CAN_Init(void);
/*!
 * @brief Receive frame first, then print message with CAN continually.
 *
 * @param   None
 * @return  None
 */
void CAN_Task(void);

#endif /*#ifndef CAN_H_*/

/*******************************************************************************
 * EOF
 ******************************************************************************/
