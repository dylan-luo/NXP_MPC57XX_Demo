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
#ifndef TIMER_H_
#define TIMER_H_

/*******************************************************************************
 * Includes
 ******************************************************************************/

#include "status.h"

/*******************************************************************************
 * API
 ******************************************************************************/

/*!
 * @brief Initialize timer driver.
 *
 * @param   None
 *         - STATUS_SUCCESS: Operation was successful
 *         - STATUS_ERROR: The input period is invalid
 */
status_t TIMER_Init(void);
/*!
 * @brief Print the timer count value per second.
 *
 * @param   None
 * @return  None
 */
void TIMER_Task(void);

#endif /*#ifndef TIMER_H_*/

/*******************************************************************************
 * EOF
 ******************************************************************************/
