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
**     Filename    : port.c/h
**     Processor   : MPC57xx
**     Abstract    :
**         Port module.
**         This module contains port initialization.
**     Settings    :
**     Contents    :
**         No public methods
**
** ###################################################################*/
/*!
** @file port.c/h
** @version 01.00
** @brief
**         Port module.
**         This module contains port initialization.
*/

#ifndef PORT_H_
#define PORT_H_

/*******************************************************************************
 * Includes
 ******************************************************************************/

#include "status.h"

/*******************************************************************************
 * API
 ******************************************************************************/

/*!
 * @brief Initialize port driver.
 *
 * @param   None
 * @return  STATUS_SUCCESS if successful.
 */
status_t PORT_Init(void);

#endif /*#ifndef PORT_H_*/

/*******************************************************************************
 * EOF
 ******************************************************************************/
