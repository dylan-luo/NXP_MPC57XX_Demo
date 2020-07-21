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
**     Filename    : main.c
**     Processor   : MPC574xR
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


/* Including necessary module. Cpu.h contains other modules needed for compiling.*/
#include "Cpu.h"

volatile int exit_code = 0;
/* User includes (#include below this line is not maintained by Processor Expert) */
#include "clk.h"
#include "port.h"
#include "uart.h"
#include "timer.h"
#include "can.h"
#include "flash.h"
#include "eeprom.h"
#include "spi.h"
#include "ramcode.h"
#include "reset.h"

/*******************************************************************************
 * Definitions
 ******************************************************************************/
#undef UART_TEST
#undef TIMER_TEST
#undef CAN_TEST
#undef FLASH_TEST
#undef EEPROM_TEST
#undef SPI_TEST
#undef RAMCODE_TEST
/* Only one demo example can run at the same time. */
//#define CAN_TEST

#define BIN_WELCOME "\r\nWelcome to MPC5746R SDK Demo "
#define BIN_VERSION "20200721-0.0.1"

/*!
  \brief The main function for the project.
  \details The startup initialization sequence is the following:
 * - startup asm routine
 * - main()
*/
int main(void)
{
    /* Write your local variable definition here */

    /*** Processor Expert internal initialization. DON'T REMOVE THIS CODE!!! ***/
    #ifdef PEX_RTOS_INIT
        PEX_RTOS_INIT();                   /* Initialization of the selected RTOS. Macro is defined by the RTOS component. */
    #endif
    /*** End of Processor Expert internal initialization.                    ***/

    /* Write your code here */

    /* Do the initializations required for this application */
    /* SYS_CLK = 100MHz, output with PJ[1] */
    /* FXBAR_CLK = 100MHz */
    /* SXBAR_CLK = 50MHz */
    /* PER_CLK   = 25MHz */
    DevAssert(STATUS_SUCCESS == CLOCK_Init());
    DevAssert(STATUS_SUCCESS == PORT_Init());
    /* baudrate = 115200 bps, RX PF[1], TX PF[0] */
    DevAssert(STATUS_SUCCESS == UART_Init());
    /* Enable system global interrupt */
	INT_SYS_EnableIRQGlobal();

    UART_Printf(BIN_WELCOME);
    UART_Printf(BIN_VERSION);
    UART_Printf("\r\nBuild Date: %s, %s\r\n", __DATE__, __TIME__);

#ifdef FLEXCAN0_INIT
	/* FlexCAN0, 500kps, TX PF[12], RX PF[13] */
	DevAssert(STATUS_SUCCESS == CAN_Init());
#endif
#ifdef TIMER_INIT
	/* PIT_0, 1s interrupt */
	DevAssert(STATUS_SUCCESS == TIMER_Init());
#endif
#ifdef DSPI_INIT
    /* DSPI_0 Master: baudrate = 500 kbit/s */
    /* SCK PJ[14], CS Output PK[5], CS Input PK[5], SDI PK[1], SDO PK[2] */
    /* DSPI_1 Slave : baudrate = 500 kbit/s */
    /* SCK PG[13], CS Input PG[9], SDI PG[11], SDO PG[12] */
	DevAssert(STATUS_SUCCESS == SPI_Init());
#endif
#ifdef UART_TEST
    UART_Task();
#endif

#ifdef TIMER_TEST
    /* 1 ms interrupt */
    DevAssert(STATUS_SUCCESS == TIMER_Init());
    TIMER_Task();
#endif

#ifdef CAN_TEST
    /* bitrate = 500 kbit/s, RX PF[13], TX PF[12] */
    DevAssert(STATUS_SUCCESS == CAN_Init());
    CAN_Task();
#endif

#ifdef FLASH_TEST
    DevAssert(STATUS_SUCCESS == FLASH_Init());
    FLASH_Task();
#endif

#ifdef EEPROM_TEST
    /* All 10 eeprom blocks are initialized. */
    DevAssert(STATUS_SUCCESS == EEPROM_Init());
    EEPROM_Task();
#endif

#ifdef SPI_TEST
    /* DSPI_0 Master: baudrate = 500 kbit/s */
    /* SCK PJ[14], CS Output PK[5], CS Input PK[5], SDI PK[1], SDO PK[2] */
    /* DSPI_1 Slave : baudrate = 500 kbit/s */
    /* SCK PG[13], CS Input PG[9], SDI PG[11], SDO PG[12] */
    DevAssert(STATUS_SUCCESS == SPI_Init());
    SPI_Task();
#endif

#ifdef RAMCODE_TEST
    /* When you debug, you can check PC pointer whether points to the 'RAM' section. */
    /* Actually, it points to the local_imem (RAM of cpu) section. */
    RAMCODE_Task();
#endif

    /* Toggle PH[0] pin 20 time, shows the program is running well before de-init */
    for (int i = 0; i < 20; i++)
    {
        PINS_DRV_TogglePins(PTH, 1 << 0);
        OSIF_TimeDelay(200);
    }
    /* De-init peripherals used, Sets IRC source as system clock */
    Prepare_Before_Jump();
    /* Indicates that passes the de-init */
    PINS_DRV_ClearPins(PTH, 1 << 0);
    PINS_DRV_ClearPins(PTH, 1 << 1);

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
