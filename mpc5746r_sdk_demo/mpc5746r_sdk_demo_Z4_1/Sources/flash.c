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
**     Filename    : flash.c/h
**     Processor   : MPC57xx
**     Abstract    :
**         flash module.
**         This module contains flash initialization.
**     Settings    :
**     Contents    :
**         No public methods
**
** ###################################################################*/
/*!
** @file flash.c/h
** @version 01.00
** @brief
**         flash module.
**         This module contains flash initialization.
*/

/*******************************************************************************
 * Includes
 ******************************************************************************/
 
#include "flash.h"

#include "uart.h"

/*******************************************************************************
 * Definitions
 ******************************************************************************/

#define BIN_WELCOME "\r\nWelcome to mpc5746r flash demo task "
#define BIN_VERSION "20190123-1.0.2"

/* Lock State */
#define UNLOCK_LOW_BLOCKS               0x00000000U
#define UNLOCK_MID_BLOCKS               0x00000000U
#define UNLOCK_HIGH_BLOCKS              0x00000000U
#define UNLOCK_FIRST256_BLOCKS          0x00000000U
#define UNLOCK_SECOND256_BLOCKS         0x00000000U

/* buffer size */
#define BUFFER_SIZE_BYTE                0x10U

#define BLOCK_START_ADDRS               0x00FA0000U
#define BLOCK_END_ADDRS                 0x00FA3FFFU

#define NUMBER_OF_WORD_BLANK_CHECK      0x90U
#define NUMBER_OF_WORD_PGM_VERIFY       0x10U
#define NUMBER_OF_WORD_CHECK_SUM        0x10U

/* Platform Flash */
#define FLASH_FMC                       PFLASH_BASE
#define FLASH_PFCR1                     0x000000000U
#define FLASH_PFCR2                     0x000000004U
#define FLASH_FMC_BFEN_MASK             0x000000001U

/*******************************************************************************
 * Local Variables
 ******************************************************************************/

uint32_t g_usrCnt = 0U;

/*******************************************************************************
 * Code
 ******************************************************************************/

/* User callback, such as feed watchdog */
static void FLASH_UserCallBack(void)
{
    /* increase g_usrCnt */
    g_usrCnt++;
}

static void DisableFlashControllerCache(uint32_t flashConfigReg,
                                        uint32_t disableVal,
                                        uint32_t *origin_pflash_pfcr)
{
    /* Read the values of the register of flash configuration */
    *origin_pflash_pfcr = REG_READ32(FLASH_FMC + flashConfigReg);

    /* Disable Caches */
    REG_BIT_CLEAR32(FLASH_FMC + flashConfigReg, disableVal);
}

static void RestoreFlashControllerCache(uint32_t flashConfigReg,
                                        uint32_t pflash_pfcr)
{
    REG_WRITE32(FLASH_FMC + flashConfigReg, pflash_pfcr);
}

/*FUNCTION**********************************************************************
 *
 * Function Name : FLASH_Init
 * Description   : Initialize flash driver.
 *
 * Implements    : FLASH_Init_Activity
 *END**************************************************************************/
status_t FLASH_Init(void)
{
    return FLASH_DRV_Init();
}   /*FLASH_Init()*/

/*FUNCTION**********************************************************************
 *
 * Function Name : FLASH_Task
 * Description   : Write flash, then read.
 *
 * Implements    : FLASH_Task_Activity
 *END**************************************************************************/
void FLASH_Task(void)
{
    uint32_t pflash_pfcr1, pflash_pfcr2;
    uint32_t buffer[BUFFER_SIZE_BYTE / C55_WORD_SIZE];
    status_t ret = STATUS_SUCCESS;
    uint32_t blkLockState;         /* block lock status to be retrieved */
    flash_block_select_t blockSelect;
    flash_context_data_t pCtxData;
    flash_state_t opResult;
    uint32_t numOfWordCycle;
    uint32_t dest;                 /* destination address */
    uint32_t size;                 /* size applicable */
    uint32_t source;               /* source address for program and verify */
    uint32_t failedAddress;        /* save the failed address in flash */
    uint32_t sum;                  /* check sum result */

    UART_Printf(BIN_WELCOME);
    UART_Printf(BIN_VERSION);
    UART_Printf("\r\nBuild Date: %s, %s\r\n", __DATE__, __TIME__);

    /* Invalidate flash controller cache */
    DisableFlashControllerCache(FLASH_PFCR1, FLASH_FMC_BFEN_MASK, &pflash_pfcr1);
    DisableFlashControllerCache(FLASH_PFCR2, FLASH_FMC_BFEN_MASK, &pflash_pfcr2);

    /**************************************************************************/
    /* Initialize source buffer                                               */
    /**************************************************************************/
    for (int i = 0; i < (BUFFER_SIZE_BYTE / C55_WORD_SIZE); i++)
    {
        buffer[i] = 0x0U;
    }

    /**************************************************************************/
    /* Lock to protect UTest address space                                    */
    /**************************************************************************/
    ret = FLASH_DRV_GetLock(C55_BLOCK_UTEST, &blkLockState);

    if (!(blkLockState & 0x00000001U))
    {
        ret = FLASH_DRV_SetLock(C55_BLOCK_UTEST, 0x1U);
        if (STATUS_SUCCESS != ret)
        {
            return;
        }
    }

    /**************************************************************************/
    /* Unlock all blocks in low address space                                 */
    /**************************************************************************/
    ret = FLASH_DRV_SetLock(C55_BLOCK_LOW, UNLOCK_LOW_BLOCKS);
    if (STATUS_SUCCESS != ret)
    {
        return;
    }

    /**************************************************************************/
    /* Unlock all blocks in mid address space                                 */
    /**************************************************************************/
    ret = FLASH_DRV_SetLock(C55_BLOCK_MID, UNLOCK_MID_BLOCKS);
    if (STATUS_SUCCESS != ret)
    {
        return;
    }

    /**************************************************************************/
    /* Unlock all blocks in 256K blocks                                       */
    /**************************************************************************/
    ret = FLASH_DRV_SetLock(C55_BLOCK_256K_FIRST, UNLOCK_FIRST256_BLOCKS);
    if (STATUS_SUCCESS != ret)
    {
        return;
    }

    ret = FLASH_DRV_SetLock(C55_BLOCK_256K_SECOND, UNLOCK_SECOND256_BLOCKS);
    if (STATUS_SUCCESS != ret)
    {
        return;
    }            

    /**************************************************************************/
    /* Call FLASH_DRV_Erase, FLASH_DRV_BlankCheck, FLASH_DRV_Program,         */
    /* FLASH_DRV_ProgramVerify, FLASH_DRV_CheckSum functions                  */
    /**************************************************************************/
    blockSelect.lowBlockSelect = 0x2U;
    blockSelect.midBlockSelect = 0x0U;
    blockSelect.highBlockSelect = 0x0U;
    blockSelect.first256KBlockSelect = 0x0U;
    blockSelect.second256KBlockSelect = 0x0U;
    g_usrCnt = 0U;

    /* Erase block */
    ret = FLASH_DRV_Erase(ERS_OPT_MAIN_SPACE, &blockSelect);

    if (STATUS_SUCCESS == ret)
    {
        do
        {
            /* The user can do any tasks while check status function is still in progress */
        	FLASH_UserCallBack();
            ret = FLASH_DRV_CheckEraseStatus(&opResult);
        } while (ret == STATUS_FLASH_INPROGRESS);
    }

    if (STATUS_SUCCESS != ret)
    {
        return;
    }

    dest = BLOCK_START_ADDRS;
    size = BLOCK_END_ADDRS + 1 - BLOCK_START_ADDRS;
    numOfWordCycle = NUMBER_OF_WORD_BLANK_CHECK;

    /* Blank check */
    ret = FLASH_DRV_BlankCheck(dest,
                               size,
                               numOfWordCycle,
                               &failedAddress,
                               NULL_CALLBACK);

    if (STATUS_SUCCESS != ret)
    {
        return;
    }

    /* Program to beginning of block */
    dest = BLOCK_START_ADDRS;
    size = BUFFER_SIZE_BYTE;
    source = (uint32_t)buffer;
    g_usrCnt = 0U;
    ret = FLASH_DRV_Program(&pCtxData,
                            dest,
                            size,
                            source);

    if (STATUS_SUCCESS == ret)
    {
        do
        {
            /* The user can do any tasks while check status function is still in progress */
            FLASH_UserCallBack();
            ret = FLASH_DRV_CheckProgramStatus(&pCtxData, &opResult);
        } while (ret == STATUS_FLASH_INPROGRESS);
    }

    if (STATUS_SUCCESS != ret)
    {
        return;
    }

    numOfWordCycle = NUMBER_OF_WORD_PGM_VERIFY;
    /* Program verify */
    ret = FLASH_DRV_ProgramVerify(dest,
                                  size,
                                  source,
                                  numOfWordCycle,
                                  &failedAddress,
                                  NULL_CALLBACK);

    if (STATUS_SUCCESS != ret)
    {
        return;
    }

    numOfWordCycle = NUMBER_OF_WORD_CHECK_SUM;
    /* Check sum */
    ret = FLASH_DRV_CheckSum(dest,
                             size,
                             numOfWordCycle,
                             &sum,
                             NULL_CALLBACK);

    if ((STATUS_SUCCESS != ret) && (sum != 0U))
    {
        return;
    }

    /* Restore flash controller cache */
    RestoreFlashControllerCache(FLASH_PFCR1, pflash_pfcr1);
    RestoreFlashControllerCache(FLASH_PFCR2, pflash_pfcr2);

    for (;;)
    {

    }   /*for*/ 
}   /*FLASH_Task()*/

/*******************************************************************************
 * EOF
 ******************************************************************************/
