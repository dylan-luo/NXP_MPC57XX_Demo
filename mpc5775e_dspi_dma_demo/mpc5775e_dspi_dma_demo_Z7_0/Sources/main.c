/*
 * Copyright 2018 NXP
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
 **     Filename    : main.c
 **     Project     : dspi_master_interrupt_mpc5777c
 **     Processor   : MPC5777C_416
 **     Version     : Driver 01.00
 **     Compiler    : GNU C Compiler
 **     Date/Time   : 2018-10-15, 14:08, # CodeGen: 1
 **     Abstract    :
 **         Main module.
 **         This module contains user's application code.
 **     Settings    :
 **     Contents    :
 **         No public methods
 **
 ** ###################################################################*/
/*!
 ** @file main.c
 ** @version 01.00
 ** @brief
 **         Main module.
 **         This module contains user's application code.
 */
/*!
 **  @addtogroup main_module main module documentation
 **  @{
 */
/* MODULE main */
/* Including needed modules to compile this module/procedure */
#include "Cpu.h"
volatile int exit_code = 0;
/* User includes (#include below this line is not maintained by Processor Expert) */
#include <stdint.h>
#include <stdbool.h>

/* Port PTI[0] on MPC5775E-EVB */
#define LED_PORT	PTF
#define LED_PIN1    19  //LED1
#define LED_PIN2	20  //LED2
#define NUMBER_OF_FRAME  5

uint8_t masterTxBuffer_8b[NUMBER_OF_FRAME] = { 0 };
uint8_t masterRxBuffer_8b[NUMBER_OF_FRAME] = { 0 };
uint8_t slaveTxBuffer_8b[NUMBER_OF_FRAME] = { 0 };
uint8_t slaveRxBuffer_8b[NUMBER_OF_FRAME] = { 0 };

/*! 
 \brief The main function for the project.
 \details The startup initialization sequence is the following:
 * - startup asm routine
 * - main()
 */
int main(void)
{
    /*** Processor Expert internal initialization. DON'T REMOVE THIS CODE!!! ***/
#ifdef PEX_RTOS_INIT
    PEX_RTOS_INIT(); /* Initialization of the selected RTOS. Macro is defined by the RTOS component. */
#endif
    /*** End of Processor Expert internal initialization.                    ***/
    uint32_t count = 0;
    bool isCorrect = false;
    dspi_transfer_status_t spiStatus = DSPI_TRANSFER_FAIL;

    /* Load the certain data into the Tx buffer  */
    for (count = 0; count < NUMBER_OF_FRAME; count++)
    {
        masterTxBuffer_8b[count] = count;
        slaveTxBuffer_8b[count] = NUMBER_OF_FRAME - count;
    }

    /* Initialize clocks */
    CLOCK_SYS_Init(g_clockManConfigsArr, CLOCK_MANAGER_CONFIG_CNT,
                   g_clockManCallbacksArr, CLOCK_MANAGER_CALLBACK_CNT);
    CLOCK_SYS_UpdateConfiguration(0U, CLOCK_MANAGER_POLICY_AGREEMENT);
    /* Initialize LED1 */
    PINS_DRV_Init(NUM_OF_CONFIGURED_PINS, g_pin_mux_InitConfigArr);
    /* Turn off LED1 */
    PINS_DRV_ClearPins(LED_PORT, (1 << LED_PIN1));
    PINS_DRV_ClearPins(LED_PORT, (1 << LED_PIN2));

    EDMA_DRV_Init(&dmaController1_State, &dmaController1_InitConfig0,
                      edmaChnStateArray, edmaChnConfigArray,
                      EDMA_CONFIGURED_CHANNELS_COUNT);

    /* fixed the SDK issues that txAdditionalDMAChannel should
     * be different from txDMAChannel and rxDMAChannel
     * */
    dspi0_MasterInitConfigDma.txAdditionalDMAChannel = 34U;
    /* Initialize Dspi0, baudrate:500kps
     * SCK:PC[29], PCS1:PD[1], SIN:PC[30], SOUT:PC[31]
     * */
    DSPI_MasterInit(DSPI0_INSTANCE, &dspi0State, &dspi0_MasterInitConfigDma);

    /* Initialize Dspi2, baudrate:500kps
     * SCK:PH[11], PCS0:PH[14], SIN:PH[12], SOUT:PH[13]
     *  */
    DSPI_SlaveInit(DSPI2_INSTANCE, &dspi2State, &dspi2_SlaveInitConfig0);

    DSPI_MasterSetDelay(DSPI0_INSTANCE, 10, 10, 10);

    while (1)
    {
        isCorrect = false;

        /* Clear Rx buffer before starting the next transfer */
        for (count = 0; count < NUMBER_OF_FRAME; count++)
        {
            masterRxBuffer_8b[count] = 0;
            slaveRxBuffer_8b[count] = 0;
        }

        /* Transfers data between dspi0 and dspi2 instances */
        DSPI_SlaveTransfer(DSPI2_INSTANCE, slaveTxBuffer_8b, slaveRxBuffer_8b, NUMBER_OF_FRAME);
        DSPI_MasterTransfer(DSPI0_INSTANCE, masterTxBuffer_8b, masterRxBuffer_8b, NUMBER_OF_FRAME);

        do
        {
            DSPI_GetTransferStatus(DSPI0_INSTANCE, &spiStatus);
        } while (spiStatus != DSPI_TRANSFER_OK);

        do
        {
            DSPI_GetTransferStatus(DSPI2_INSTANCE, &spiStatus);
        } while (spiStatus != DSPI_TRANSFER_OK);


        /* verify the data transfers between dspi0 and dspi2 instance */
        for (count = 0; count < NUMBER_OF_FRAME; count++)
        {
            isCorrect = (masterTxBuffer_8b[count] == slaveRxBuffer_8b[count]) ? true : false;
            isCorrect = (slaveTxBuffer_8b[count] == masterRxBuffer_8b[count]) ? true : false;
        }

        if (isCorrect)
        {
            /* Toggle LED1 if data transfer between dspi 0 and dspi2 instances is correct */
            PINS_DRV_TogglePins(LED_PORT, (1 << LED_PIN1));
            OSIF_TimeDelay(200);
        }
        else
        {
            /* Toggle LED2 if data transfer between dspi 0 and dspi2 instances is incorrect */
            PINS_DRV_TogglePins(LED_PORT, (1 << LED_PIN2));
            OSIF_TimeDelay(200);
        }
    }

    /*** Don't write any code pass this line, or it will be deleted during code generation. ***/
  /*** RTOS startup code. Macro PEX_RTOS_START is defined by the RTOS component. DON'T MODIFY THIS CODE!!! ***/
  #ifdef PEX_RTOS_START
    PEX_RTOS_START();                  /* Startup of the selected RTOS. Macro is defined by the RTOS component. */
  #endif
  /*** End of RTOS startup code.  ***/
  /*** Processor Expert end of main routine. DON'T MODIFY THIS CODE!!! ***/
  for(;;) {
    if(exit_code != 0) {
      break;
    }
  }
  return exit_code;
  /*** Processor Expert end of main routine. DON'T WRITE CODE BELOW!!! ***/
} /*** End of main routine. DO NOT MODIFY THIS TEXT!!! ***/
/* END main */
/*!
 ** @}
 */
/*
 ** ###################################################################
 **
 **     This file was created by Processor Expert 10.1 [05.21]
 **     for the NXP C55 series of microcontrollers.
 **
 ** ###################################################################
 */
