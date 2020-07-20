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
**     Filename    : spi.c/h
**     Processor   : MPC57xx
**     Abstract    :
**         spi module.
**         This module contains spi initialization.
**     Settings    :
**     Contents    :
**         No public methods
**
** ###################################################################*/
/*!
** @file spi.c/h
** @version 01.00
** @brief
**         spi module.
**         This module contains spi initialization.
*/

/*******************************************************************************
 * Includes
 ******************************************************************************/
 
#include "spi.h"

#include "dspi0.h"
#include "dspi1.h"

#include "uart.h"

/*******************************************************************************
 * Definitions
 ******************************************************************************/

#define BIN_WELCOME "\r\nWelcome to mpc5746r spi demo task "
#define BIN_VERSION "20190128-1.0.3"

#define NUMBER_OF_FRAME  12

/*******************************************************************************
 * Local Variables
 ******************************************************************************/

static bool s_dspi0_master_done = false;
static bool s_dspi0_slave_done  = false;
static bool s_dspi1_master_done = false;
static bool s_dspi1_slave_done  = false;

/*******************************************************************************
 * Code
 ******************************************************************************/

/*FUNCTION**********************************************************************
 *
 * Function Name : DSPI0_MasterHandler
 * Description   : SPI master handler.
 *
 * Implements    : DSPI0_MasterHandler_Activity
 *END**************************************************************************/
static void DSPI0_MasterHandler(void)
{
    s_dspi0_master_done = true;
}   /*DSPI0_MasterHandler()*/

/*FUNCTION**********************************************************************
 *
 * Function Name : DSPI0_SlaveHandler
 * Description   : SPI slave handler.
 *
 * Implements    : DSPI0_SlaveHandler_Activity
 *END**************************************************************************/
static void DSPI0_SlaveHandler(void)
{
    s_dspi0_slave_done = true;
}   /*DSPI0_SlaveHandler()*/

/*FUNCTION**********************************************************************
 *
 * Function Name : DSPI1_MasterHandler
 * Description   : SPI master handler.
 *
 * Implements    : DSPI1_MasterHandler_Activity
 *END**************************************************************************/
static void DSPI1_MasterHandler(void)
{
    s_dspi1_master_done = true;
}   /*DSPI1_MasterHandler()*/

/*FUNCTION**********************************************************************
 *
 * Function Name : DSPI1_SlaveHandler
 * Description   : SPI slave handler.
 *
 * Implements    : DSPI1_SlaveHandler_Activity
 *END**************************************************************************/
static void DSPI1_SlaveHandler(void)
{
    s_dspi1_slave_done = true;
}   /*DSPI1_SlaveHandler()*/

/*FUNCTION**********************************************************************
 *
 * Function Name : DSPI0_MasterCallback
 * Description   : This function is the event callback function for the IRQ handler.
 *
 * Implements    : CAN_EventCallback_Activity
 *END**************************************************************************/
void DSPI0_MasterCallback(void *driverState, spi_event_t event, void *userData)
{
    (void)driverState;
    (void)event;    /*only SPI_EVENT_END_TRANSFER event*/
    (void)userData;

    /* Write your code here */
    DSPI0_MasterHandler();
}   /*DSPI0_MasterCallback()*/

/*FUNCTION**********************************************************************
 *
 * Function Name : DSPI0_SlaveCallback
 * Description   : This function is the event callback function for the IRQ handler.
 *
 * Implements    : CAN_EventCallback_Activity
 *END**************************************************************************/
void DSPI0_SlaveCallback(void *driverState, spi_event_t event, void *userData)
{
    (void)driverState;
    (void)event;    /*only SPI_EVENT_END_TRANSFER event*/
    (void)userData;   

    /* Write your code here */
    DSPI0_SlaveHandler();
}   /*DSPI0_SlaveCallback()*/

/*FUNCTION**********************************************************************
 *
 * Function Name : DSPI1_MasterCallback
 * Description   : This function is the event callback function for the IRQ handler.
 *
 * Implements    : CAN_EventCallback_Activity
 *END**************************************************************************/
void DSPI1_MasterCallback(void *driverState, spi_event_t event, void *userData)
{
    (void)driverState;
    (void)event;    /*only SPI_EVENT_END_TRANSFER event*/
    (void)userData;

    /* Write your code here */
    DSPI1_MasterHandler();
}   /*DSPI1_MasterCallback()*/

/*FUNCTION**********************************************************************
 *
 * Function Name : DSPI1_SlaveCallback
 * Description   : This function is the event callback function for the IRQ handler.
 *
 * Implements    : CAN_EventCallback_Activity
 *END**************************************************************************/
void DSPI1_SlaveCallback(void *driverState, spi_event_t event, void *userData)
{
    (void)driverState;
    (void)event;    /*only SPI_EVENT_END_TRANSFER event*/
    (void)userData;   

    /* Write your code here */
    DSPI1_SlaveHandler();
}   /*DSPI1_SlaveCallback()*/

/*FUNCTION**********************************************************************
 *
 * Function Name : SPI_Init
 * Description   : Initialize spi driver.
 * DSPI_0 Master: baudrate = 500 kbit/s
 * SCK PJ[14], CS Output PK[5], CS Input PK[5], SDI PK[1], SDO PK[2]
 * DSPI_1 Slave : baudrate = 500 kbit/s
 * SCK PG[13], CS Input PG[9], SDI PG[11], SDO PG[12]
 *
 * Implements    : SPI_Init_Activity
 *END**************************************************************************/
status_t SPI_Init(void)
{
    status_t ret = STATUS_SUCCESS;

    /* Initialize Dspi0 */
    ret = DSPI_MasterInit(DSPI0_INSTANCE, &dspi0State, &dspi0_MasterInitConfig0);
    if (STATUS_SUCCESS == ret)
    {   
        /* Initialize Dspi1 */
        ret = DSPI_SlaveInit(DSPI1_INSTANCE, &dspi1State, &dspi1_SlaveInitConfig0);
        if (STATUS_SUCCESS == ret)
        {
            ret = DSPI_MasterSetDelay(DSPI0_INSTANCE, 1, 1, 1);
        }   /*if*/
    }   /*if*/

    return ret;
}   /*SPI_Init()*/

/*FUNCTION**********************************************************************
 *
 * Function Name : SPI_Task
 * Description   : 
 *
 * Implements    : SPI_Task_Activity
 *END**************************************************************************/
void SPI_Task(void)
{
    uint32_t count  = 0;
    status_t ret    = STATUS_SUCCESS;
    dspi_transfer_status_t transfer_status = DSPI_TRANSFER_OK;
    uint32_t numOfByteTransIncorrectly  = 0;
    uint8_t masterTxBuffer_8b[NUMBER_OF_FRAME] = {0};
    uint8_t masterRxBuffer_8b[NUMBER_OF_FRAME] = {0};
    uint8_t slaveTxBuffer_8b[NUMBER_OF_FRAME]  = {0};
    uint8_t slaveRxBuffer_8b[NUMBER_OF_FRAME]  = {0};

    UART_Printf(BIN_WELCOME);
    UART_Printf(BIN_VERSION);
    UART_Printf("\r\nBuild Date: %s, %s\r\n", __DATE__, __TIME__);

    for (count = 0; count < NUMBER_OF_FRAME; count++)
    {
        masterTxBuffer_8b[count] = count;
        slaveTxBuffer_8b[count] = NUMBER_OF_FRAME - count;
    }

    /* Transfers data between dspi0 and dspi1 instances */
    ret = DSPI_SlaveTransfer(DSPI1_INSTANCE,
                             slaveTxBuffer_8b, 
                             slaveRxBuffer_8b, 
                             NUMBER_OF_FRAME);
    DevAssert(STATUS_SUCCESS == ret);
	ret = DSPI_MasterTransfer(DSPI0_INSTANCE,
                               masterTxBuffer_8b,
                               masterRxBuffer_8b,
                               NUMBER_OF_FRAME);
    DevAssert(STATUS_SUCCESS == ret);
    /* Check whether the last transfer was done */
	do {
		DSPI_GetTransferStatus(DSPI0_INSTANCE, &transfer_status);
	} while (transfer_status != DSPI_TRANSFER_OK);

	do {
		DSPI_GetTransferStatus(DSPI1_INSTANCE, &transfer_status);
	} while (transfer_status != DSPI_TRANSFER_OK);

    /* verify the data transfers between dspi0 and dspi1 instances */
    for (count = 0; count < NUMBER_OF_FRAME; count++)
    {
        numOfByteTransIncorrectly = (masterTxBuffer_8b[count] == slaveRxBuffer_8b[count]) 
            ? numOfByteTransIncorrectly : (numOfByteTransIncorrectly + 1);
        numOfByteTransIncorrectly = (slaveTxBuffer_8b[count] == masterRxBuffer_8b[count]) 
            ? numOfByteTransIncorrectly : (numOfByteTransIncorrectly + 1);
    }

    if (numOfByteTransIncorrectly == 0)
    {
        UART_Printf("Congratulation! Data transfer between dspi 0 and dspi1 instances is "
                    "correct.\r\n");
    } else {
        UART_Printf("Oops! %d data are different.\r\n", numOfByteTransIncorrectly);
    }   /*if else*/

    /* De-initialize dspi  */
    DSPI_Deinit(DSPI0_INSTANCE);
    DSPI_Deinit(DSPI1_INSTANCE);
  
    for (;;)
    {

    }   /*for*/ 
}   /*SPI_Task()*/

/*******************************************************************************
 * EOF
 ******************************************************************************/
