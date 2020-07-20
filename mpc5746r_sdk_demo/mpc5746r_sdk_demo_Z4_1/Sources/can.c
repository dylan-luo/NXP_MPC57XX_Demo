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

/*******************************************************************************
 * Includes
 ******************************************************************************/

#include "can.h"

#include "canCom1.h"
#include "uart.h"

/*******************************************************************************
 * Definitions
 ******************************************************************************/

#define BIN_WELCOME "\r\nWelcome to mpc5746r can demo task "
#define BIN_VERSION "20190123-1.0.2"

/*! @brief CAN Mail Box type
 * Implements : can_mailbox_type_t_Class
 */
typedef enum {
    CAN_MAILBOX_RX_0 = 0,
    CAN_MAILBOX_RX_1,
    CAN_MAILBOX_RX_MAX,
    CAN_MAILBOX_TX_0 = CAN_MAILBOX_RX_MAX,
    CAN_MAILBOX_TX_1,
    CAN_MAILBOX_TX_MAX,
    CAN_MAILBOX_MAX = CAN_MAILBOX_TX_MAX
} can_mailbox_type_t;

/*******************************************************************************
 * Local Variables
 ******************************************************************************/

static bool s_rx_done = false;
static bool s_tx_done = true;
static flexcan_msgbuff_t s_can_msgbuff = {0};

static const uint32_t s_msg_id[CAN_MAILBOX_MAX] = {
    0x12,   /*!< CAN_MAILBOX_RX_0*/
    0x34,   /*!< CAN_MAILBOX_RX_1*/
    0x112,  /*!< CAN_MAILBOX_TX_0*/
    0x134   /*!< CAN_MAILBOX_TX_1*/
};

/*******************************************************************************
 * Code
 ******************************************************************************/

static bool CAN0_RxIsDone(void)
{
    bool ret = false;

    if (s_rx_done)
    {
        s_rx_done = false;
        ret = true;
    }

    return ret;
}   /*CAN0_RxIsDone()*/

static bool CAN0_TxIsDone(void)
{
    bool ret = false;

    if (s_tx_done)
    {
        s_tx_done = false;
        ret = true;
    }

    return ret;
}   /*CAN0_TxIsDone()*/

/*FUNCTION**********************************************************************
 *
 * Function Name : CAN0_RxHandler
 * Description   : Process all received data in rx interrupt.
 *
 * Implements    : CAN0_RxHandler_Activity
 *END**************************************************************************/
static void CAN0_RxHandler(void)
{
    s_rx_done = true;
}   /*CAN0_RxHandler()*/

/*FUNCTION**********************************************************************
 *
 * Function Name : CAN0_TxHandler
 * Description   : This function sets the transmitted flag in tx interrupt.
 *
 * Implements    : CAN0_TxHandler_Activity
 *END**************************************************************************/
static void CAN0_TxHandler(void)
{
    s_tx_done = true;
}   /*CAN0_TxHandler()*/

/*FUNCTION**********************************************************************
 *
 * Function Name : CAN_EventCallback
 * Description   : This function is the event callback function for the IRQ handler.
 *
 * Implements    : CAN_EventCallback_Activity
 *END**************************************************************************/
static void CAN_EventCallback(uint8_t instance, 
                              flexcan_event_type_t eventType,
                              uint32_t buffIdx, 
                              flexcan_state_t *flexcanState)
{
    DEV_ASSERT(flexcanState != NULL);

    status_t ret = STATUS_SUCCESS;
    static uint8_t s_irq_cnt = 0;
    static uint8_t s_rx_cnt = 0;
    static uint8_t s_tx_cnt = 0;

    ++s_irq_cnt;
    switch (eventType)
    {
        case FLEXCAN_EVENT_RX_COMPLETE:
            ++s_rx_cnt;
            if (INST_CANCOM1 == instance)
            {
                /*Handle the received data.*/
                CAN0_RxHandler();
                /*Start to receive data and enable a new can rx interrupt.*/
                ret = FLEXCAN_DRV_Receive(INST_CANCOM1, 
                                          buffIdx, 
                                          &s_can_msgbuff);
                DEV_ASSERT(STATUS_SUCCESS == ret);
            } 
            break;
        case FLEXCAN_EVENT_TX_COMPLETE:
            ++s_tx_cnt;
            if (INST_CANCOM1 == instance)
            {
                CAN0_TxHandler();
            }  
            break;
        default:
            break;
    }   /*switch*/
}   /*CAN_EventCallback()*/

/*FUNCTION**********************************************************************
 *
 * Function Name : CAN_ErrorCallback
 * Description   : This function is the error callback function for the IRQ handler.
 *
 * Implements    : CAN_ErrorCallback_Activity
 *END**************************************************************************/
static void CAN_ErrorCallback(uint8_t instance, 
                              flexcan_event_type_t eventType,
                              flexcan_state_t *flexcanState)
{
    DEV_ASSERT(flexcanState != NULL);

    uint32_t esr1 = FLEXCAN_DRV_GetErrorStatus(instance);
    uint8_t fltconf = (uint8_t)((esr1 & CAN_ESR1_FLTCONF_MASK) >> 
        CAN_ESR1_FLTCONF_SHIFT);
    static uint8_t s_error_active_cnt  = 0;
    static uint8_t s_error_passive_cnt = 0;
    static uint8_t s_error_busoff_cnt  = 0;

    /* Check whether bus is off. */
    switch (fltconf)
    {
        case 0:     /*Error Active*/
            ++s_error_active_cnt;
            break;
        case 1:     /*Error Passive*/
            ++s_error_passive_cnt;
            break;
        default:    /*Bus Off*/
            ++s_error_busoff_cnt;
            /* Write your code here */

            break;
    }   /*switch*/
}   /*CAN_ErrorCallback()*/


/*FUNCTION**********************************************************************
 *
 * Function Name : CAN_Init
 * Description   : Initialize CAN driver.
 * bitrate = 500 kbit/s, RX PF[13], TX PF[12]
 *
 * Implements    : CAN_Init_Activity
 *END**************************************************************************/
status_t CAN_Init(void)
{
    status_t ret;

    ret = FLEXCAN_DRV_Init(INST_CANCOM1, &canCom1_State, &canCom1_InitConfig0);
    if (STATUS_SUCCESS == ret)
    {
        FLEXCAN_DRV_InstallEventCallback(INST_CANCOM1,
                                         (flexcan_callback_t)CAN_EventCallback, 
                                         NULL);
        FLEXCAN_DRV_InstallErrorCallback(INST_CANCOM1,
                                         (flexcan_error_callback_t)CAN_ErrorCallback, 
                                         NULL);
    }   /*if*/

    return ret;
}   /*CAN_Init()*/

/*FUNCTION**********************************************************************
 *
 * Function Name : CAN_Task
 * Description   : Receive frame first, then print message with CAN continually.
 *
 * Implements    : CAN_Task_Activity
 *END**************************************************************************/
void CAN_Task(void)
{
    uint8_t for_cnt  = 0;
    uint8_t send_cnt = 0;
    status_t ret = STATUS_SUCCESS;
    flexcan_data_info_t rx_info =
    {
        .msg_id_type = FLEXCAN_MSG_ID_STD,
        .data_length = 8UL,
        .is_remote   = false
    };
    flexcan_data_info_t tx_info =
    {
        .msg_id_type = FLEXCAN_MSG_ID_STD,
        .data_length = 8UL,
        .is_remote   = false
    };
    uint8_t send_buf[4][8] = {{0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08},
                              {0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18},
                              {0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28},
                              {0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38}};

    UART_Printf(BIN_WELCOME);
    UART_Printf(BIN_VERSION);
    UART_Printf("\r\nBuild Date: %s, %s\r\n", __DATE__, __TIME__);

    /* Initialize Rx mailbox. Start to receive data and enable can rx interrupt. */
    for (int i = CAN_MAILBOX_RX_0; i < CAN_MAILBOX_RX_MAX; ++i)
    {
        ret = FLEXCAN_DRV_ConfigRxMb(INST_CANCOM1, i, &rx_info, s_msg_id[i]);
        if (STATUS_SUCCESS == ret)
        {
            ret = FLEXCAN_DRV_Receive(INST_CANCOM1, i, &s_can_msgbuff);
        } 
        DEV_ASSERT(STATUS_SUCCESS == ret);
    }
    /* Initialize Tx mailbox. */
    for (int i = CAN_MAILBOX_TX_0; i < CAN_MAILBOX_TX_MAX; ++i)
    {
        ret = FLEXCAN_DRV_ConfigTxMb(INST_CANCOM1, i, &tx_info, s_msg_id[i]); 
        DEV_ASSERT(STATUS_SUCCESS == ret);
    }

    for (;;)
    {
        /* Rx Task */
        if (CAN0_RxIsDone())
        {
            UART_Printf("Received %X CAN frame: ", s_can_msgbuff.msgId);
            for (int i = 0; i < s_can_msgbuff.dataLen; ++i)
            {
                UART_Printf("%02X ", s_can_msgbuff.data[i]);
            }
            UART_Printf("\r\n");
        }   /*if*/

        /* Tx Task */
        /* Transmit different buffers in turn. */
        if (CAN0_TxIsDone())
        {
            switch ((send_cnt++) & 3)
            {
                case 0:
                    send_buf[0][0] = for_cnt++;
                    ret = FLEXCAN_DRV_Send(INST_CANCOM1, 
                                           CAN_MAILBOX_TX_0, 
                                           &tx_info, 
                                           s_msg_id[CAN_MAILBOX_TX_0], 
                                           send_buf[0]);
                    DEV_ASSERT(STATUS_SUCCESS == ret);
                    break;
                case 1:
                    send_buf[1][0] = for_cnt++;
                    ret = FLEXCAN_DRV_Send(INST_CANCOM1, 
                                           CAN_MAILBOX_TX_0, 
                                           &tx_info, 
                                           s_msg_id[CAN_MAILBOX_TX_0], 
                                           send_buf[1]);
                    DEV_ASSERT(STATUS_SUCCESS == ret);
                    break;
                case 2:
                    send_buf[2][0] = for_cnt++;
                    ret = FLEXCAN_DRV_Send(INST_CANCOM1, 
                                           CAN_MAILBOX_TX_1, 
                                           &tx_info, 
                                           s_msg_id[CAN_MAILBOX_TX_1], 
                                           send_buf[2]);
                    DEV_ASSERT(STATUS_SUCCESS == ret);
                    break;
                case 3:
                    send_buf[3][0] = for_cnt++;
                    ret = FLEXCAN_DRV_Send(INST_CANCOM1, 
                                           CAN_MAILBOX_TX_1, 
                                           &tx_info, 
                                           s_msg_id[CAN_MAILBOX_TX_1], 
                                           send_buf[3]);
                    DEV_ASSERT(STATUS_SUCCESS == ret);
                    break;
                default:
                    break;
            }   /*switch*/
            OSIF_TimeDelay(10);
        }   /*if*/
    }   /*for*/ 
}   /*CAN_Task()*/

/*******************************************************************************
 * EOF
 ******************************************************************************/
