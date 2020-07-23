/*
 * reset.h
 *
 *  Created on: 2020Äê7ÔÂ16ÈÕ
 *      Author: nxf47394
 */

#ifndef RESET_H_
#define RESET_H_

//#define FLEXCAN0_INIT
#define FLEXCAN1_INIT
#define TIMER_INIT
#define DSPI_INIT

void Timer_Reset(void);
void FlexCAN0_Reset(void);
void FlexCAN1_Reset(void);
void DSPI0_Reset(void);
void DSPI1_Reset(void);
void Clock_Reset(void);
void Prepare_Before_Jump(void);

#endif /* RESET_H_ */
