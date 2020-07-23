/*
 * reset.c
 *
 *  Created on: 2020Äê7ÔÂ16ÈÕ
 *      Author: nxf47394
 */
#include <stdbool.h>
#include "reset.h"
#include "MPC5746R.h"

/* This function disables PIT and STM timer. */
void Timer_Reset()
{
    unsigned char chan_num;

    for (chan_num = 0; chan_num < 8; chan_num++)
    {
        /* Disable PIT0 interrupts, timer */
        PIT_0.TIMER[chan_num].TCTRL.R = 0x00000000ul;
        /* Reset load value */
        PIT_0.TIMER[chan_num].LDVAL.R = 0x00000000ul;
        /* Clear timer interrupt flag */
        PIT_0.TIMER[chan_num].TFLG.R = 0x00000001ul;
    }

    /* PIT module clock and stop it in debug mode*/
    PIT_0.MCR.R = 0x00000007ul;

    /* Disable STM timer counter and stop it in debug mode as enabled it at the function of FblTimerInit */
    STM_0.CR.R &= 0x00000002ul;
}
/*
 * FlexCAN0 de-initialize function
 * reset its registers and shutdown the peripheral module
 */
void FlexCAN0_Reset(void)
{
    uint32_t i;
    bool enabled = false;
    uint32_t aux = 0U;
    uint32_t tempIMSK[2], tempMCR;

    /* Disable FlexCAN0 individual interrupt for a specified IRQ */
    for (i = 677; i <= 682; i++)
    {
        INTC_0.PSR[i].B.PRIN = 0;
    }

    /* The MB must be initialized before inactivate it. */
    /* Inactivate all message buffers */
    for (i = 0; i < 64; i++)
    {
        CAN_0.MB[i].CS.B.CODE = 0;
    }
    /* Enter Freeze Mode Required before to enter Disabled Mode */
    CAN_0.MCR.B.FRZ = 1;
    CAN_0.MCR.B.HALT = 1;
    if (CAN_0.MCR.B.MDIS == 0U)
    {
        enabled = true;
    }
    else
    {
        CAN_0.MCR.B.MDIS = 0U;
    }

    CAN_0.TIMER.R = 0U;
    while ((CAN_0.MCR.B.FRZACK == 0) && (aux < 730U))
    {
        /* Wait until finish counting 730 bit times and exit*/
        aux = (uint32_t)CAN_0.TIMER.R;
    }
    if (CAN_0.MCR.B.FRZACK == 0U)
    {
        /* Save registers before Soft Reset */
        tempIMSK[0] = CAN_0.IMASK1.R;
        tempIMSK[1] = CAN_0.IMASK2.R;
        tempMCR = CAN_0.MCR.R;
        /* Soft Reset FlexCan */
        CAN_0.MCR.B.SOFTRST = 1;
        while (CAN_0.MCR.B.SOFTRST == 1) {}
        /* Restore registers after Soft Reset */
        CAN_0.IMASK1.R = tempIMSK[0];
        CAN_0.IMASK2.R = tempIMSK[1];
        CAN_0.MCR.R = tempMCR;
        /* Disable the Protection again because is enabled by soft reset */
        /* Enable write of MECR register */
        CAN_0.CTRL2.B.ECRWRE = 1;
        /* Enable write of MECR */
        CAN_0.MECR.B.ECRWRDIS = 0;
        /* Disable Error Detection and Correction mechanism,
         * that will set CAN in Freeze Mode in case of trigger */
        CAN_0.MECR.B.NCEFAFRZ = 0;
        /* Disable write of MECR */
        CAN_0.CTRL2.B.ECRWRE = 0;
    }

    /* Wait for entering the freeze mode */
    while (CAN_0.MCR.B.FRZACK == 0) {}
    if (false == enabled)
    {
        CAN_0.MCR.B.MDIS = 1;
        /* Wait until disable mode acknowledged */
        while (CAN_0.MCR.B.LPMACK == 0U) {}
    }

    /* Disable FlexCAN.*/
    /* To access the memory mapped registers */
    /* Enter disable mode (hard reset). */
    if (CAN_0.MCR.B.MDIS == 0U)
    {
        /* Clock disable (module) */
        CAN_0.MCR.B.MDIS = 1;

        /* Wait until disable mode acknowledged */
        while (CAN_0.MCR.B.LPMACK == 0U) {}
    }
}

/*
 * FlexCAN1 de-initialize function
 * reset its registers and shutdown the peripheral module
 */
void FlexCAN1_Reset(void)
{
    uint32_t i;
    bool enabled = false;
    uint32_t aux = 0U;
    uint32_t tempIMSK[2], tempMCR;

    /* Disable FlexCAN0 individual interrupt for a specified IRQ */
    for (i = 683; i <= 688; i++)
    {
        INTC_0.PSR[i].B.PRIN = 0;
    }
#if 1
    /* The MB must be initialized before inactivate it. */
    /* Inactivate all message buffers */
    for (i = 0; i < 64; i++)
    {
        CAN_1.MB[i].CS.B.CODE = 0;
    }
#endif
    /* Enter Freeze Mode Required before to enter Disabled Mode */
    CAN_1.MCR.B.FRZ = 1;
    CAN_1.MCR.B.HALT = 1;
    if (CAN_1.MCR.B.MDIS == 0U)
    {
        enabled = true;
    }
    else
    {
        CAN_1.MCR.B.MDIS = 0U;
    }

    CAN_1.TIMER.R = 0U;
    while ((CAN_1.MCR.B.FRZACK == 0) && (aux < 730U))
    {
        /* Wait until finish counting 730 bit times and exit*/
        aux = (uint32_t)CAN_1.TIMER.R;
    }
    if (CAN_1.MCR.B.FRZACK == 0U)
    {
        /* Save registers before Soft Reset */
        tempIMSK[0] = CAN_1.IMASK1.R;
        tempIMSK[1] = CAN_1.IMASK2.R;
        tempMCR = CAN_1.MCR.R;
        /* Soft Reset FlexCan */
        CAN_1.MCR.B.SOFTRST = 1;
        while (CAN_1.MCR.B.SOFTRST == 1) {}
        /* Restore registers after Soft Reset */
        CAN_1.IMASK1.R = tempIMSK[0];
        CAN_1.IMASK2.R = tempIMSK[1];
        CAN_1.MCR.R = tempMCR;
        /* Disable the Protection again because is enabled by soft reset */
        /* Enable write of MECR register */
        CAN_1.CTRL2.B.ECRWRE = 1;
        /* Enable write of MECR */
        CAN_1.MECR.B.ECRWRDIS = 0;
        /* Disable Error Detection and Correction mechanism,
         * that will set CAN in Freeze Mode in case of trigger */
        CAN_1.MECR.B.NCEFAFRZ = 0;
        /* Disable write of MECR */
        CAN_1.CTRL2.B.ECRWRE = 0;
    }

    /* Wait for entering the freeze mode */
    while (CAN_1.MCR.B.FRZACK == 0) {}
    if (false == enabled)
    {
        CAN_1.MCR.B.MDIS = 1;
        /* Wait until disable mode acknowledged */
        while (CAN_1.MCR.B.LPMACK == 0U) {}
    }

    /* Disable FlexCAN.*/
    /* To access the memory mapped registers */
    /* Enter disable mode (hard reset). */
    if (CAN_1.MCR.B.MDIS == 0U)
    {
        /* Clock disable (module) */
        CAN_1.MCR.B.MDIS = 1;

        /* Wait until disable mode acknowledged */
        while (CAN_1.MCR.B.LPMACK == 0U) {}
    }
}

void DSPI0_Reset(void)
{
    uint32_t i;

    /* Disable module clocks, clear the TX & RX FIFO counter, Stop transfers */
    DSPI_0.MCR.R = 0x00000C01u;
    /* Clear transfer counter */
    DSPI_0.TCR.R = 0;
    /* Reset clock and transfer attributes */
    for (i = 0U; i < 8; i++)
    {
        DSPI_0.MODE.CTAR[i].R = 0;
        DSPI_0.CTARE[i].R = 0;
    }

    /* Clear status register */
    DSPI_0.SR.R = 0xFFFFFFFFU;
    /* Disable all interrupt */
    DSPI_0.RSER.R = 0;

    /* Disable DSPI0 individual interrupt for a specified IRQ */
    for (i = 259; i <= 266; i++)
    {
        INTC_0.PSR[i].B.PRIN = 0;
    }
}

void DSPI1_Reset(void)
{
    uint32_t i;

    /* Disable module clocks, clear the TX & RX FIFO counter, Stop transfers */
    DSPI_1.MCR.R = 0x00000C01u;
    /* Clear transfer counter */
    DSPI_1.TCR.R = 0;
    /* Reset clock and transfer attributes */
    for (i = 0U; i< 8; i++)
    {
        DSPI_1.MODE.CTAR[i].R = 0;
        DSPI_1.CTARE[i].R = 0;
    }

    /* Clear status register */
    DSPI_1.SR.R = 0xFFFFFFFFU;
    /* Disable all interrupt */
    DSPI_1.RSER.R = 0;

    /* Disable DSPI1 individual interrupt for a specified IRQ */
    for (i = 268; i <= 275; i++)
    {
        INTC_0.PSR[i].B.PRIN = 0;
    }
}

void Clock_Reset(void)
{
    uint32_t i;

    PLLDIG.PLL0DV.R = 0u;
    PLLDIG.PLL1DV.R = 0u;
    /* Enables IRC sources. Disables XOSC and PLL sources. Sets IRC source as system clock */
    MC_ME.DRUN_MC.R = 0x00130010;

    /* Reset run peripheral configurations */
    for (i = 0; i <= 8; i++)
    {
        MC_ME.RUN_PC[i].R = 0;
    }
#if 1
    /* Clock sources are enabled after mode transition */
    /* Mode Transition to enter DRUN mode */
    MC_ME.MCTL.R = 0x30005AF0;      /* Enter DRUN Mode & Key */
    MC_ME.MCTL.R = 0x3000A50F;      /* Enter DRUN Mode & Inverted Key */
    while (MC_ME.GS.B.S_MTRANS);  /* Wait for mode transition to complete */
    while (MC_ME.GS.B.S_CURRENT_MODE != 3);  /* Verify DRUN is the current mode */
#endif
}

/* do the preparation for bootloader jump to user app */
void Prepare_Before_Jump(void)
{
#ifdef TIMER_INIT
    /*Reset the initialized PIT and STM module*/
    Timer_Reset();
#endif
#ifdef FLEXCAN0_INIT
    /*Reset and shutdown FlexCAN0 module*/
    FlexCAN0_Reset();
#endif
#ifdef FLEXCAN1_INIT
    /*Reset and shutdown FlexCAN1 module*/
    FlexCAN1_Reset();
#endif
#ifdef DSPI_INIT
    /*Reset DSPI0, DSPI1 module*/
    DSPI0_Reset();
    DSPI1_Reset();
#endif
    /*Reset system clock module*/
    Clock_Reset();
    /*Disable the CPU interrupt*/
    __asm__(" wrteei 0 ");
}
