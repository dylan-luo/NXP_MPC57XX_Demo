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
**     Filename    : eeprom.c/h
**     Processor   : MPC57xx
**     Abstract    :
**         eeprom module.
**         This module contains eeprom initialization.
**     Settings    :
**     Contents    :
**         No public methods
**
** ###################################################################*/
/*!
** @file eeprom.c/h
** @version 01.00
** @brief
**         eeprom module.
**         This module contains eeprom initialization.
*/

/*******************************************************************************
 * Includes
 ******************************************************************************/
 
#include "eeprom.h"

#include "eee1.h"
#include "uart.h"

/*******************************************************************************
 * Definitions
 ******************************************************************************/

#define BIN_WELCOME "\r\nWelcome to mpc5746r eeprom demo task "
#define BIN_VERSION "20190123-1.0.2"

/* Lock State */
#define UNLOCK_MID_BLOCKS               0x00000000U

/* buffer size */
#define BUFFER_SIZE_BYTE                0x80U

/* EEPROM address */
/* MPC5746R Reference Manual, Page 906-907. */
#define BLOCK_START_ADDRS               0x00800000U
#define BLOCK_END_ADDRS                 0x0083FFFFU

#define NUMBER_OF_WORD_BLANK_CHECK      0x90

/* Platform Flash */
#define FLASH_FMC                       PFLASH_BASE
#define FLASH_PFCR1                     0x000000000U
#define FLASH_PFCR2                     0x000000004U
#define FLASH_FMC_BFEN_MASK             0x000000001U

/*******************************************************************************
 * Local Variables
 ******************************************************************************/

static eee_state_t s_state = {0};

/*******************************************************************************
 * Code
 ******************************************************************************/

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
 * Function Name : EEPROM_Init
 * Description   : Initialize eeprom driver.
 * All 10 eeprom blocks are initialized.
 *
 * Implements    : EEPROM_Init_Activity
 *END**************************************************************************/
status_t EEPROM_Init(void)
{
    status_t ret = STATUS_SUCCESS;
    uint32_t dest = 0U;  /* destination address */
    uint16_t size = 0U;  /* size of data record */
    uint32_t pflash_pfcr1 = 0U;
    uint32_t pflash_pfcr2 = 0U;
    uint32_t numOfWordCycle = 0U;
    uint32_t failedAddress = 0U;	/* save the failed address in flash */
    flash_state_t opResult = C55_OK;
    flash_block_select_t blockSelect = {0};

    /* Invalidate flash controller cache */
    DisableFlashControllerCache(FLASH_PFCR1, FLASH_FMC_BFEN_MASK, &pflash_pfcr1);
    DisableFlashControllerCache(FLASH_PFCR2, FLASH_FMC_BFEN_MASK, &pflash_pfcr2);

    /* Unlock all eeprom blocks */
	/**************************************************************************/
	/* Unlock all blocks in mid address space                                 */
	/**************************************************************************/
    ret = FLASH_DRV_SetLock(C55_BLOCK_MID, UNLOCK_MID_BLOCKS);
    /**************************************************************************/
    /* Call FLASH_DRV_Erase, FLASH_DRV_BlankCheck functions to erase all      */
    /* EEE blocks Which are used in EEPROM emulation                          */
    /**************************************************************************/
    if (STATUS_SUCCESS == ret)
    {
        blockSelect.lowBlockSelect = 0x0U;
        blockSelect.midBlockSelect = 0x3FFU;
        blockSelect.highBlockSelect = 0x0U;
        blockSelect.first256KBlockSelect = 0x0U;
        blockSelect.second256KBlockSelect = 0x0U;

        /* Erase block */
        /***********************************************************************
         * Attention!!!
         **********************************************************************/
		/* If eeprom had been initialized before, some eeprom status */
		/* information would be written into the head of each block. */
		/* You can use these information, such as for erase blocks only once!!! */
        ret = FLASH_DRV_Erase(ERS_OPT_MAIN_SPACE, &blockSelect);
        if (STATUS_SUCCESS == ret)
        {
            do
            {
                ret = FLASH_DRV_CheckEraseStatus(&opResult);
            } while (ret == STATUS_FLASH_INPROGRESS);
        }   /*if*/
        if (STATUS_SUCCESS == ret)
        {
            dest = BLOCK_START_ADDRS;
            size = (uint16_t)(BLOCK_END_ADDRS + 1U - BLOCK_START_ADDRS);
            numOfWordCycle = NUMBER_OF_WORD_BLANK_CHECK;

            /* Blank check */
            ret = FLASH_DRV_BlankCheck(dest,
                                       size,
                                       numOfWordCycle,
                                       &failedAddress,
                                       NULL_CALLBACK);
            if (STATUS_SUCCESS == ret)
            {
                ret = EEE_DRV_InitEeprom(&userConf, &s_state);
            }  
        }
    }   /*if*/

    /* Restore flash controller cache */
    RestoreFlashControllerCache(FLASH_PFCR1, pflash_pfcr1);
    RestoreFlashControllerCache(FLASH_PFCR2, pflash_pfcr2);

    return ret;
}   /*EEPROM_Init()*/

/*FUNCTION**********************************************************************
 *
 * Function Name : EEPROM_Task
 * Description   : Write flash, then read.
 *
 * Implements    : EEPROM_Task_Activity
 *END**************************************************************************/
void EEPROM_Task(void)
{
    bool re_init_flag = false;  /* control if it needs to re-init eeprom system */
    bool swap_flag = false;
    uint16_t id = 0U;           /* id of data record */
    uint16_t size = 0U;         /* size of data record */
    uint32_t i = 0U;            /* index variable */
    uint32_t pflash_pfcr1 = 0;
    uint32_t pflash_pfcr2 = 0;
    uint32_t recordAddr = 0;
    uint32_t swapNum = 0;
    status_t ret = STATUS_SUCCESS;
    uint8_t buffer[BUFFER_SIZE_BYTE] = {0};

    UART_Printf(BIN_WELCOME);
    UART_Printf(BIN_VERSION);
    UART_Printf("\r\nBuild Date: %s, %s\r\n", __DATE__, __TIME__);

    /* Invalidate flash controller cache */
    DisableFlashControllerCache(FLASH_PFCR1, FLASH_FMC_BFEN_MASK, &pflash_pfcr1);
    DisableFlashControllerCache(FLASH_PFCR2, FLASH_FMC_BFEN_MASK, &pflash_pfcr2);

    /*---------------------------------------------------------------------*/
    /* Write eeprom data records                                           */
    /*---------------------------------------------------------------------*/

    /*---------------------------------------------------------------------*/
    /* Reference documents: Documentation\MPC5xxx_EED_UM.pdf               */    
    /*---------------------------------------------------------------------*/

    /*---------------------------------------------------------------------*/
    /* Simple example                                                      */
    /*---------------------------------------------------------------------*/
    id = 4U;
    /* Exit loop when all blocks are written once. */
    while (swapNum < userConf.numberOfBlock)
    {
        size = id + 1U;
        if (size > BUFFER_SIZE_BYTE)
        {
           size = BUFFER_SIZE_BYTE;
        }

        /* Initialize buffer */
        for (i = 0U; i < size; i++)
        {
           buffer[i] = (uint8_t)i;
        }

        ret = EEE_DRV_WriteEeprom(id,
                                  size,
                                  (uint32_t)buffer,
                                  EEE_IMMEDIATE_NONE);
        if (ret == STATUS_SUCCESS)
        {
            /* Call to EEE_DRV_MainFunction if there is a swap operation. */
            while (g_eraseStatusFlag == EEE_ERASE_IN_PROGRESS)
            {
                swap_flag = true;
                ret = EEE_DRV_MainFunction();
            }
            if (true == swap_flag)
            {
                swapNum++;
            }
            swap_flag = false;
            if (g_eraseStatusFlag == EEE_ERASE_SWAP_ERROR)
            {
                re_init_flag = true;
            }
        } 
        else
        {
            re_init_flag = true;
        }

        if (re_init_flag == true)
        {
            /* Call to EEE_DRV_InitEeprom to try recovering eeprom system */
            ret = EEE_DRV_InitEeprom(&userConf, &s_state);
            DEV_ASSERT(STATUS_SUCCESS == ret);
        }

        id++;
        id = id % 0x50U;
    }   /* while */

    /*---------------------------------------------------------------------*/
    /* Read data from eeprom                                               */
    /*---------------------------------------------------------------------*/
    for(i = 0U; i < BUFFER_SIZE_BYTE; i++)
    {
        buffer[i] = 0xFFU;
    }

    id = 0x10U;
    ret = EEE_DRV_ReadEeprom(id,
                             size,
                             (uint32_t)buffer,
                             &recordAddr,
                             EEE_IMMEDIATE_NONE);
    DEV_ASSERT(STATUS_SUCCESS == ret);

    /*---------------------------------------------------------------------*/
    /* Delete data from eeprom                                             */
    /*---------------------------------------------------------------------*/
    ret = EEE_DRV_DeleteRecord(id,
                               EEE_IMMEDIATE_NONE);
    DEV_ASSERT(STATUS_SUCCESS == ret);

    for(i = 0U; i < BUFFER_SIZE_BYTE; i++)
    {
        buffer[i] = 0xFFU;
    }

    ret = EEE_DRV_ReadEeprom(id,
                             size,
                             (uint32_t)buffer,
                             &recordAddr,
                             EEE_IMMEDIATE_NONE);
    DEV_ASSERT(STATUS_EEE_ERROR_DATA_NOT_FOUND == ret);

    /*---------------------------------------------------------------------*/
    /* Report eeprom status                                                */
    /*---------------------------------------------------------------------*/
    ret = EEE_DRV_ReportEepromStatus(&i);
    DEV_ASSERT(STATUS_SUCCESS == ret);

    /* Erase all eeprom blocks*/
    ret = EEE_DRV_RemoveEeprom();
    DEV_ASSERT(STATUS_SUCCESS == ret);

    /* Restore flash controller cache */
    RestoreFlashControllerCache(FLASH_PFCR1, pflash_pfcr1);
    RestoreFlashControllerCache(FLASH_PFCR2, pflash_pfcr2);

    for (;;)
    {

    }   /*for*/ 
}   /*EEPROM_Task()*/

/*******************************************************************************
 * EOF
 ******************************************************************************/
