/* ---------------------------------------------------------------------------------------*/
/*  @file:    startup_MPC5746R.S                                                          */
/*  @purpose: GNU Compiler Collection Startup File                                        */
/*            MPC5746R                                                                    */
/*  @version: 1.0                                                                         */
/*  @date:    2017-2-9                                                                    */
/*  @build:   #                                                                           */
/* ---------------------------------------------------------------------------------------*/
/*                                                                                        */
/* Copyright 2018-2019 NXP                                                                */
/* All rights reserved.                                                                   */
/*                                                                                        */
/* THIS SOFTWARE IS PROVIDED BY NXP "AS IS" AND ANY EXPRESSED OR                          */
/* IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES              */
/* OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.                */
/* IN NO EVENT SHALL NXP OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT,                    */
/* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES                     */
/* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR                     */
/* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)                     */
/* HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,                    */
/* STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING                  */
/* IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF                         */
/* THE POSSIBILITY OF SUCH DAMAGE.                                                        */
/*****************************************************************************/
/* Version: GNU Compiler Collection                                          */

/* ----------------------------------------------------------------------------
   -- Boot header configuration
   ---------------------------------------------------------------------------- */
#if defined(TURN_ON_CPU0)
#define CPU0_ENABLED  0x00000006
#else
#define CPU0_ENABLED  0x0
#endif /* defined(TURN_ON_CPU0) */
#if defined(TURN_ON_CPU1)
#define CPU1_ENABLED  0x00000008
#else
#define CPU1_ENABLED  0x0
#endif /* defined(TURN_ON_CPU1) */
#define MPC57xx_ID    0x005A0000
#define RCHW_VAL (MPC57xx_ID | CPU0_ENABLED | CPU1_ENABLED)

#ifndef I_CACHE
#define I_CACHE
#endif
#ifndef ICACHE_ENABLE
#define ICACHE_ENABLE 0
#endif

#ifndef DISABLE_WDOG
#define DISABLE_WDOG  1
#endif
/* There are 3 intances in total        */
/* but only 2 are one after the other   */
/* the third one is treated separately. */
#ifndef SWT_COUNT
#define SWT_COUNT     2
#endif
#ifndef SWT_BASE_ADDR
#define SWT_BASE_ADDR   0xFC050000
#endif

/* Init table */
    .section .init_table, "a"
    .long 5
    .long __VECTOR_TABLE
    .long __VECTOR_RAM
    .long __VECTOR_TABLE_COPY_END
    .long __CUSTOM_ROM
    .long __CUSTOM_RAM
    .long __CUSTOM_END
    .long __DATA_ROM
    .long __DATA_RAM
    .long __DATA_END
    .long __SDATA_ROM
    .long __SDATA_RAM
    .long __SDATA_END
    .long __CODE_ROM
    .long __CODE_RAM
    .long __CODE_END
/* Zero table */
    .section .zero_table, "a"
    .long 2
    .long __SBSS_START
    .long __SBSS_END
    .long __BSS_START
    .long __BSS_END

#ifdef TURN_ON_CPU0
    .section .cpu0_reset_vector, "a"
    .long       __start

    .section .cpuc_reset_vector, "a"
    .long       __start
#endif
#ifdef TURN_ON_CPU1
    .section .cpu1_reset_vector, "a"
    .long       __start

    .section .rchw, "a"
    .long RCHW_VAL
#endif
    .section .startup, "ax"

    .globl    _start
    .globl    Reset_Handler
Reset_Handler:
_start:
    wrteei 0    ;# Disable interrupts


;#**************************** Init Core Registers ****************************
;# The E200Z4 core needs its registers initialising before they are used
;# otherwise in Lock Step mode the two cores will contain different random data.
;# If this is stored to memory (e.g. stacked) it will cause a Lock Step error.

;# GPRs 0-31
    e_li    r0, 0
    e_li    r1, 0
    e_li    r2, 0
    e_li    r3, 0
    e_li    r4, 0
    e_li    r5, 0
    e_li    r6, 0
    e_li    r7, 0
    e_li    r8, 0
    e_li    r9, 0
    e_li    r10, 0
    e_li    r11, 0
    e_li    r12, 0
    e_li    r13, 0
    e_li    r14, 0
    e_li    r15, 0
    e_li    r16, 0
    e_li    r17, 0
    e_li    r18, 0
    e_li    r19, 0
    e_li    r20, 0
    e_li    r21, 0
    e_li    r22, 0
    e_li    r23, 0
    e_li    r24, 0
    e_li    r25, 0
    e_li    r26, 0
    e_li    r27, 0
    e_li    r28, 0
    e_li    r29, 0
    e_li    r30, 0
    e_li    r31, 0

;# Init any other CPU register which might be stacked (before being used).

    mtspr    1, r1          ;#XER
    mtcrf    0xFF, r1
    mtspr    CTR, r1
    mtspr    272, r1        ;#SPRG0
    mtspr    273, r1        ;#SPRG1
    mtspr    274, r1        ;#SPRG2
    mtspr    275, r1        ;#SPRG3
    mtspr    58, r1         ;#CSRR0
    mtspr    59, r1         ;#CSRR1
    mtspr    570, r1        ;#MCSRR0
    mtspr    571, r1        ;#MCSRR1
    mtspr    61, r1         ;#DEAR
    mtspr    63, r1         ;#IVPR
    mtspr    256, r1        ;#USPRG0
    mtspr    62, r1         ;#ESR
    mtspr    8, r31         ;#LR

;#***************************** DISABLE WATCHDOG *****************************
#if DISABLE_WDOG
    e_lis   r4, SWT_BASE_ADDR@h   ;# Initialize the base address of SWT_0
    e_or2i  r4, SWT_BASE_ADDR@l

    e_li    r5, SWT_COUNT@l
    mtctr   r5                    ;# Move to counter number of SWT instances

disable_swt:
    e_li    r3, 0xC520
    e_stw   r3, 0x10(r4)          ;# Write the watchdog unlock value 0xc520

    e_li    r3, 0xD928
    e_stw   r3, 0x10(r4)          ;# Write the watchdog unlock value 0xD928

    e_lis   r3, 0xFF00
    e_or2i  r3, 0x0102
    e_stw   r3, 0(r4)             ;# Write reset value with SWT disabled

    e_addi  r4,r4, 0x4000         ;# Increase the pointer to the next instance of SWT
    e_bdnz  disable_swt           ;# Loop for all instance of SWT


    e_addi  r4,r4, 0x4000         ;# Increase the pointer to the base address of SWT_3 (Security)

    e_li    r3, 0xC520
    e_stw   r3, 0x10(r4)          ;# Write the watchdog unlock value 0xc520

    e_li    r3, 0xD928
    e_stw   r3, 0x10(r4)          ;# Write the watchdog unlock value 0xD928

    e_lis   r3, 0xFF00
    e_or2i  r3, 0x0102
    e_stw   r3, 0(r4)             ;# Write reset value with SWT disabled
#endif

;#***************************** Initialise SRAM ECC **************************
;# Store number of 128Byte (32GPRs) segments in Counter
    e_lis       r5, __SRAM_SIZE@h  # Initialize r5 to size of SRAM (Bytes)
    e_or2i      r5, __SRAM_SIZE@l
    e_srwi      r5, r5, 0x7         ;# Divide SRAM size by 128
    mtctr       r5                  ;# Move to counter for use with "bdnz"

;# Base Address of the internal SRAM
    e_lis       r5, __SRAM_BASE_ADDR@h
    e_or2i      r5, __SRAM_BASE_ADDR@l

;# Fill SRAM with writes of 32GPRs
sram_loop:
    e_stmw      r0, 0(r5)           ;# Write all 32 registers to SRAM
    e_addi      r5, r5, 128         ;# Increment the RAM pointer to next 128bytes
    e_bdnz      sram_loop           ;# Loop for all of SRAM

;#************************ Initialise Local Data SRAM ECC *********************
;# Store number of 128Byte (32GPRs) segments in Counter
 e_lis       r5, __LOCAL_DMEM_SIZE@h  ;#Initialize r5 to size of SRAM (Bytes)
 e_or2i      r5, __LOCAL_DMEM_SIZE@l
 e_srwi      r5, r5, 0x7            ;#Divide SRAM size by 128
 mtctr       r5                     ;#Move to counter for use with "bdnz"

;# Base Address of the Local SRAM
 e_lis       r5, __LOCAL_DMEM_BASE_ADDR@h
 e_or2i      r5, __LOCAL_DMEM_BASE_ADDR@l

;# Fill Local SRAM with writes of 32GPRs
ldmem_loop:
    e_stmw      r0,0(r5)             ;# Write all 32 registers to SRAM
    e_addi      r5,r5,128            ;#Increment the RAM pointer to next 128bytes
    e_bdnz      ldmem_loop           ;# Loop for all of SRAM

;#************************ Initialise Local Instruction SRAM ECC *********************
;# Store number of 128Byte (32GPRs) segments in Counter
 e_lis       r5, __LOCAL_IMEM_SIZE@h  ;#Initialize r5 to size of SRAM (Bytes)
 e_or2i      r5, __LOCAL_IMEM_SIZE@l
 e_srwi      r5, r5, 0x7            ;#Divide SRAM size by 128
 mtctr       r5                     ;#Move to counter for use with "bdnz"

;# Base Address of the Local SRAM
 e_lis       r5, __LOCAL_IMEM_BASE_ADDR@h
 e_or2i      r5, __LOCAL_IMEM_BASE_ADDR@l

;# Fill Local SRAM with writes of 32GPRs
limem_loop:
    e_stmw      r0,0(r5)             ;# Write all 32 registers to SRAM
    e_addi      r5,r5,128            ;#Increment the RAM pointer to next 128bytes
    e_bdnz      limem_loop           ;# Loop for all of SRAM

;#********************************* Enable BTB ********************************
;# Flush & Enable BTB - Set BBFI bit in BUCSR
    e_li      r3, 0x201
    mtspr     1013, r3
    se_isync

;#******************** Clear reservations on external interrupt *****************
;# Set ICR in HID0
    e_lis     r3, 0x2
    mtspr     1008, r3
    se_isync

;#*************************** Enable ME Bit in MSR *****************************
    mfmsr    r6
    e_or2i   r6, 0x1000
    mtmsr    r6

#if defined(I_CACHE) && (ICACHE_ENABLE == 1)
;#****************** Invalidate and Enable the Instruction cache **************
__icache_cfg:
    e_li     r5, 0x2
    mtspr    1011, r5

    e_li     r7, 0x4
    e_li     r8, 0x2
    e_lis    r11, 0xFFFF
    e_or2i   r11, 0xFFFB

__icache_inv:
    mfspr    r9, 1011
    and.     r10, r7, r9
    e_beq    __icache_no_abort
    and.     r10, r11, r9
    mtspr    1011, r10
    e_b      __icache_cfg

__icache_no_abort:
    and.     r10, r8, r9
    e_bne    __icache_inv

    mfspr    r5, 1011
    e_ori    r5, r5, 0x0001
    se_isync
    mtspr    1011, r5
#endif

;#****************************** Configure Stack *****************************
    e_lis       r1, __SP_INIT@h         ;# Initialize stack pointer r1 to
    e_or2i      r1, __SP_INIT@l         ;# value in linker command file.

    e_lis       r13, _SDA_BASE_@h       ;# Initialize r13 to sdata base
    e_or2i      r13, _SDA_BASE_@l       ;# (provided by linker).

    e_lis       r2, _SDA2_BASE_@h       ;# Initialize r2 to sdata2 base
    e_or2i      r2, _SDA2_BASE_@l       ;# (provided by linker).

    e_stwu      r0, -64(r1)             ;# Terminate stack.

#ifndef __NO_SYSTEM_INIT
;# Call the system init routine
    e_bl   SystemInit
#endif
;# Init .data and .bss sections
    e_bl   init_data_bss
    wrteei 1    ;# Enable interrupts
;# Call custom init function
;# This symbol must be defined in the ASM preprocessor e.g -DCUSTOM_INIT=my_func, 
;# where my_func is a void function that does not take any parameters and it is defined in the application code
#ifdef CUSTOM_INIT
    e_bl CUSTOM_INIT
#endif

;# Jump to Main
    e_bl        main

    .section .intc_vector_table, "a"
    .align 2
    .globl __isr_vector
__isr_vector:
    .long   SS0_IRQHandler                   /* Vector   0 Software setable flag 0 SSCIR0[CLR0] */
    .long   SS1_IRQHandler                   /* Vector   1 Software setable flag 1 SSCIR0[CLR1] */
    .long   SS2_IRQHandler                   /* Vector   2 Software setable flag 2 SSCIR0[CLR2] */
    .long   SS3_IRQHandler                   /* Vector   3 Software setable flag 3 SSCIR0[CLR3] */
    .long   SS4_IRQHandler                   /* Vector   4 Software setable flag 4 SSCIR0[CLR4] */
    .long   SS5_IRQHandler                   /* Vector   5 Software setable flag 5 SSCIR0[CLR5] */
    .long   SS6_IRQHandler                   /* Vector   6 Software setable flag 6 SSCIR0[CLR6] */
    .long   SS7_IRQHandler                   /* Vector   7 Software setable flag 7 SSCIR0[CLR7] */
    .long   SS8_IRQHandler                   /* Vector   8 Software setable flag 8 SSCIR0[CLR8] */
    .long   SS9_IRQHandler                   /* Vector   9 Software setable flag 9 SSCIR0[CLR9] */
    .long   SS10_IRQHandler                  /* Vector  10 Software setable flag 10 SSCIR0[CLR10] */
    .long   SS11_IRQHandler                  /* Vector  11 Software setable flag 11 SSCIR0[CLR11] */
    .long   SS12_IRQHandler                  /* Vector  12 Software setable flag 12 SSCIR0[CLR12] */
    .long   SS13_IRQHandler                  /* Vector  13 Software setable flag 13 SSCIR0[CLR13] */
    .long   SS14_IRQHandler                  /* Vector  14 Software setable flag 14 SSCIR0[CLR14] */
    .long   SS15_IRQHandler                  /* Vector  15 Software setable flag 15 SSCIR0[CLR15] */
    .long   SS16_IRQHandler                  /* Vector  16 Software setable flag 16 SSCIR0[CLR16] */
    .long   SS17_IRQHandler                  /* Vector  17 Software setable flag 17 SSCIR0[CLR17] */
    .long   SS18_IRQHandler                  /* Vector  18 Software setable flag 18 SSCIR0[CLR18] */
    .long   SS19_IRQHandler                  /* Vector  19 Software setable flag 19 SSCIR0[CLR19] */
    .long   SS20_IRQHandler                  /* Vector  20 Software setable flag 20 SSCIR0[CLR20] */
    .long   SS21_IRQHandler                  /* Vector  21 Software setable flag 21 SSCIR0[CLR21] */
    .long   SS22_IRQHandler                  /* Vector  22 Software setable flag 22 SSCIR0[CLR22] */
    .long   SS23_IRQHandler                  /* Vector  23 Software setable flag 23 SSCIR0[CLR23] */
    .long   SS24_IRQHandler                  /* Vector  24 Software setable flag 24 SSCIR0[CLR24] */
    .long   SS25_IRQHandler                  /* Vector  25 Software setable flag 25 SSCIR0[CLR25] */
    .long   SS26_IRQHandler                  /* Vector  26 Software setable flag 26 SSCIR0[CLR26] */
    .long   SS27_IRQHandler                  /* Vector  27 Software setable flag 27 SSCIR0[CLR27] */
    .long   SS28_IRQHandler                  /* Vector  28 Software setable flag 28 SSCIR0[CLR28] */
    .long   SS29_IRQHandler                  /* Vector  29 Software setable flag 29 SSCIR0[CLR29] */
    .long   SS30_IRQHandler                  /* Vector  30 Software setable flag 30 SSCIR0[CLR30] */
    .long   SS31_IRQHandler                  /* Vector  31 Software setable flag 31 SSCIR0[CLR31] */
    .long   SWT0_IRQHandler                  /* Vector  32 Platform watchdog timer 0 SWT_0_IR[TIF] */
    .long   SWT1_IRQHandler                  /* Vector  33 Platform watchdog timer 1 SWT_1_IR[TIF] */
    .long   DefaultISR                       /* Vector  34 */
    .long   SWT3_IRQHandler                  /* Vector  35 Platform watchdog timer 3 SWT_3_IR[TIF] */
    .long   STM0_CIR0_IRQHandler             /* Vector  36 Platform periodic timer 0_0 (STM) STM_0_CIR0[CIF] */
    .long   STM0_CIR1_IRQHandler             /* Vector  37 Platform periodic timer 0_1 (STM) STM_0_CIR1[CIF] */
    .long   STM0_CIR2_IRQHandler             /* Vector  38 Platform periodic timer 0_2 (STM) STM_0_CIR2[CIF] */
    .long   STM0_CIR3_IRQHandler             /* Vector  39 Platform periodic timer 0_3 (STM) STM_0_CIR3[CIF] */
    .long   STM1_CIR0_IRQHandler             /* Vector  40 Platform periodic timer 1_0 (STM) STM_1_CIR0[CIF] */
    .long   STM1_CIR1_IRQHandler             /* Vector  41 Platform periodic timer 1_1 (STM) STM_1_CIR1[CIF] */
    .long   STM1_CIR2_IRQHandler             /* Vector  42 Platform periodic timer 1_2 (STM) STM_1_CIR2[CIF] */
    .long   STM1_CIR3_IRQHandler             /* Vector  43 Platform periodic timer 1_3 (STM) STM_1_CIR3[CIF] */
    .long   DefaultISR                       /* Vector  44 */
    .long   DefaultISR                       /* Vector  45 */
    .long   DefaultISR                       /* Vector  46 */
    .long   DefaultISR                       /* Vector  47 */
    .long   DefaultISR                       /* Vector  48 */
    .long   DefaultISR                       /* Vector  49 */
    .long   DefaultISR                       /* Vector  50 */
    .long   DefaultISR                       /* Vector  51 */
    .long   DMA0_Ch0_Ch63_Error_IRQHandler   /* Vector  52 eDMA0 Combined Error 0-63 */
    .long   DMA0_Ch0_IRQHandler              /* Vector  53 eDMA0 Channel 0 */
    .long   DMA0_Ch1_IRQHandler              /* Vector  54 eDMA0 Channel 1 */
    .long   DMA0_Ch2_IRQHandler              /* Vector  55 eDMA0 Channel 2 */
    .long   DMA0_Ch3_IRQHandler              /* Vector  56 eDMA0 Channel 3 */
    .long   DMA0_Ch4_IRQHandler              /* Vector  57 eDMA0 Channel 4 */
    .long   DMA0_Ch5_IRQHandler              /* Vector  58 eDMA0 Channel 5 */
    .long   DMA0_Ch6_IRQHandler              /* Vector  59 eDMA0 Channel 6 */
    .long   DMA0_Ch7_IRQHandler              /* Vector  60 eDMA0 Channel 7 */
    .long   DMA0_Ch8_IRQHandler              /* Vector  61 eDMA0 Channel 8 */
    .long   DMA0_Ch9_IRQHandler              /* Vector  62 eDMA0 Channel 9 */
    .long   DMA0_Ch10_IRQHandler             /* Vector  63 eDMA0 Channel 10 */
    .long   DMA0_Ch11_IRQHandler             /* Vector  64 eDMA0 Channel 11 */
    .long   DMA0_Ch12_IRQHandler             /* Vector  65 eDMA0 Channel 12 */
    .long   DMA0_Ch13_IRQHandler             /* Vector  66 eDMA0 Channel 13 */
    .long   DMA0_Ch14_IRQHandler             /* Vector  67 eDMA0 Channel 14 */
    .long   DMA0_Ch15_IRQHandler             /* Vector  68 eDMA0 Channel 15 */
    .long   DMA0_Ch16_IRQHandler             /* Vector  69 eDMA0 Channel 16 */
    .long   DMA0_Ch17_IRQHandler             /* Vector  70 eDMA0 Channel 17 */
    .long   DMA0_Ch18_IRQHandler             /* Vector  71 eDMA0 Channel 18 */
    .long   DMA0_Ch19_IRQHandler             /* Vector  72 eDMA0 Channel 19 */
    .long   DMA0_Ch20_IRQHandler             /* Vector  73 eDMA0 Channel 20 */
    .long   DMA0_Ch21_IRQHandler             /* Vector  74 eDMA0 Channel 21 */
    .long   DMA0_Ch22_IRQHandler             /* Vector  75 eDMA0 Channel 22 */
    .long   DMA0_Ch23_IRQHandler             /* Vector  76 eDMA0 Channel 23 */
    .long   DMA0_Ch24_IRQHandler             /* Vector  77 eDMA0 Channel 24 */
    .long   DMA0_Ch25_IRQHandler             /* Vector  78 eDMA0 Channel 25 */
    .long   DMA0_Ch26_IRQHandler             /* Vector  79 eDMA0 Channel 26 */
    .long   DMA0_Ch27_IRQHandler             /* Vector  80 eDMA0 Channel 27 */
    .long   DMA0_Ch28_IRQHandler             /* Vector  81 eDMA0 Channel 28 */
    .long   DMA0_Ch29_IRQHandler             /* Vector  82 eDMA0 Channel 29 */
    .long   DMA0_Ch30_IRQHandler             /* Vector  83 eDMA0 Channel 30 */
    .long   DMA0_Ch31_IRQHandler             /* Vector  84 eDMA0 Channel 31 */
    .long   DMA0_Ch32_IRQHandler             /* Vector  85 eDMA0 Channel 32 */
    .long   DMA0_Ch33_IRQHandler             /* Vector  86 eDMA0 Channel 33 */
    .long   DMA0_Ch34_IRQHandler             /* Vector  87 eDMA0 Channel 34 */
    .long   DMA0_Ch35_IRQHandler             /* Vector  88 eDMA0 Channel 35 */
    .long   DMA0_Ch36_IRQHandler             /* Vector  89 eDMA0 Channel 36 */
    .long   DMA0_Ch37_IRQHandler             /* Vector  90 eDMA0 Channel 37 */
    .long   DMA0_Ch38_IRQHandler             /* Vector  91 eDMA0 Channel 38 */
    .long   DMA0_Ch39_IRQHandler             /* Vector  92 eDMA0 Channel 39 */
    .long   DMA0_Ch40_IRQHandler             /* Vector  93 eDMA0 Channel 40 */
    .long   DMA0_Ch41_IRQHandler             /* Vector  94 eDMA0 Channel 41 */
    .long   DMA0_Ch42_IRQHandler             /* Vector  95 eDMA0 Channel 42 */
    .long   DMA0_Ch43_IRQHandler             /* Vector  96 eDMA0 Channel 43 */
    .long   DMA0_Ch44_IRQHandler             /* Vector  97 eDMA0 Channel 44 */
    .long   DMA0_Ch45_IRQHandler             /* Vector  98 eDMA0 Channel 45 */
    .long   DMA0_Ch46_IRQHandler             /* Vector  99 eDMA0 Channel 46 */
    .long   DMA0_Ch47_IRQHandler             /* Vector 100 eDMA0 Channel 47 */
    .long   DMA0_Ch48_IRQHandler             /* Vector 101 eDMA0 Channel 48 */
    .long   DMA0_Ch49_IRQHandler             /* Vector 102 eDMA0 Channel 49 */
    .long   DMA0_Ch50_IRQHandler             /* Vector 103 eDMA0 Channel 50 */
    .long   DMA0_Ch51_IRQHandler             /* Vector 104 eDMA0 Channel 51 */
    .long   DMA0_Ch52_IRQHandler             /* Vector 105 eDMA0 Channel 52 */
    .long   DMA0_Ch53_IRQHandler             /* Vector 106 eDMA0 Channel 53 */
    .long   DMA0_Ch54_IRQHandler             /* Vector 107 eDMA0 Channel 54 */
    .long   DMA0_Ch55_IRQHandler             /* Vector 108 eDMA0 Channel 55 */
    .long   DMA0_Ch56_IRQHandler             /* Vector 109 eDMA0 Channel 56 */
    .long   DMA0_Ch57_IRQHandler             /* Vector 110 eDMA0 Channel 57 */
    .long   DMA0_Ch58_IRQHandler             /* Vector 111 eDMA0 Channel 58 */
    .long   DMA0_Ch59_IRQHandler             /* Vector 112 eDMA0 Channel 59 */
    .long   DMA0_Ch60_IRQHandler             /* Vector 113 eDMA0 Channel 60 */
    .long   DMA0_Ch61_IRQHandler             /* Vector 114 eDMA0 Channel 61 */
    .long   DMA0_Ch62_IRQHandler             /* Vector 115 eDMA0 Channel 62 */
    .long   DMA0_Ch63_IRQHandler             /* Vector 116 eDMA0 Channel 63 */
    .long   DefaultISR                       /* Vector 117 */
    .long   DefaultISR                       /* Vector 118 */
    .long   DefaultISR                       /* Vector 119 */
    .long   DefaultISR                       /* Vector 120 */
    .long   DefaultISR                       /* Vector 121 */
    .long   DefaultISR                       /* Vector 122 */
    .long   DefaultISR                       /* Vector 123 */
    .long   DefaultISR                       /* Vector 124 */
    .long   DefaultISR                       /* Vector 125 */
    .long   DefaultISR                       /* Vector 126 */
    .long   DefaultISR                       /* Vector 127 */
    .long   DefaultISR                       /* Vector 128 */
    .long   DefaultISR                       /* Vector 129 */
    .long   DefaultISR                       /* Vector 130 */
    .long   DefaultISR                       /* Vector 131 */
    .long   DefaultISR                       /* Vector 132 */
    .long   DefaultISR                       /* Vector 133 */
    .long   DefaultISR                       /* Vector 134 */
    .long   DefaultISR                       /* Vector 135 */
    .long   DefaultISR                       /* Vector 136 */
    .long   DefaultISR                       /* Vector 137 */
    .long   DefaultISR                       /* Vector 138 */
    .long   DefaultISR                       /* Vector 139 */
    .long   DefaultISR                       /* Vector 140 */
    .long   DefaultISR                       /* Vector 141 */
    .long   DefaultISR                       /* Vector 142 */
    .long   DefaultISR                       /* Vector 143 */
    .long   DefaultISR                       /* Vector 144 */
    .long   DefaultISR                       /* Vector 145 */
    .long   DefaultISR                       /* Vector 146 */
    .long   DefaultISR                       /* Vector 147 */
    .long   DefaultISR                       /* Vector 148 */
    .long   DefaultISR                       /* Vector 149 */
    .long   DefaultISR                       /* Vector 150 */
    .long   DefaultISR                       /* Vector 151 */
    .long   DefaultISR                       /* Vector 152 */
    .long   DefaultISR                       /* Vector 153 */
    .long   DefaultISR                       /* Vector 154 */
    .long   DefaultISR                       /* Vector 155 */
    .long   DefaultISR                       /* Vector 156 */
    .long   DefaultISR                       /* Vector 157 */
    .long   DefaultISR                       /* Vector 158 */
    .long   DefaultISR                       /* Vector 159 */
    .long   DefaultISR                       /* Vector 160 */
    .long   DefaultISR                       /* Vector 161 */
    .long   DefaultISR                       /* Vector 162 */
    .long   DefaultISR                       /* Vector 163 */
    .long   DefaultISR                       /* Vector 164 */
    .long   DefaultISR                       /* Vector 165 */
    .long   DefaultISR                       /* Vector 166 */
    .long   DefaultISR                       /* Vector 167 */
    .long   DefaultISR                       /* Vector 168 */
    .long   DefaultISR                       /* Vector 169 */
    .long   DefaultISR                       /* Vector 170 */
    .long   DefaultISR                       /* Vector 171 */
    .long   DefaultISR                       /* Vector 172 */
    .long   DefaultISR                       /* Vector 173 */
    .long   DefaultISR                       /* Vector 174 */
    .long   DefaultISR                       /* Vector 175 */
    .long   DefaultISR                       /* Vector 176 */
    .long   DefaultISR                       /* Vector 177 */
    .long   DefaultISR                       /* Vector 178 */
    .long   DefaultISR                       /* Vector 179 */
    .long   DefaultISR                       /* Vector 180 */
    .long   DefaultISR                       /* Vector 181 */
    .long   DefaultISR                       /* Vector 182 */
    .long   DefaultISR                       /* Vector 183 */
    .long   DefaultISR                       /* Vector 184 */
    .long   FMC_Done_IRQHandler              /* Vector 185 Flash controller Prog/Erase/Suspend IRQ_0 MCR[DONE] */
    .long   DefaultISR                       /* Vector 186 */
    .long   DefaultISR                       /* Vector 187 */
    .long   DefaultISR                       /* Vector 188 */
    .long   DefaultISR                       /* Vector 189 */
    .long   DefaultISR                       /* Vector 190 */
    .long   DefaultISR                       /* Vector 191 */
    .long   DefaultISR                       /* Vector 192 */
    .long   DefaultISR                       /* Vector 193 */
    .long   DefaultISR                       /* Vector 194 */
    .long   DefaultISR                       /* Vector 195 */
    .long   DefaultISR                       /* Vector 196 */
    .long   DefaultISR                       /* Vector 197 */
    .long   DefaultISR                       /* Vector 198 */
    .long   DefaultISR                       /* Vector 199 */
    .long   DefaultISR                       /* Vector 200 */
    .long   DefaultISR                       /* Vector 201 */
    .long   DefaultISR                       /* Vector 202 */
    .long   DefaultISR                       /* Vector 203 */
    .long   DefaultISR                       /* Vector 204 */
    .long   DefaultISR                       /* Vector 205 */
    .long   DefaultISR                       /* Vector 206 */
    .long   DefaultISR                       /* Vector 207 */
    .long   DefaultISR                       /* Vector 208 */
    .long   DefaultISR                       /* Vector 209 */
    .long   DefaultISR                       /* Vector 210 */
    .long   DefaultISR                       /* Vector 211 */
    .long   DefaultISR                       /* Vector 212 */
    .long   DefaultISR                       /* Vector 213 */
    .long   DefaultISR                       /* Vector 214 */
    .long   DefaultISR                       /* Vector 215 */
    .long   DefaultISR                       /* Vector 216 */
    .long   DefaultISR                       /* Vector 217 */
    .long   FEC_TXF_IRQHandler               /* Vector 218 Ethernet_0_0 EIR[TXF] */
    .long   FEC_RXF_IRQHandler               /* Vector 219 Ethernet_0_0 EIR[RXF] */
    .long   FEC_ERR_IRQHandler               /* Vector 220 Ethernet_0_0 EIR[ERRORS] */
    .long   DefaultISR                       /* Vector 221 */
    .long   DefaultISR                       /* Vector 222 */
    .long   DefaultISR                       /* Vector 223 */
    .long   DefaultISR                       /* Vector 224 */
    .long   DefaultISR                       /* Vector 225 */
    .long   PIT0_TFLG0_IRQHandler            /* Vector 226 Periodic Interrupt Timer (PIT0) PIT_0_TFLG[TIF] */
    .long   PIT0_TFLG1_IRQHandler            /* Vector 227 Periodic Interrupt Timer (PIT1) PIT_0_TFLG[TIF] */
    .long   PIT0_TFLG2_IRQHandler            /* Vector 228 Periodic Interrupt Timer (PIT2) PIT_0_TFLG[TIF] */
    .long   PIT0_TFLG3_IRQHandler            /* Vector 229 Periodic Interrupt Timer (PIT3) PIT_0_TFLG[TIF] */
    .long   PIT0_TFLG4_IRQHandler            /* Vector 230 Periodic Interrupt Timer (PIT4) PIT_0_TFLG[TIF] */
    .long   PIT0_TFLG5_IRQHandler            /* Vector 231 Periodic Interrupt Timer (PIT5) PIT_0_TFLG[TIF] */
    .long   PIT0_TFLG6_IRQHandler            /* Vector 232 Periodic Interrupt Timer (PIT6) PIT_0_TFLG[TIF] */
    .long   PIT0_TFLG7_IRQHandler            /* Vector 233 Periodic Interrupt Timer (PIT7) PIT_0_TFLG[TIF] */
    .long   DefaultISR                       /* Vector 234 */
    .long   DefaultISR                       /* Vector 235 */
    .long   DefaultISR                       /* Vector 236 */
    .long   DefaultISR                       /* Vector 237 */
    .long   DefaultISR                       /* Vector 238 */
    .long   PIT0_RTI_IRQHandler              /* Vector 239 PIT_RTI PIT_0_RTI_TFLG[TIF] */
    .long   PIT1_TFLG0_IRQHandler            /* Vector 240 PIT_64_Lower PIT_1_TFLG0[TIF] */
    .long   PIT1_TFLG1_IRQHandler            /* Vector 241 PIT_64_Upper PIT_1_TFLG1[TIF] */
    .long   XOSC_IRQHandler                  /* Vector 242 XOSC Counter */
    .long   SIU_0_IRQHandler                 /* Vector 243 SIU External Interrupt_0 */
    .long   SIU_1_IRQHandler                 /* Vector 244 SIU External Interrupt_1 */
    .long   DefaultISR                       /* Vector 245 */
    .long   DefaultISR                       /* Vector 246 */
    .long   DefaultISR                       /* Vector 247 */
    .long   DefaultISR                       /* Vector 248 */
    .long   DefaultISR                       /* Vector 249 */
    .long   DefaultISR                       /* Vector 250 */
    .long   MC_ME_SAFE_IRQHandler            /* Vector 251 ME_IS[I_SAFE] */
    .long   MC_ME_MTC_IRQHandler             /* Vector 252 ME_IS[I_MTC] */
    .long   MC_ME_IMODE_IRQHandler           /* Vector 253 ME_IS[I_IMODE] */
    .long   MC_ME_ICONF_IRQHandler           /* Vector 254 ME_IS[I_ICONF] */
    .long   MC_ME_RGM_IRQHandler             /* Vector 255 MC_RGM Functional and destructive reset alternate event interrupt */
    .long   DefaultISR                       /* Vector 256 */
    .long   DefaultISR                       /* Vector 257 */
    .long   DefaultISR                       /* Vector 258 */
    .long   DSPI0_FIFO_Error_IRQHandler      /* Vector 259 DSPI_0_SR[TFUF] | DSPI_0_SR[RFOF] | DSPI_0_SR[TFIWF] */
    .long   DSPI0_EOQF_IRQHandler            /* Vector 260 DSPI_0_SR[EOQF] */
    .long   DSPI0_Send_IRQHandler            /* Vector 261 DSPI_0_SR[TFFF] */
    .long   DSPI0_TCF_IRQHandler             /* Vector 262 DSPI_0_SR[TCF] */
    .long   DSPI0_Receive_IRQHandler         /* Vector 263 DSPI_0_SR[RFDF] */
    .long   DSPI0_CMDTCF_IRQHandler          /* Vector 264 DSPI_0_SR[CMD_TCF] */
    .long   DSPI0_CMDFFF_IRQHandler          /* Vector 265 DSPI_0_SR[CMDFFF] */
    .long   DSPI0_SPEF_IRQHandler            /* Vector 266 DSPI_0_SR[SPEF] */
    .long   DefaultISR                       /* Vector 267 */
    .long   DSPI1_FIFO_Error_IRQHandler      /* Vector 268 DSPI_1_SR[TFUF] | DSPI_1_SR[RFOF] | DSPI_1_SR[TFIWF] */
    .long   DSPI1_EOQF_IRQHandler            /* Vector 269 DSPI_1_SR[EOQF] */
    .long   DSPI1_Send_IRQHandler            /* Vector 270 DSPI_1_SR[TFFF] */
    .long   DSPI1_TCF_IRQHandler             /* Vector 271 DSPI_1_SR[TCF] */
    .long   DSPI1_Receive_IRQHandler         /* Vector 272 DSPI_1_SR[RFDF] */
    .long   DSPI1_CMDTCF_IRQHandler          /* Vector 273 DSPI_1_SR[CMD_TCF] */
    .long   DSPI1_CMDFFF_IRQHandler          /* Vector 274 DSPI_1_SR[CMDFFF] */
    .long   DSPI1_SPEF_IRQHandler            /* Vector 275 DSPI_1_SR[SPEF] */
    .long   DefaultISR                       /* Vector 276 */
    .long   DSPI2_FIFO_Error_IRQHandler      /* Vector 277 DSPI_2_SR[TFUF] | DSPI_2_SR[RFOF] | DSPI_2_SR[TFIWF] */
    .long   DSPI2_EOQF_IRQHandler            /* Vector 278 DSPI_2_SR[EOQF] */
    .long   DSPI2_Send_IRQHandler            /* Vector 279 DSPI_2_SR[TFFF] */
    .long   DSPI2_TCF_IRQHandler             /* Vector 280 DSPI_2_SR[TCF] */
    .long   DSPI2_Receive_IRQHandler         /* Vector 281 DSPI_2_SR[RFDF] */
    .long   DSPI2_CMDTCF_IRQHandler          /* Vector 282 DSPI_2_SR[CMD_TCF] */
    .long   DSPI2_CMDFFF_IRQHandler          /* Vector 283 DSPI_2_SR[CMDFFF] */
    .long   DSPI2_SPEF_IRQHandler            /* Vector 284 DSPI_2_SR[SPEF] */
    .long   DefaultISR                       /* Vector 285 */
    .long   DSPI3_FIFO_Error_IRQHandler      /* Vector 286 DSPI_3_SR[TFUF] | DSPI_3_SR[RFOF] | DSPI_3_SR[TFIWF] */
    .long   DSPI3_EOQF_IRQHandler            /* Vector 287 DSPI_3_SR[EOQF] */
    .long   DSPI3_Send_IRQHandler            /* Vector 288 DSPI_3_SR[TFFF] */
    .long   DSPI3_TCF_IRQHandler             /* Vector 289 DSPI_3_SR[TCF] */
    .long   DSPI3_Receive_IRQHandler         /* Vector 290 DSPI_3_SR[RFDF] */
    .long   DSPI3_CMDTCF_IRQHandler          /* Vector 291 DSPI_3_SR[CMD_TCF] */
    .long   DSPI3_CMDFFF_IRQHandler          /* Vector 292 DSPI_3_SR[CMDFFF] */
    .long   DSPI3_SPEF_IRQHandler            /* Vector 293 DSPI_3_SR[SPEF] */
    .long   DefaultISR                       /* Vector 294 */
    .long   DSPI4_FIFO_Error_IRQHandler      /* Vector 295 DSPI_4_SR[TFUF] | DSPI_4_SR[RFOF] | DSPI_4_SR[TFIWF] */
    .long   DSPI4_EOQF_IRQHandler            /* Vector 296 DSPI_4_SR[EOQF] */
    .long   DSPI4_Send_IRQHandler            /* Vector 297 DSPI_4_SR[TFFF] */
    .long   DSPI4_TCF_IRQHandler             /* Vector 298 DSPI_4_SR[TCF] */
    .long   DSPI4_Receive_IRQHandler         /* Vector 299 DSPI_4_SR[RFDF] */
    .long   DSPI4_CMDTCF_IRQHandler          /* Vector 300 DSPI_4_SR[CMD_TCF] */
    .long   DSPI4_CMDFFF_IRQHandler          /* Vector 301 DSPI_4_SR[CMDFFF] */
    .long   DSPI4_SPEF_IRQHandler            /* Vector 302 DSPI_4_SR[SPEF] */
    .long   DefaultISR                       /* Vector 303 */
    .long   DSPI5_FIFO_Error_IRQHandler      /* Vector 304 DSPI_M0_SR[TFUF] | DSPI_M0_SR[RFOF] | DSPI_M0_SR[TFIWF] */
    .long   DSPI_M0_EOQF_IRQHandler          /* Vector 305 DSPI_M0_SR[EOQF] */
    .long   DSPI5_Send_IRQHandler            /* Vector 306 DSPI_M0_SR[TFFF] */
    .long   DSPI_M0_TCF_IRQHandler           /* Vector 307 DSPI_M0_SR[TCF] */
    .long   DSPI5_Receive_IRQHandler         /* Vector 308 DSPI_M0_SR[RFDF] */
    .long   DSPI_M0_CMDTCF_IRQHandler        /* Vector 309 DSPI_M0_SR[CMD_TCF] */
    .long   DSPI_M0_CMDFFF_IRQHandler        /* Vector 310 DSPI_M0_SR[CMDFFF] */
    .long   DSPI_M0_SPEF_IRQHandler          /* Vector 311 DSPI_M0_SR[SPEF] | DSPI_M0_SR[DPEF] */
    .long   DSPI_M0_DDIF_IRQHandler          /* Vector 312 DSPI_M0_SR[DDIF] */
    .long   DSPI6_FIFO_Error_IRQHandler      /* Vector 313 DSPI_M1_SR[TFUF] | DSPI_M1_SR[RFOF] | DSPI_M1_SR[TFIWF] */
    .long   DSPI_M1_EOQF_IRQHandler          /* Vector 314 DSPI_M1_SR[EOQF] */
    .long   DSPI6_Send_IRQHandler            /* Vector 315 DSPI_M1_SR[TFFF] */
    .long   DSPI_M1_TCF_IRQHandler           /* Vector 316 DSPI_M1_SR[TCF] */
    .long   DSPI6_Receive_IRQHandler         /* Vector 317 DSPI_M1_SR[RFDF] */
    .long   DSPI_M1_CMDTCF_IRQHandler        /* Vector 318 DSPI_M1_SR[CMD_TCF] */
    .long   DSPI_M1_CMDFFF_IRQHandler        /* Vector 319 DSPI_M1_SR[CMDFFF] */
    .long   DSPI_M1_SPEF_IRQHandler          /* Vector 320 DSPI_M1_SR[SPEF] | DSPI_M1_SR[DPEF] */
    .long   DSPI_M1_DDIF_IRQHandler          /* Vector 321 DSPI_M1_SR[DDIF] */
    .long   DefaultISR                       /* Vector 322 */
    .long   DefaultISR                       /* Vector 323 */
    .long   DefaultISR                       /* Vector 324 */
    .long   DefaultISR                       /* Vector 325 */
    .long   DefaultISR                       /* Vector 326 */
    .long   DefaultISR                       /* Vector 327 */
    .long   DefaultISR                       /* Vector 328 */
    .long   DefaultISR                       /* Vector 329 */
    .long   DefaultISR                       /* Vector 330 */
    .long   DefaultISR                       /* Vector 331 */
    .long   DefaultISR                       /* Vector 332 */
    .long   DefaultISR                       /* Vector 333 */
    .long   DefaultISR                       /* Vector 334 */
    .long   DefaultISR                       /* Vector 335 */
    .long   DefaultISR                       /* Vector 336 */
    .long   DefaultISR                       /* Vector 337 */
    .long   DefaultISR                       /* Vector 338 */
    .long   DefaultISR                       /* Vector 339 */
    .long   DefaultISR                       /* Vector 340 */
    .long   DefaultISR                       /* Vector 341 */
    .long   DefaultISR                       /* Vector 342 */
    .long   DefaultISR                       /* Vector 343 */
    .long   DefaultISR                       /* Vector 344 */
    .long   DefaultISR                       /* Vector 345 */
    .long   DefaultISR                       /* Vector 346 */
    .long   DefaultISR                       /* Vector 347 */
    .long   DefaultISR                       /* Vector 348 */
    .long   DefaultISR                       /* Vector 349 */
    .long   DefaultISR                       /* Vector 350 */
    .long   DefaultISR                       /* Vector 351 */
    .long   DefaultISR                       /* Vector 352 */
    .long   DefaultISR                       /* Vector 353 */
    .long   DefaultISR                       /* Vector 354 */
    .long   DefaultISR                       /* Vector 355 */
    .long   DefaultISR                       /* Vector 356 */
    .long   DefaultISR                       /* Vector 357 */
    .long   DefaultISR                       /* Vector 358 */
    .long   DefaultISR                       /* Vector 359 */
    .long   DefaultISR                       /* Vector 360 */
    .long   DefaultISR                       /* Vector 361 */
    .long   DefaultISR                       /* Vector 362 */
    .long   DefaultISR                       /* Vector 363 */
    .long   DefaultISR                       /* Vector 364 */
    .long   DefaultISR                       /* Vector 365 */
    .long   DefaultISR                       /* Vector 366 */
    .long   DefaultISR                       /* Vector 367 */
    .long   DefaultISR                       /* Vector 368 */
    .long   DefaultISR                       /* Vector 369 */
    .long   DefaultISR                       /* Vector 370 */
    .long   DefaultISR                       /* Vector 371 */
    .long   DefaultISR                       /* Vector 372 */
    .long   DefaultISR                       /* Vector 373 */
    .long   DefaultISR                       /* Vector 374 */
    .long   DefaultISR                       /* Vector 375 */
    .long   LINFLEXD0_RX_IRQHandler          /* Vector 376 Linflex/eSCI0_0 LINFlex_0_RXI */
    .long   LINFLEXD0_TX_IRQHandler          /* Vector 377 Linflex/eSCI0_1 LINFlex_0_TXI */
    .long   LINFLEXD0_ERR_IRQHandler         /* Vector 378 Linflex/eSCI0_2 LINFlex_0_ERR */
    .long   DefaultISR                       /* Vector 379 */
    .long   LINFLEXD1_RX_IRQHandler          /* Vector 380 Linflex/eSCI1_0 LINFlex_1_RXI */
    .long   LINFLEXD1_TX_IRQHandler          /* Vector 381 Linflex/eSCI1_1 LINFlex_1_TXI */
    .long   LINFLEXD1_ERR_IRQHandler         /* Vector 382 Linflex/eSCI1_2 LINFlex_1_ERR */
    .long   DefaultISR                       /* Vector 383 */
    .long   LINFLEXD2_RX_IRQHandler          /* Vector 384 Linflex/eSCI2_0 LINFlex_2_RXI */
    .long   LINFLEXD2_TX_IRQHandler          /* Vector 385 Linflex/eSCI2_1 LINFlex_2_TXI */
    .long   LINFLEXD2_ERR_IRQHandler         /* Vector 386 Linflex/eSCI2_2 LINFlex_2_ERR */
    .long   DefaultISR                       /* Vector 387 */
    .long   LINFLEXD3_RX_IRQHandler          /* Vector 388 Linflex/eSCI3_0 LINFlex_3_RXI */
    .long   LINFLEXD3_TX_IRQHandler          /* Vector 389 Linflex/eSCI3_1 LINFlex_3_TXI */
    .long   LINFLEXD3_ERR_IRQHandler         /* Vector 390 Linflex/eSCI3_2 LINFlex_3_ERR */
    .long   DefaultISR                       /* Vector 391 */
    .long   LINFLEXD_M0_RX_IRQHandler        /* Vector 392 Linflex/eSCI_M0_0 LINFlex_M0_RXI */
    .long   LINFLEXD_M0_TX_IRQHandler        /* Vector 393 Linflex/eSCI_M0_1 LINFlex_M0_TXI */
    .long   LINFLEXD_M0_ERR_IRQHandler       /* Vector 394 Linflex/eSCI_M0_2 LINFlex_M0_ERR */
    .long   DefaultISR                       /* Vector 395 */
    .long   LINFLEXD_M1_RX_IRQHandler        /* Vector 396 Linflex/eSCI_M1_0 LINFlex_M1_RXI */
    .long   LINFLEXD_M1_TX_IRQHandler        /* Vector 397 Linflex/eSCI_M1_1 LINFlex_M1_TXI */
    .long   LINFLEXD_M1_ERR_IRQHandler       /* Vector 398 Linflex/eSCI_M1_2 LINFlex_M1_ERR */
    .long   DefaultISR                       /* Vector 399 */
    .long   DefaultISR                       /* Vector 400 */
    .long   DefaultISR                       /* Vector 401 */
    .long   DefaultISR                       /* Vector 402 */
    .long   DefaultISR                       /* Vector 403 */
    .long   DefaultISR                       /* Vector 404 */
    .long   DefaultISR                       /* Vector 405 */
    .long   DefaultISR                       /* Vector 406 */
    .long   DefaultISR                       /* Vector 407 */
    .long   DefaultISR                       /* Vector 408 */
    .long   DefaultISR                       /* Vector 409 */
    .long   DefaultISR                       /* Vector 410 */
    .long   DefaultISR                       /* Vector 411 */
    .long   DefaultISR                       /* Vector 412 */
    .long   DefaultISR                       /* Vector 413 */
    .long   DefaultISR                       /* Vector 414 */
    .long   DefaultISR                       /* Vector 415 */
    .long   DefaultISR                       /* Vector 416 */
    .long   DefaultISR                       /* Vector 417 */
    .long   DefaultISR                       /* Vector 418 */
    .long   DefaultISR                       /* Vector 419 */
    .long   DefaultISR                       /* Vector 420 */
    .long   DefaultISR                       /* Vector 421 */
    .long   DefaultISR                       /* Vector 422 */
    .long   DefaultISR                       /* Vector 423 */
    .long   DefaultISR                       /* Vector 424 */
    .long   DefaultISR                       /* Vector 425 */
    .long   DefaultISR                       /* Vector 426 */
    .long   DefaultISR                       /* Vector 427 */
    .long   DefaultISR                       /* Vector 428 */
    .long   DefaultISR                       /* Vector 429 */
    .long   DefaultISR                       /* Vector 430 */
    .long   DefaultISR                       /* Vector 431 */
    .long   DefaultISR                       /* Vector 432 */
    .long   DefaultISR                       /* Vector 433 */
    .long   DefaultISR                       /* Vector 434 */
    .long   DefaultISR                       /* Vector 435 */
    .long   DefaultISR                       /* Vector 436 */
    .long   DefaultISR                       /* Vector 437 */
    .long   DefaultISR                       /* Vector 438 */
    .long   DefaultISR                       /* Vector 439 */
    .long   DefaultISR                       /* Vector 440 */
    .long   DefaultISR                       /* Vector 441 */
    .long   DefaultISR                       /* Vector 442 */
    .long   DefaultISR                       /* Vector 443 */
    .long   DefaultISR                       /* Vector 444 */
    .long   DefaultISR                       /* Vector 445 */
    .long   DefaultISR                       /* Vector 446 */
    .long   DefaultISR                       /* Vector 447 */
    .long   DefaultISR                       /* Vector 448 */
    .long   DefaultISR                       /* Vector 449 */
    .long   DefaultISR                       /* Vector 450 */
    .long   DefaultISR                       /* Vector 451 */
    .long   DefaultISR                       /* Vector 452 */
    .long   DefaultISR                       /* Vector 453 */
    .long   DefaultISR                       /* Vector 454 */
    .long   DefaultISR                       /* Vector 455 */
    .long   DefaultISR                       /* Vector 456 */
    .long   DefaultISR                       /* Vector 457 */
    .long   DefaultISR                       /* Vector 458 */
    .long   DefaultISR                       /* Vector 459 */
    .long   DefaultISR                       /* Vector 460 */
    .long   DefaultISR                       /* Vector 461 */
    .long   DefaultISR                       /* Vector 462 */
    .long   DefaultISR                       /* Vector 463 */
    .long   DefaultISR                       /* Vector 464 */
    .long   DefaultISR                       /* Vector 465 */
    .long   DefaultISR                       /* Vector 466 */
    .long   DefaultISR                       /* Vector 467 */
    .long   DefaultISR                       /* Vector 468 */
    .long   DefaultISR                       /* Vector 469 */
    .long   DefaultISR                       /* Vector 470 */
    .long   DefaultISR                       /* Vector 471 */
    .long   DefaultISR                       /* Vector 472 */
    .long   DefaultISR                       /* Vector 473 */
    .long   DefaultISR                       /* Vector 474 */
    .long   DefaultISR                       /* Vector 475 */
    .long   DefaultISR                       /* Vector 476 */
    .long   PMU_IRQHandler                   /* Vector 477 Power Monitor Unit */
    .long   PMU_TSENSE_IRQHandler            /* Vector 478 Power management Unit (temp sensor) */
    .long   DefaultISR                       /* Vector 479 */
    .long   PLL_0_0_IRQHandler               /* Vector 480 PLL0SR[LOLF] */
    .long   DefaultISR                       /* Vector 481 */
    .long   PLL_1_0_IRQHandler               /* Vector 482 PLL1SR[LOLF] */
    .long   DefaultISR                       /* Vector 483 */
    .long   PLL_0_1_IRQHandler               /* Vector 484 PLL0SR[EXTPDF] */
    .long   PLL_1_1_IRQHandler               /* Vector 485 PLL1SR[EXTPDF] */
    .long   DefaultISR                       /* Vector 486 */
    .long   DefaultISR                       /* Vector 487 */
    .long   FCCU_ALARM_IRQHandler            /* Vector 488 FCCU_IRQ_STAT[ALRM_STAT] */
    .long   FCCU_MISC_IRQHandler             /* Vector 489 FCU_IRQ_STAT[CFG_TO_STAT] */
    .long   FCCU_RCCS0_IRQHandler            /* Vector 490 FCCU_SCFS[RCCS0] */
    .long   FCCU_RCCS1_IRQHandler            /* Vector 491 FCCU_SCFS[RCCS1] */
    .long   DefaultISR                       /* Vector 492 */
    .long   DefaultISR                       /* Vector 493 */
    .long   STCU2_0_IRQHandler               /* Vector 494 STCU_RUNSW[LBIE] */
    .long   STCU2_1_IRQHandler               /* Vector 495 STCU_RUNSW[MBIE] */
    .long   DefaultISR                       /* Vector 496 */
    .long   DefaultISR                       /* Vector 497 */
    .long   DefaultISR                       /* Vector 498 */
    .long   DefaultISR                       /* Vector 499 */
    .long   DefaultISR                       /* Vector 500 */
    .long   DefaultISR                       /* Vector 501 */
    .long   DefaultISR                       /* Vector 502 */
    .long   DefaultISR                       /* Vector 503 */
    .long   DefaultISR                       /* Vector 504 */
    .long   DefaultISR                       /* Vector 505 */
    .long   DefaultISR                       /* Vector 506 */
    .long   DefaultISR                       /* Vector 507 */
    .long   DefaultISR                       /* Vector 508 */
    .long   DefaultISR                       /* Vector 509 */
    .long   DefaultISR                       /* Vector 510 */
    .long   DefaultISR                       /* Vector 511 */
    .long   DefaultISR                       /* Vector 512 */
    .long   DefaultISR                       /* Vector 513 */
    .long   DefaultISR                       /* Vector 514 */
    .long   DefaultISR                       /* Vector 515 */
    .long   DefaultISR                       /* Vector 516 */
    .long   DefaultISR                       /* Vector 517 */
    .long   DefaultISR                       /* Vector 518 */
    .long   DefaultISR                       /* Vector 519 */
    .long   DefaultISR                       /* Vector 520 */
    .long   DefaultISR                       /* Vector 521 */
    .long   DefaultISR                       /* Vector 522 */
    .long   DefaultISR                       /* Vector 523 */
    .long   DefaultISR                       /* Vector 524 */
    .long   DefaultISR                       /* Vector 525 */
    .long   DefaultISR                       /* Vector 526 */
    .long   DefaultISR                       /* Vector 527 */
    .long   ADC0_EOC_IRQHandler              /* Vector 528 SAR_ADC_0_EOCTU | SAR_ADC_0_JECO | SAR_ADC_0_JECH | SAR_ADC_0_EOC | SAR_ADC_0_ECH */
    .long   ADC0_ER_IRQHandler               /* Vector 529 SAR_ADC_0_ER */
    .long   ADC0_WD_IRQHandler               /* Vector 530 SAR_ADC_0_WD */
    .long   DefaultISR                       /* Vector 531 */
    .long   ADC1_EOC_IRQHandler              /* Vector 532 SAR_ADC_1_EOCTU | SAR_ADC_1_JECO | SAR_ADC_1_JECH | SAR_ADC_1_EOC | SAR_ADC_1_ECH */
    .long   ADC1_ER_IRQHandler               /* Vector 533 SAR_ADC_1_ER */
    .long   ADC1_WD_IRQHandler               /* Vector 534 SAR_ADC_1_WD */
    .long   DefaultISR                       /* Vector 535 */
    .long   ADC2_EOC_IRQHandler              /* Vector 536 SAR_ADC_2_EOCTU | SAR_ADC_2_JECO | SAR_ADC_2_JECH | SAR_ADC_2_EOC | SAR_ADC_2_ECH */
    .long   ADC2_ER_IRQHandler               /* Vector 537 SAR_ADC_2_ER */
    .long   ADC2_WD_IRQHandler               /* Vector 538 SAR_ADC_2_WD */
    .long   DefaultISR                       /* Vector 540 */
    .long   ADC3_EOC_IRQHandler              /* Vector 540 SAR_ADC_3_EOCTU | SAR_ADC_3_JECO | SAR_ADC_3_JECH | SAR_ADC_3_EOC | SAR_ADC_3_ECH */
    .long   ADC3_ER_IRQHandler               /* Vector 541 SAR_ADC_3_ER */
    .long   ADC3_WD_IRQHandler               /* Vector 542 SAR_ADC_3_WD */
    .long   DefaultISR                       /* Vector 543 */
    .long   SDADC0_IRQHandler                /* Vector 544 SD_ADC0 */
    .long   SDADC1_IRQHandler                /* Vector 545 SD_ADC1 */
    .long   SDADC2_IRQHandler                /* Vector 546 SD_ADC2 */
    .long   DefaultISR                       /* Vector 547 */
    .long   DefaultISR                       /* Vector 548 */
    .long   DefaultISR                       /* Vector 549 */
    .long   DefaultISR                       /* Vector 550 */
    .long   DefaultISR                       /* Vector 551 */
    .long   DefaultISR                       /* Vector 552 */
    .long   DefaultISR                       /* Vector 553 */
    .long   DefaultISR                       /* Vector 554 */
    .long   DefaultISR                       /* Vector 555 */
    .long   DefaultISR                       /* Vector 556 */
    .long   DefaultISR                       /* Vector 557 */
    .long   SENT0_Fast_IRQHandler            /* Vector 558 SENT_0_FMSG_RDY[n] */
    .long   SENT0_Slow_IRQHandler            /* Vector 559 SENT_0_SMSG_RDY[n] */
    .long   SENT0_RxErr_IRQHandler           /* Vector 560 SENT_0_STATUS_RDY[n] */
    .long   SENT1_Fast_IRQHandler            /* Vector 561 SENT_1_FMSG_RDY[n] */
    .long   SENT1_Slow_IRQHandler            /* Vector 562 SENT_1_SMSG_RDY[n] */
    .long   SENT1_RxErr_IRQHandler           /* Vector 563 SENT_1_STATUS_RDY[n] */
    .long   SENT0_Fast_0_IRQHandler          /* Vector 564 SENT_0_FMSG_RDY[0] */
    .long   SENT0_Slow_0_IRQHandler          /* Vector 565 SENT_0_SMSG_RDY[0] */
    .long   SENT0_RxErr_0_IRQHandler         /* Vector 566 SENT_0_CH0_STATUS[4:7|9:15] */
    .long   SENT0_Fast_1_IRQHandler          /* Vector 567 SENT_0_FMSG_RDY[1] */
    .long   SENT0_Slow_1_IRQHandler          /* Vector 568 SENT_0_SMSG_RDY[1] */
    .long   SENT0_RxErr_1_IRQHandler         /* Vector 569 SENT_0_CH1_STATUS[4:7|9:15] */
    .long   SENT0_Fast_2_IRQHandler          /* Vector 570 SENT_0_FMSG_RDY[2] */
    .long   SENT0_Slow_2_IRQHandler          /* Vector 571 SENT_0_SMSG_RDY[2] */
    .long   SENT0_RxErr_2_IRQHandler         /* Vector 572 SENT_0_CH2_STATUS[4:7|9:15] */
    .long   DefaultISR                       /* Vector 573 */
    .long   DefaultISR                       /* Vector 574 */
    .long   DefaultISR                       /* Vector 575 */
    .long   DefaultISR                       /* Vector 576 */
    .long   DefaultISR                       /* Vector 577 */
    .long   DefaultISR                       /* Vector 578 */
    .long   SENT1_Fast_0_IRQHandler          /* Vector 579 SENT_1_FMSG_RDY[0] */
    .long   SENT1_Slow_0_IRQHandler          /* Vector 580 SENT_1_SMSG_RDY[0] */
    .long   SENT1_RxErr_0_IRQHandler         /* Vector 581 SENT_1_CH0_STATUS[4:7|9:15] */
    .long   SENT1_Fast_1_IRQHandler          /* Vector 582 SENT_1_FMSG_RDY[1] */
    .long   SENT1_Slow_1_IRQHandler          /* Vector 583 SENT_1_SMSG_RDY[1] */
    .long   SENT1_RxErr_1_IRQHandler         /* Vector 584 SENT_1_CH1_STATUS[4:7|9:15] */
    .long   SENT1_Fast_2_IRQHandler          /* Vector 585 SENT_1_FMSG_RDY[2] */
    .long   SENT1_Slow_2_IRQHandler          /* Vector 586 SENT_1_SMSG_RDY[2] */
    .long   SENT1_RxErr_2_IRQHandler         /* Vector 587 SENT_1_CH2_STATUS[4:7|9:15] */
    .long   DefaultISR                       /* Vector 588 */
    .long   DefaultISR                       /* Vector 589 */
    .long   DefaultISR                       /* Vector 590 */
    .long   DefaultISR                       /* Vector 591 */
    .long   DefaultISR                       /* Vector 592 */
    .long   DefaultISR                       /* Vector 593 */
    .long   DefaultISR                       /* Vector 594 */
    .long   DefaultISR                       /* Vector 595 */
    .long   DefaultISR                       /* Vector 596 */
    .long   DefaultISR                       /* Vector 597 */
    .long   DefaultISR                       /* Vector 598 */
    .long   DefaultISR                       /* Vector 599 */
    .long   DefaultISR                       /* Vector 600 */
    .long   DefaultISR                       /* Vector 601 */
    .long   DefaultISR                       /* Vector 602 */
    .long   DefaultISR                       /* Vector 603 */
    .long   DefaultISR                       /* Vector 604 */
    .long   DefaultISR                       /* Vector 605 */
    .long   DefaultISR                       /* Vector 606 */
    .long   DefaultISR                       /* Vector 607 */
    .long   DefaultISR                       /* Vector 608 */
    .long   DefaultISR                       /* Vector 609 */
    .long   DefaultISR                       /* Vector 610 */
    .long   DefaultISR                       /* Vector 611 */
    .long   DefaultISR                       /* Vector 612 */
    .long   DefaultISR                       /* Vector 613 */
    .long   DefaultISR                       /* Vector 614 */
    .long   DefaultISR                       /* Vector 615 */
    .long   DefaultISR                       /* Vector 616 */
    .long   DefaultISR                       /* Vector 617 */
    .long   DefaultISR                       /* Vector 618 */
    .long   DefaultISR                       /* Vector 619 */
    .long   DefaultISR                       /* Vector 620 */
    .long   DefaultISR                       /* Vector 621 */
    .long   DefaultISR                       /* Vector 622 */
    .long   DefaultISR                       /* Vector 623 */
    .long   DefaultISR                       /* Vector 624 */
    .long   DefaultISR                       /* Vector 625 */
    .long   DefaultISR                       /* Vector 626 */
    .long   DefaultISR                       /* Vector 627 */
    .long   DefaultISR                       /* Vector 628 */
    .long   DefaultISR                       /* Vector 629 */
    .long   DefaultISR                       /* Vector 630 */
    .long   DefaultISR                       /* Vector 631 */
    .long   DefaultISR                       /* Vector 632 */
    .long   DefaultISR                       /* Vector 633 */
    .long   DefaultISR                       /* Vector 634 */
    .long   DefaultISR                       /* Vector 635 */
    .long   DefaultISR                       /* Vector 636 */
    .long   DefaultISR                       /* Vector 637 */
    .long   DefaultISR                       /* Vector 638 */
    .long   DefaultISR                       /* Vector 639 */
    .long   DefaultISR                       /* Vector 640 */
    .long   DefaultISR                       /* Vector 641 */
    .long   DefaultISR                       /* Vector 642 */
    .long   DefaultISR                       /* Vector 643 */
    .long   DefaultISR                       /* Vector 644 */
    .long   DefaultISR                       /* Vector 645 */
    .long   DefaultISR                       /* Vector 646 */
    .long   DefaultISR                       /* Vector 647 */
    .long   DefaultISR                       /* Vector 648 */
    .long   DefaultISR                       /* Vector 649 */
    .long   DefaultISR                       /* Vector 650 */
    .long   DefaultISR                       /* Vector 651 */
    .long   DefaultISR                       /* Vector 652 */
    .long   DefaultISR                       /* Vector 653 */
    .long   SIPI0_ErrorIrqHandler                      /* Vector 654 SIPI_ERR[TOEn|TIDEn|ACKEn] */
    .long   SIPI0_CrcErrorIrqHandler                   /* Vector 655 SIPI_SR[GCRCE] */
    .long   SIPI0_Ch0ResponseOrAckIrqHandler           /* Vector 656 SIPI_CSR0[RAR|ACKR] */
    .long   SIPI0_Ch1ResponseOrAckIrqHandler           /* Vector 657 SIPI_CSR1[RAR|ACKR] */
    .long   SIPI0_Ch2ResponseOrAckIrqHandler           /* Vector 658 SIPI_CSR2[RAR|ACKR] */
    .long   SIPI0_Ch3ResponseOrAckIrqHandler           /* Vector 659 SIPI_CSR3[RAR|ACKR] */
    .long   SIPI0_TriggerOrMaxCountReachedIrqHandler   /* Vector 660 SIPI_SR[TE0|TE1|TE2|TE3|MCR] */
    .long   LFAST0_0_IRQHandler              /* Vector 661 LFAST_0_TISR[TXPNGF|TXUNSF|TXICLCF|TXDTF] */
    .long   LFAST0_1_IRQHandler              /* Vector 662 LFAST_0_TISR[TXIEF|TXOVF] */
    .long   LFAST0_2_IRQHandler              /* Vector 663 LFAST_0_RISR[RXCTSF|RXDF|RXUNSF] */
    .long   LFAST0_3_IRQHandler              /* Vector 664 LFAST_0_RISR[RXUOF|RXMNF|RXMXF|RXUFF|RXOFF|RXSZF|RXICF|RXLCEF] */
    .long   LFAST0_4_IRQHandler              /* Vector 665 LFAST_0_RIISR[ICPFF|ICPSF|ICPRF|ICTOF|ICLPF|ICCTF|ICTDF|ICTEF|ICRFF|ICRSF|ICRSF|ICTFF|ICTSF|ICPOFF|ICPONF] */
    .long   DefaultISR                       /* Vector 666 */
    .long   DefaultISR                       /* Vector 667 */
    .long   DefaultISR                       /* Vector 668 */
    .long   DefaultISR                       /* Vector 669 */
    .long   DefaultISR                       /* Vector 670 */
    .long   DefaultISR                       /* Vector 671 */
    .long   DefaultISR                       /* Vector 672 */
    .long   DefaultISR                       /* Vector 673 */
    .long   JTAGM_IRQHandler                 /* Vector 674 JTAGM_SR[SPU_INT|IDLE] */
    .long   JDC_IRQHandler                   /* Vector 675 JDC_MSR[JIN_INT|JOUT_INT] */
    .long   DefaultISR                       /* Vector 676 */
    .long   CAN0_0_IRQHandler                /* Vector 677 CAN0_ESR1[BOFFINT|BOFFDONEINT] */
    .long   CAN0_1_IRQHandler                /* Vector 678 CAN0_ESR1[ERRINT|ERRINT_FAST] */
    .long   CAN0_5_IRQHandler                /* Vector 679 CAN0_IFLAG1[BUF15:BUF0] */
    .long   CAN0_2_IRQHandler                /* Vector 680 CAN0_IFLAG1[BUF31:BUF16] */
    .long   CAN0_3_IRQHandler                /* Vector 681 CAN0_IFLAG2[BUF63:BUF32] */
    .long   CAN0_4_IRQHandler                /* Vector 682 CAN0_IFLAG3[BUF95:BUF64] */
    .long   CAN1_0_IRQHandler                /* Vector 683 CAN1_ESR1[BOFFINT|BOFFDONEINT] */
    .long   CAN1_1_IRQHandler                /* Vector 684 CAN1_ESR1[ERRINT|ERRINT_FAST] */
    .long   CAN1_5_IRQHandler                /* Vector 685 CAN1_IFLAG1[BUF15:BUF0] */
    .long   CAN1_2_IRQHandler                /* Vector 686 CAN1_IFLAG1[BUF31:BUF16] */
    .long   CAN1_3_IRQHandler                /* Vector 687 CAN1_IFLAG2[BUF63:BUF32] */
    .long   CAN1_4_IRQHandler                /* Vector 688 CAN1_IFLAG3[BUF95:BUF64] */
    .long   CAN2_0_IRQHandler                /* Vector 689 CAN2_ESR1[BOFFINT|BOFFDONEINT] */
    .long   CAN2_1_IRQHandler                /* Vector 690 CAN2_ESR1[ERRINT|ERRINT_FAST] */
    .long   CAN2_5_IRQHandler                /* Vector 691 CAN2_IFLAG1[BUF7:BUF0] */
    .long   CAN2_2_IRQHandler                /* Vector 692 CAN2_IFLAG1[BUF15:BUF8] */
    .long   CAN2_3_IRQHandler                /* Vector 693 CAN2_IFLAG2[BUF31:BUF16] */
    .long   CAN2_4_IRQHandler                /* Vector 694 CAN2_IFLAG3[BUF63:BUF32] */
    .long   CAN3_0_IRQHandler                /* Vector 695 CAN3_ESR1[BOFFINT|BOFFDONEINT] */
    .long   CAN3_1_IRQHandler                /* Vector 696 CAN3_ESR1[ERRINT|ERRINT_FAST] */
    .long   CAN3_5_IRQHandler                /* Vector 697 CAN3_IFLAG1[BUF7:BUF0] */
    .long   CAN3_2_IRQHandler                /* Vector 698 CAN3_IFLAG1[BUF15:BUF8] */
    .long   CAN3_3_IRQHandler                /* Vector 699 CAN3_IFLAG2[BUF31:BUF16] */
    .long   CAN3_4_IRQHandler                /* Vector 700 CAN3_IFLAG3[BUF63:BUF32] */
    .long   DefaultISR                       /* Vector 701 */
    .long   DefaultISR                       /* Vector 702 */
    .long   DefaultISR                       /* Vector 703 */
    .long   DefaultISR                       /* Vector 704 */
    .long   DefaultISR                       /* Vector 705 */
    .long   EMIOS0_8_IRQHandler              /* Vector 706 EMIOS_0_GFR[F8] */
    .long   EMIOS0_9_IRQHandler              /* Vector 707 EMIOS_0_GFR[F9] */
    .long   EMIOS0_10_IRQHandler             /* Vector 708 EMIOS_0_GFR[F10] */
    .long   EMIOS0_11_IRQHandler             /* Vector 709 EMIOS_0_GFR[F11] */
    .long   EMIOS0_12_IRQHandler             /* Vector 710 EMIOS_0_GFR[F12] */
    .long   EMIOS0_13_IRQHandler             /* Vector 711 EMIOS_0_GFR[F13] */
    .long   EMIOS0_14_IRQHandler             /* Vector 712 EMIOS_0_GFR[F14] */
    .long   EMIOS0_15_IRQHandler             /* Vector 713 EMIOS_0_GFR[F15] */
    .long   EMIOS0_16_IRQHandler             /* Vector 714 EMIOS_0_GFR[F16] */
    .long   EMIOS0_17_IRQHandler             /* Vector 715 EMIOS_0_GFR[F17] */
    .long   EMIOS0_18_IRQHandler             /* Vector 716 EMIOS_0_GFR[F18] */
    .long   EMIOS0_19_IRQHandler             /* Vector 717 EMIOS_0_GFR[F19] */
    .long   EMIOS0_20_IRQHandler             /* Vector 718 EMIOS_0_GFR[F20] */
    .long   EMIOS0_21_IRQHandler             /* Vector 719 EMIOS_0_GFR[F21] */
    .long   EMIOS0_22_IRQHandler             /* Vector 720 EMIOS_0_GFR[F22] */
    .long   EMIOS0_23_IRQHandler             /* Vector 721 EMIOS_0_GFR[F23] */
    .long   EMIOS1_8_IRQHandler              /* Vector 722 EMIOS_1_GFR[F8] */
    .long   EMIOS1_9_IRQHandler              /* Vector 723 EMIOS_1_GFR[F9] */
    .long   EMIOS1_10_IRQHandler             /* Vector 724 EMIOS_1_GFR[F10] */
    .long   EMIOS1_11_IRQHandler             /* Vector 725 EMIOS_1_GFR[F11] */
    .long   EMIOS1_12_IRQHandler             /* Vector 726 EMIOS_1_GFR[F12] */
    .long   EMIOS1_13_IRQHandler             /* Vector 727 EMIOS_1_GFR[F13] */
    .long   EMIOS1_14_IRQHandler             /* Vector 728 EMIOS_1_GFR[F14] */
    .long   EMIOS1_15_IRQHandler             /* Vector 729 EMIOS_1_GFR[F15] */
    .long   EMIOS1_16_IRQHandler             /* Vector 730 EMIOS_1_GFR[F16] */
    .long   EMIOS1_17_IRQHandler             /* Vector 731 EMIOS_1_GFR[F17] */
    .long   EMIOS1_18_IRQHandler             /* Vector 732 EMIOS_1_GFR[F18] */
    .long   EMIOS1_19_IRQHandler             /* Vector 733 EMIOS_1_GFR[F19] */
    .long   EMIOS1_20_IRQHandler             /* Vector 734 EMIOS_1_GFR[F20] */
    .long   EMIOS1_21_IRQHandler             /* Vector 735 EMIOS_1_GFR[F21] */
    .long   EMIOS1_22_IRQHandler             /* Vector 736 EMIOS_1_GFR[F22] */
    .long   EMIOS1_23_IRQHandler             /* Vector 737 EMIOS_1_GFR[F23] */
    .long   ETPU_GE_IRQHandler               /* Vector 738 eTPU Engine 0 and 1 Global Exception: ETPU_MCRAB[MGEA,MGEB,ILFA,ILFB,SCM,MISF] */
    .long   ETPU0_CIS0_IRQHandler            /* Vector 739 eTPU Engine 0 Channel 0: ETPU_CISR_0[CIS0] */
    .long   ETPU0_CIS1_IRQHandler            /* Vector 740 eTPU Engine 0 Channel 1: ETPU_CISR_0[CIS1] */
    .long   ETPU0_CIS2_IRQHandler            /* Vector 741 eTPU Engine 0 Channel 2: ETPU_CISR_0[CIS2] */
    .long   ETPU0_CIS3_IRQHandler            /* Vector 742 eTPU Engine 0 Channel 3: ETPU_CISR_0[CIS3] */
    .long   ETPU0_CIS4_IRQHandler            /* Vector 743 eTPU Engine 0 Channel 4: ETPU_CISR_0[CIS4] */
    .long   ETPU0_CIS5_IRQHandler            /* Vector 744 eTPU Engine 0 Channel 5: ETPU_CISR_0[CIS5] */
    .long   ETPU0_CIS6_IRQHandler            /* Vector 745 eTPU Engine 0 Channel 6: ETPU_CISR_0[CIS6] */
    .long   ETPU0_CIS7_IRQHandler            /* Vector 746 eTPU Engine 0 Channel 7: ETPU_CISR_0[CIS7] */
    .long   ETPU0_CIS8_IRQHandler            /* Vector 747 eTPU Engine 0 Channel 8: ETPU_CISR_0[CIS8] */
    .long   ETPU0_CIS9_IRQHandler            /* Vector 748 eTPU Engine 0 Channel 9: ETPU_CISR_0[CIS9] */
    .long   ETPU0_CIS10_IRQHandler           /* Vector 749 eTPU Engine 0 Channel 10: ETPU_CISR_0[CIS10] */
    .long   ETPU0_CIS11_IRQHandler           /* Vector 750 eTPU Engine 0 Channel 11: ETPU_CISR_0[CIS11] */
    .long   ETPU0_CIS12_IRQHandler           /* Vector 751 eTPU Engine 0 Channel 12: ETPU_CISR_0[CIS12] */
    .long   ETPU0_CIS13_IRQHandler           /* Vector 752 eTPU Engine 0 Channel 13: ETPU_CISR_0[CIS13] */
    .long   ETPU0_CIS14_IRQHandler           /* Vector 753 eTPU Engine 0 Channel 14: ETPU_CISR_0[CIS14] */
    .long   ETPU0_CIS15_IRQHandler           /* Vector 754 eTPU Engine 0 Channel 15: ETPU_CISR_0[CIS15] */
    .long   ETPU0_CIS16_IRQHandler           /* Vector 755 eTPU Engine 0 Channel 16: ETPU_CISR_0[CIS16] */
    .long   ETPU0_CIS17_IRQHandler           /* Vector 756 eTPU Engine 0 Channel 17: ETPU_CISR_0[CIS17] */
    .long   ETPU0_CIS18_IRQHandler           /* Vector 757 eTPU Engine 0 Channel 18: ETPU_CISR_0[CIS18] */
    .long   ETPU0_CIS19_IRQHandler           /* Vector 758 eTPU Engine 0 Channel 19: ETPU_CISR_0[CIS19] */
    .long   ETPU0_CIS20_IRQHandler           /* Vector 759 eTPU Engine 0 Channel 20: ETPU_CISR_0[CIS20] */
    .long   ETPU0_CIS21_IRQHandler           /* Vector 760 eTPU Engine 0 Channel 21: ETPU_CISR_0[CIS21] */
    .long   ETPU0_CIS22_IRQHandler           /* Vector 761 eTPU Engine 0 Channel 22: ETPU_CISR_0[CIS22] */
    .long   ETPU0_CIS23_IRQHandler           /* Vector 762 eTPU Engine 0 Channel 23: ETPU_CISR_0[CIS23] */
    .long   ETPU0_CIS24_IRQHandler           /* Vector 763 eTPU Engine 0 Channel 24: ETPU_CISR_0[CIS24] */
    .long   ETPU0_CIS25_IRQHandler           /* Vector 764 eTPU Engine 0 Channel 25: ETPU_CISR_0[CIS25] */
    .long   ETPU0_CIS26_IRQHandler           /* Vector 765 eTPU Engine 0 Channel 26: ETPU_CISR_0[CIS26] */
    .long   ETPU0_CIS27_IRQHandler           /* Vector 766 eTPU Engine 0 Channel 27: ETPU_CISR_0[CIS27] */
    .long   ETPU0_CIS28_IRQHandler           /* Vector 767 eTPU Engine 0 Channel 28: ETPU_CISR_0[CIS28] */
    .long   ETPU0_CIS29_IRQHandler           /* Vector 768 eTPU Engine 0 Channel 29: ETPU_CISR_0[CIS29] */
    .long   ETPU0_CIS30_IRQHandler           /* Vector 769 eTPU Engine 0 Channel 30: ETPU_CISR_0[CIS30] */
    .long   ETPU0_CIS31_IRQHandler           /* Vector 770 eTPU Engine 0 Channel 31: ETPU_CISR_0[CIS31] */
    .long   ETPU1_CIS0_IRQHandler            /* Vector 771 eTPU Engine 1 Channel 0: ETPU_CISR_1[CIS0] */
    .long   ETPU1_CIS1_IRQHandler            /* Vector 772 eTPU Engine 1 Channel 1: ETPU_CISR_1[CIS1] */
    .long   ETPU1_CIS2_IRQHandler            /* Vector 773 eTPU Engine 1 Channel 2: ETPU_CISR_1[CIS2] */
    .long   ETPU1_CIS3_IRQHandler            /* Vector 774 eTPU Engine 1 Channel 3: ETPU_CISR_1[CIS3] */
    .long   ETPU1_CIS4_IRQHandler            /* Vector 775 eTPU Engine 1 Channel 4: ETPU_CISR_1[CIS4] */
    .long   ETPU1_CIS5_IRQHandler            /* Vector 776 eTPU Engine 1 Channel 5: ETPU_CISR_1[CIS5] */
    .long   ETPU1_CIS6_IRQHandler            /* Vector 777 eTPU Engine 1 Channel 6: ETPU_CISR_1[CIS6] */
    .long   ETPU1_CIS7_IRQHandler            /* Vector 778 eTPU Engine 1 Channel 7: ETPU_CISR_1[CIS7] */
    .long   ETPU1_CIS8_IRQHandler            /* Vector 779 eTPU Engine 1 Channel 8: ETPU_CISR_1[CIS8] */
    .long   ETPU1_CIS9_IRQHandler            /* Vector 780 eTPU Engine 1 Channel 9: ETPU_CISR_1[CIS9] */
    .long   ETPU1_CIS10_IRQHandler           /* Vector 781 eTPU Engine 1 Channel 10: ETPU_CISR_1[CIS10] */
    .long   ETPU1_CIS11_IRQHandler           /* Vector 782 eTPU Engine 1 Channel 11: ETPU_CISR_1[CIS11] */
    .long   ETPU1_CIS12_IRQHandler           /* Vector 783 eTPU Engine 1 Channel 12: ETPU_CISR_1[CIS12] */
    .long   ETPU1_CIS13_IRQHandler           /* Vector 784 eTPU Engine 1 Channel 13: ETPU_CISR_1[CIS13] */
    .long   ETPU1_CIS14_IRQHandler           /* Vector 785 eTPU Engine 1 Channel 14: ETPU_CISR_1[CIS14] */
    .long   ETPU1_CIS15_IRQHandler           /* Vector 786 eTPU Engine 1 Channel 15: ETPU_CISR_1[CIS15] */
    .long   ETPU1_CIS16_IRQHandler           /* Vector 787 eTPU Engine 1 Channel 16: ETPU_CISR_1[CIS16] */
    .long   ETPU1_CIS17_IRQHandler           /* Vector 788 eTPU Engine 1 Channel 17: ETPU_CISR_1[CIS17] */
    .long   ETPU1_CIS18_IRQHandler           /* Vector 789 eTPU Engine 1 Channel 18: ETPU_CISR_1[CIS18] */
    .long   ETPU1_CIS19_IRQHandler           /* Vector 790 eTPU Engine 1 Channel 19: ETPU_CISR_1[CIS19] */
    .long   ETPU1_CIS20_IRQHandler           /* Vector 791 eTPU Engine 1 Channel 20: ETPU_CISR_1[CIS20] */
    .long   ETPU1_CIS21_IRQHandler           /* Vector 792 eTPU Engine 1 Channel 21: ETPU_CISR_1[CIS21] */
    .long   ETPU1_CIS22_IRQHandler           /* Vector 793 eTPU Engine 1 Channel 22: ETPU_CISR_1[CIS22] */
    .long   ETPU1_CIS23_IRQHandler           /* Vector 794 eTPU Engine 1 Channel 23: ETPU_CISR_1[CIS23] */
    .long   ETPU1_CIS24_IRQHandler           /* Vector 795 eTPU Engine 1 Channel 24: ETPU_CISR_1[CIS24] */
    .long   ETPU1_CIS25_IRQHandler           /* Vector 796 eTPU Engine 1 Channel 25: ETPU_CISR_1[CIS25] */
    .long   ETPU1_CIS26_IRQHandler           /* Vector 797 eTPU Engine 1 Channel 26: ETPU_CISR_1[CIS26] */
    .long   ETPU1_CIS27_IRQHandler           /* Vector 798 eTPU Engine 1 Channel 27: ETPU_CISR_1[CIS27] */
    .long   ETPU1_CIS28_IRQHandler           /* Vector 799 eTPU Engine 1 Channel 28: ETPU_CISR_1[CIS28] */
    .long   ETPU1_CIS29_IRQHandler           /* Vector 800 eTPU Engine 1 Channel 29: ETPU_CISR_1[CIS29] */
    .long   ETPU1_CIS30_IRQHandler           /* Vector 801 eTPU Engine 1 Channel 30: ETPU_CISR_1[CIS30] */
    .long   ETPU1_CIS31_IRQHandler           /* Vector 802 eTPU Engine 1 Channel 31: ETPU_CISR_1[CIS31] */
    .long   DefaultISR                       /* Vector 803 */
    .long   DefaultISR                       /* Vector 804 */
    .long   DefaultISR                       /* Vector 805 */
    .long   DefaultISR                       /* Vector 806 */
    .long   DefaultISR                       /* Vector 807 */
    .long   DefaultISR                       /* Vector 808 */
    .long   DefaultISR                       /* Vector 809 */
    .long   DefaultISR                       /* Vector 810 */
    .long   DefaultISR                       /* Vector 811 */
    .long   DefaultISR                       /* Vector 812 */
    .long   DefaultISR                       /* Vector 813 */
    .long   DefaultISR                       /* Vector 814 */
    .long   DefaultISR                       /* Vector 815 */
    .long   DefaultISR                       /* Vector 816 */
    .long   DefaultISR                       /* Vector 817 */
    .long   DefaultISR                       /* Vector 818 */
    .long   DefaultISR                       /* Vector 819 */
    .long   DefaultISR                       /* Vector 820 */
    .long   DefaultISR                       /* Vector 821 */
    .long   DefaultISR                       /* Vector 822 */
    .long   DefaultISR                       /* Vector 823 */
    .long   DefaultISR                       /* Vector 824 */
    .long   DefaultISR                       /* Vector 825 */
    .long   DefaultISR                       /* Vector 826 */
    .long   DefaultISR                       /* Vector 827 */
    .long   DefaultISR                       /* Vector 828 */
    .long   DefaultISR                       /* Vector 829 */
    .long   DefaultISR                       /* Vector 830 */
    .long   DefaultISR                       /* Vector 831 */
    .long   DefaultISR                       /* Vector 832 */
    .long   DefaultISR                       /* Vector 833 */
    .long   DefaultISR                       /* Vector 834 */
    .long   DefaultISR                       /* Vector 835 */
    .long   DefaultISR                       /* Vector 836 */
    .long   DefaultISR                       /* Vector 837 */
    .long   DefaultISR                       /* Vector 838 */
    .long   DefaultISR                       /* Vector 839 */
    .long   DefaultISR                       /* Vector 840 */
    .long   DefaultISR                       /* Vector 841 */
    .long   DefaultISR                       /* Vector 842 */
    .long   DefaultISR                       /* Vector 843 */
    .long   DefaultISR                       /* Vector 844 */
    .long   DefaultISR                       /* Vector 845 */
    .long   DefaultISR                       /* Vector 846 */
    .long   DefaultISR                       /* Vector 847 */
    .long   DefaultISR                       /* Vector 848 */
    .long   DefaultISR                       /* Vector 849 */
    .long   DefaultISR                       /* Vector 850 */
    .long   DefaultISR                       /* Vector 851 */
    .long   DefaultISR                       /* Vector 852 */
    .long   DefaultISR                       /* Vector 853 */
    .long   DefaultISR                       /* Vector 854 */
    .long   DefaultISR                       /* Vector 855 */
    .long   DefaultISR                       /* Vector 856 */
    .long   DefaultISR                       /* Vector 857 */
    .long   DefaultISR                       /* Vector 858 */
    .long   DefaultISR                       /* Vector 859 */
    .long   DefaultISR                       /* Vector 860 */
    .long   DefaultISR                       /* Vector 861 */
    .long   DefaultISR                       /* Vector 862 */
    .long   DefaultISR                       /* Vector 863 */
    .long   DefaultISR                       /* Vector 864 */
    .long   DefaultISR                       /* Vector 865 */
    .long   DefaultISR                       /* Vector 866 */
    .long   DefaultISR                       /* Vector 867 */
    .long   DefaultISR                       /* Vector 868 */
    .long   DefaultISR                       /* Vector 869 */
    .long   DefaultISR                       /* Vector 870 */
    .long   DefaultISR                       /* Vector 871 */
    .long   DefaultISR                       /* Vector 872 */
    .long   DefaultISR                       /* Vector 873 */
    .long   DefaultISR                       /* Vector 874 */
    .long   DefaultISR                       /* Vector 875 */
    .long   DefaultISR                       /* Vector 876 */
    .long   DefaultISR                       /* Vector 877 */
    .long   DefaultISR                       /* Vector 878 */
    .long   DefaultISR                       /* Vector 879 */
    .long   DefaultISR                       /* Vector 880 */
    .long   DefaultISR                       /* Vector 881 */
    .long   DefaultISR                       /* Vector 882 */
    .long   DefaultISR                       /* Vector 883 */
    .long   DefaultISR                       /* Vector 884 */
    .long   DefaultISR                       /* Vector 885 */
    .long   DefaultISR                       /* Vector 886 */
    .long   DefaultISR                       /* Vector 887 */
    .long   DefaultISR                       /* Vector 888 */
    .long   DefaultISR                       /* Vector 889 */
    .long   DefaultISR                       /* Vector 890 */
    .long   DefaultISR                       /* Vector 891 */
    .long   DefaultISR                       /* Vector 892 */
    .long   DefaultISR                       /* Vector 893 */
    .long   DefaultISR                       /* Vector 894 */
    .long   DefaultISR                       /* Vector 895 */
    .long   DefaultISR                       /* Vector 896 */
    .long   DefaultISR                       /* Vector 897 */
    .long   DefaultISR                       /* Vector 898 */
    .long   DefaultISR                       /* Vector 899 */
    .long   BCTU0_TRI_IRQHandler             /* Vector 900 BCTU_0_TRIG */
    .long   BCTU0_ADC0_IRQHandler            /* Vector 901 BCTU_0_ADC0 */
    .long   BCTU0_ADC1_IRQHandler            /* Vector 902 BCTU_0_ADC1 */
    .long   BCTU0_ADC2_IRQHandler            /* Vector 903 BCTU_0_ADC2 */
    .long   BCTU0_ADC3_IRQHandler            /* Vector 904 BCTU_0_ADC3 */
    .long   BCTU0_LIST_IRQHandler            /* Vector 905 BCTU_0_LIST */
    .long   DefaultISR                       /* Vector 906 */
    .long   DefaultISR                       /* Vector 907 */
    .long   DefaultISR                       /* Vector 908 */
    .long   DefaultISR                       /* Vector 909 */
    .long   DefaultISR                       /* Vector 910 */
    .long   DefaultISR                       /* Vector 911 */
    .long   DefaultISR                       /* Vector 912 */
    .long   DefaultISR                       /* Vector 913 */
    .long   DefaultISR                       /* Vector 914 */
    .long   REACM_G_IRQHandler               /* Vector 915 ipi_int_reacm */
    .long   REACM_CH0_IRQHandler             /* Vector 916 ipi_int_reacm_ch0 */
    .long   REACM_CH1_IRQHandler             /* Vector 917 ipi_int_reacm_ch1 */
    .long   REACM_CH2_IRQHandler             /* Vector 918 ipi_int_reacm_ch2 */
    .long   REACM_CH3_IRQHandler             /* Vector 919 ipi_int_reacm_ch3 */
    .long   REACM_CH4_IRQHandler             /* Vector 920 ipi_int_reacm_ch4 */
    .long   REACM_CH5_IRQHandler             /* Vector 921 ipi_int_reacm_ch5 */
    .long   REACM_CH6_IRQHandler             /* Vector 922 ipi_int_reacm_ch6 */
    .long   REACM_CH7_IRQHandler             /* Vector 923 ipi_int_reacm_ch7 */
    .long   REACM_CH8_IRQHandler             /* Vector 924 ipi_int_reacm_ch8 */
    .long   REACM_CH9_IRQHandler             /* Vector 925 ipi_int_reacm_ch9 */
    .long   DefaultISR                       /* Vector 926 */
    .long   DefaultISR                       /* Vector 927 */
    .long   DefaultISR                       /* Vector 928 */
    .long   DefaultISR                       /* Vector 929 */
    .long   DefaultISR                       /* Vector 930 */
    .long   DefaultISR                       /* Vector 931 */
    .long   DECFILTER0_IN_IRQHandler         /* Vector 932 ipi_int_dec_filter_0_in */
    .long   DECFILTER0_OUT_IRQHandler        /* Vector 933 pi_int_dec_filter_0_out */
    .long   DECFILTER0_ERR_IRQHandler        /* Vector 934 ipi_int_dec_filter_0_err */
    .long   DECFILTER1_IN_IRQHandler         /* Vector 935 ipi_int_dec_filter_1_in */
    .long   DECFILTER1_OUT_IRQHandler        /* Vector 936 ipi_int_dec_filter_1_out */
    .long   DECFILTER1_ERR_IRQHandler        /* Vector 937 ipi_int_dec_filter_1_err */

    .align  2
    .weak DefaultISR
    .type DefaultISR, %function
DefaultISR:
    e_b       DefaultISR
    .size DefaultISR, . - DefaultISR

/*    Macro to define default handlers. Default handler
 *    will be weak symbol and just dead loops. They can be
 *    overwritten by other handlers */
    .macro def_irq_handler  handler_name
    .weak \handler_name
    .set  \handler_name, DefaultISR
    .endm

/* Exception Handlers */
    def_irq_handler    IVOR0_Handler
    def_irq_handler    IVOR1_Handler
    def_irq_handler    IVOR2_Handler
    def_irq_handler    IVOR3_Handler
    def_irq_handler    IVOR4_Handler
    def_irq_handler    IVOR5_Handler
    def_irq_handler    IVOR6_Handler
    def_irq_handler    IVOR8_Handler
    def_irq_handler    IVOR15_Handler
    def_irq_handler    IVOR33_Handler
    def_irq_handler    IVOR34_Handler
    def_irq_handler    IVOR35_Handler
    def_irq_handler    IVOR0_Exception_Handler
    def_irq_handler    IVOR1_Exception_Handler
    def_irq_handler    IVOR2_Exception_Handler
    def_irq_handler    IVOR3_Exception_Handler
    def_irq_handler    IVOR5_Exception_Handler
    def_irq_handler    IVOR6_Exception_Handler
    def_irq_handler    IVOR8_Exception_Handler
    def_irq_handler    IVOR15_Exception_Handler
    def_irq_handler    IVOR33_Exception_Handler
    def_irq_handler    IVOR34_Exception_Handler
    def_irq_handler    IVOR35_Exception_Handler
    def_irq_handler    SS0_IRQHandler
    def_irq_handler    SS1_IRQHandler
    def_irq_handler    SS2_IRQHandler
    def_irq_handler    SS3_IRQHandler
    def_irq_handler    SS4_IRQHandler
    def_irq_handler    SS5_IRQHandler
    def_irq_handler    SS6_IRQHandler
    def_irq_handler    SS7_IRQHandler
    def_irq_handler    SS8_IRQHandler
    def_irq_handler    SS9_IRQHandler
    def_irq_handler    SS10_IRQHandler
    def_irq_handler    SS11_IRQHandler
    def_irq_handler    SS12_IRQHandler
    def_irq_handler    SS13_IRQHandler
    def_irq_handler    SS14_IRQHandler
    def_irq_handler    SS15_IRQHandler
    def_irq_handler    SS16_IRQHandler
    def_irq_handler    SS17_IRQHandler
    def_irq_handler    SS18_IRQHandler
    def_irq_handler    SS19_IRQHandler
    def_irq_handler    SS20_IRQHandler
    def_irq_handler    SS21_IRQHandler
    def_irq_handler    SS22_IRQHandler
    def_irq_handler    SS23_IRQHandler
    def_irq_handler    SS24_IRQHandler
    def_irq_handler    SS25_IRQHandler
    def_irq_handler    SS26_IRQHandler
    def_irq_handler    SS27_IRQHandler
    def_irq_handler    SS28_IRQHandler
    def_irq_handler    SS29_IRQHandler
    def_irq_handler    SS30_IRQHandler
    def_irq_handler    SS31_IRQHandler
    def_irq_handler    SWT0_IRQHandler
    def_irq_handler    SWT1_IRQHandler
    def_irq_handler    SWT3_IRQHandler
    def_irq_handler    STM0_CIR0_IRQHandler
    def_irq_handler    STM0_CIR1_IRQHandler
    def_irq_handler    STM0_CIR2_IRQHandler
    def_irq_handler    STM0_CIR3_IRQHandler
    def_irq_handler    STM1_CIR0_IRQHandler
    def_irq_handler    STM1_CIR1_IRQHandler
    def_irq_handler    STM1_CIR2_IRQHandler
    def_irq_handler    STM1_CIR3_IRQHandler
    def_irq_handler    DMA0_Ch0_Ch63_Error_IRQHandler
    def_irq_handler    DMA0_Ch0_IRQHandler
    def_irq_handler    DMA0_Ch1_IRQHandler
    def_irq_handler    DMA0_Ch2_IRQHandler
    def_irq_handler    DMA0_Ch3_IRQHandler
    def_irq_handler    DMA0_Ch4_IRQHandler
    def_irq_handler    DMA0_Ch5_IRQHandler
    def_irq_handler    DMA0_Ch6_IRQHandler
    def_irq_handler    DMA0_Ch7_IRQHandler
    def_irq_handler    DMA0_Ch8_IRQHandler
    def_irq_handler    DMA0_Ch9_IRQHandler
    def_irq_handler    DMA0_Ch10_IRQHandler
    def_irq_handler    DMA0_Ch11_IRQHandler
    def_irq_handler    DMA0_Ch12_IRQHandler
    def_irq_handler    DMA0_Ch13_IRQHandler
    def_irq_handler    DMA0_Ch14_IRQHandler
    def_irq_handler    DMA0_Ch15_IRQHandler
    def_irq_handler    DMA0_Ch16_IRQHandler
    def_irq_handler    DMA0_Ch17_IRQHandler
    def_irq_handler    DMA0_Ch18_IRQHandler
    def_irq_handler    DMA0_Ch19_IRQHandler
    def_irq_handler    DMA0_Ch20_IRQHandler
    def_irq_handler    DMA0_Ch21_IRQHandler
    def_irq_handler    DMA0_Ch22_IRQHandler
    def_irq_handler    DMA0_Ch23_IRQHandler
    def_irq_handler    DMA0_Ch24_IRQHandler
    def_irq_handler    DMA0_Ch25_IRQHandler
    def_irq_handler    DMA0_Ch26_IRQHandler
    def_irq_handler    DMA0_Ch27_IRQHandler
    def_irq_handler    DMA0_Ch28_IRQHandler
    def_irq_handler    DMA0_Ch29_IRQHandler
    def_irq_handler    DMA0_Ch30_IRQHandler
    def_irq_handler    DMA0_Ch31_IRQHandler
    def_irq_handler    DMA0_Ch32_IRQHandler
    def_irq_handler    DMA0_Ch33_IRQHandler
    def_irq_handler    DMA0_Ch34_IRQHandler
    def_irq_handler    DMA0_Ch35_IRQHandler
    def_irq_handler    DMA0_Ch36_IRQHandler
    def_irq_handler    DMA0_Ch37_IRQHandler
    def_irq_handler    DMA0_Ch38_IRQHandler
    def_irq_handler    DMA0_Ch39_IRQHandler
    def_irq_handler    DMA0_Ch40_IRQHandler
    def_irq_handler    DMA0_Ch41_IRQHandler
    def_irq_handler    DMA0_Ch42_IRQHandler
    def_irq_handler    DMA0_Ch43_IRQHandler
    def_irq_handler    DMA0_Ch44_IRQHandler
    def_irq_handler    DMA0_Ch45_IRQHandler
    def_irq_handler    DMA0_Ch46_IRQHandler
    def_irq_handler    DMA0_Ch47_IRQHandler
    def_irq_handler    DMA0_Ch48_IRQHandler
    def_irq_handler    DMA0_Ch49_IRQHandler
    def_irq_handler    DMA0_Ch50_IRQHandler
    def_irq_handler    DMA0_Ch51_IRQHandler
    def_irq_handler    DMA0_Ch52_IRQHandler
    def_irq_handler    DMA0_Ch53_IRQHandler
    def_irq_handler    DMA0_Ch54_IRQHandler
    def_irq_handler    DMA0_Ch55_IRQHandler
    def_irq_handler    DMA0_Ch56_IRQHandler
    def_irq_handler    DMA0_Ch57_IRQHandler
    def_irq_handler    DMA0_Ch58_IRQHandler
    def_irq_handler    DMA0_Ch59_IRQHandler
    def_irq_handler    DMA0_Ch60_IRQHandler
    def_irq_handler    DMA0_Ch61_IRQHandler
    def_irq_handler    DMA0_Ch62_IRQHandler
    def_irq_handler    DMA0_Ch63_IRQHandler
    def_irq_handler    FMC_Done_IRQHandler
    def_irq_handler    FEC_TXF_IRQHandler
    def_irq_handler    FEC_RXF_IRQHandler
    def_irq_handler    FEC_ERR_IRQHandler
    def_irq_handler    PIT0_TFLG0_IRQHandler
    def_irq_handler    PIT0_TFLG1_IRQHandler
    def_irq_handler    PIT0_TFLG2_IRQHandler
    def_irq_handler    PIT0_TFLG3_IRQHandler
    def_irq_handler    PIT0_TFLG4_IRQHandler
    def_irq_handler    PIT0_TFLG5_IRQHandler
    def_irq_handler    PIT0_TFLG6_IRQHandler
    def_irq_handler    PIT0_TFLG7_IRQHandler
    def_irq_handler    PIT0_RTI_IRQHandler
    def_irq_handler    PIT1_TFLG0_IRQHandler
    def_irq_handler    PIT1_TFLG1_IRQHandler
    def_irq_handler    XOSC_IRQHandler
    def_irq_handler    SIU_0_IRQHandler
    def_irq_handler    SIU_1_IRQHandler
    def_irq_handler    MC_ME_SAFE_IRQHandler
    def_irq_handler    MC_ME_MTC_IRQHandler
    def_irq_handler    MC_ME_IMODE_IRQHandler
    def_irq_handler    MC_ME_ICONF_IRQHandler
    def_irq_handler    MC_ME_RGM_IRQHandler
    def_irq_handler    DSPI0_FIFO_Error_IRQHandler
    def_irq_handler    DSPI0_EOQF_IRQHandler
    def_irq_handler    DSPI0_Send_IRQHandler
    def_irq_handler    DSPI0_TCF_IRQHandler
    def_irq_handler    DSPI0_Receive_IRQHandler
    def_irq_handler    DSPI0_CMDTCF_IRQHandler
    def_irq_handler    DSPI0_CMDFFF_IRQHandler
    def_irq_handler    DSPI0_SPEF_IRQHandler
    def_irq_handler    DSPI1_FIFO_Error_IRQHandler
    def_irq_handler    DSPI1_EOQF_IRQHandler
    def_irq_handler    DSPI1_Send_IRQHandler
    def_irq_handler    DSPI1_TCF_IRQHandler
    def_irq_handler    DSPI1_Receive_IRQHandler
    def_irq_handler    DSPI1_CMDTCF_IRQHandler
    def_irq_handler    DSPI1_CMDFFF_IRQHandler
    def_irq_handler    DSPI1_SPEF_IRQHandler
    def_irq_handler    DSPI2_FIFO_Error_IRQHandler
    def_irq_handler    DSPI2_EOQF_IRQHandler
    def_irq_handler    DSPI2_Send_IRQHandler
    def_irq_handler    DSPI2_TCF_IRQHandler
    def_irq_handler    DSPI2_Receive_IRQHandler
    def_irq_handler    DSPI2_CMDTCF_IRQHandler
    def_irq_handler    DSPI2_CMDFFF_IRQHandler
    def_irq_handler    DSPI2_SPEF_IRQHandler
    def_irq_handler    DSPI3_FIFO_Error_IRQHandler
    def_irq_handler    DSPI3_EOQF_IRQHandler
    def_irq_handler    DSPI3_Send_IRQHandler
    def_irq_handler    DSPI3_TCF_IRQHandler
    def_irq_handler    DSPI3_Receive_IRQHandler
    def_irq_handler    DSPI3_CMDTCF_IRQHandler
    def_irq_handler    DSPI3_CMDFFF_IRQHandler
    def_irq_handler    DSPI3_SPEF_IRQHandler
    def_irq_handler    DSPI4_FIFO_Error_IRQHandler
    def_irq_handler    DSPI4_EOQF_IRQHandler
    def_irq_handler    DSPI4_Send_IRQHandler
    def_irq_handler    DSPI4_TCF_IRQHandler
    def_irq_handler    DSPI4_Receive_IRQHandler
    def_irq_handler    DSPI4_CMDTCF_IRQHandler
    def_irq_handler    DSPI4_CMDFFF_IRQHandler
    def_irq_handler    DSPI4_SPEF_IRQHandler
    def_irq_handler    DSPI5_FIFO_Error_IRQHandler
    def_irq_handler    DSPI_M0_EOQF_IRQHandler
    def_irq_handler    DSPI5_Send_IRQHandler
    def_irq_handler    DSPI_M0_TCF_IRQHandler
    def_irq_handler    DSPI5_Receive_IRQHandler
    def_irq_handler    DSPI_M0_CMDTCF_IRQHandler
    def_irq_handler    DSPI_M0_CMDFFF_IRQHandler
    def_irq_handler    DSPI_M0_SPEF_IRQHandler
    def_irq_handler    DSPI_M0_DDIF_IRQHandler
    def_irq_handler    DSPI6_FIFO_Error_IRQHandler
    def_irq_handler    DSPI_M1_EOQF_IRQHandler
    def_irq_handler    DSPI6_Send_IRQHandler
    def_irq_handler    DSPI_M1_TCF_IRQHandler
    def_irq_handler    DSPI6_Receive_IRQHandler
    def_irq_handler    DSPI_M1_CMDTCF_IRQHandler
    def_irq_handler    DSPI_M1_CMDFFF_IRQHandler
    def_irq_handler    DSPI_M1_SPEF_IRQHandler
    def_irq_handler    DSPI_M1_DDIF_IRQHandler
    def_irq_handler    LINFLEXD0_RX_IRQHandler
    def_irq_handler    LINFLEXD0_TX_IRQHandler
    def_irq_handler    LINFLEXD0_ERR_IRQHandler
    def_irq_handler    LINFLEXD1_RX_IRQHandler
    def_irq_handler    LINFLEXD1_TX_IRQHandler
    def_irq_handler    LINFLEXD1_ERR_IRQHandler
    def_irq_handler    LINFLEXD2_RX_IRQHandler
    def_irq_handler    LINFLEXD2_TX_IRQHandler
    def_irq_handler    LINFLEXD2_ERR_IRQHandler
    def_irq_handler    LINFLEXD3_RX_IRQHandler
    def_irq_handler    LINFLEXD3_TX_IRQHandler
    def_irq_handler    LINFLEXD3_ERR_IRQHandler
    def_irq_handler    LINFLEXD_M0_RX_IRQHandler
    def_irq_handler    LINFLEXD_M0_TX_IRQHandler
    def_irq_handler    LINFLEXD_M0_ERR_IRQHandler
    def_irq_handler    LINFLEXD_M1_RX_IRQHandler
    def_irq_handler    LINFLEXD_M1_TX_IRQHandler
    def_irq_handler    LINFLEXD_M1_ERR_IRQHandler
    def_irq_handler    PMU_IRQHandler
    def_irq_handler    PMU_TSENSE_IRQHandler
    def_irq_handler    PLL_0_0_IRQHandler
    def_irq_handler    PLL_1_0_IRQHandler
    def_irq_handler    PLL_0_1_IRQHandler
    def_irq_handler    PLL_1_1_IRQHandler
    def_irq_handler    FCCU_ALARM_IRQHandler
    def_irq_handler    FCCU_MISC_IRQHandler
    def_irq_handler    FCCU_RCCS0_IRQHandler
    def_irq_handler    FCCU_RCCS1_IRQHandler
    def_irq_handler    STCU2_0_IRQHandler
    def_irq_handler    STCU2_1_IRQHandler
    def_irq_handler    ADC0_EOC_IRQHandler
    def_irq_handler    ADC0_ER_IRQHandler
    def_irq_handler    ADC0_WD_IRQHandler
    def_irq_handler    ADC1_EOC_IRQHandler
    def_irq_handler    ADC1_ER_IRQHandler
    def_irq_handler    ADC1_WD_IRQHandler
    def_irq_handler    ADC2_EOC_IRQHandler
    def_irq_handler    ADC2_ER_IRQHandler
    def_irq_handler    ADC2_WD_IRQHandler
    def_irq_handler    ADC3_EOC_IRQHandler
    def_irq_handler    ADC3_ER_IRQHandler
    def_irq_handler    ADC3_WD_IRQHandler
    def_irq_handler    SDADC0_IRQHandler
    def_irq_handler    SDADC1_IRQHandler
    def_irq_handler    SDADC2_IRQHandler
    def_irq_handler    SENT0_Fast_IRQHandler
    def_irq_handler    SENT0_Slow_IRQHandler
    def_irq_handler    SENT0_RxErr_IRQHandler
    def_irq_handler    SENT1_Fast_IRQHandler
    def_irq_handler    SENT1_Slow_IRQHandler
    def_irq_handler    SENT1_RxErr_IRQHandler
    def_irq_handler    SENT0_Fast_0_IRQHandler
    def_irq_handler    SENT0_Slow_0_IRQHandler
    def_irq_handler    SENT0_RxErr_0_IRQHandler
    def_irq_handler    SENT0_Fast_1_IRQHandler
    def_irq_handler    SENT0_Slow_1_IRQHandler
    def_irq_handler    SENT0_RxErr_1_IRQHandler
    def_irq_handler    SENT0_Fast_2_IRQHandler
    def_irq_handler    SENT0_Slow_2_IRQHandler
    def_irq_handler    SENT0_RxErr_2_IRQHandler
    def_irq_handler    SENT1_Fast_0_IRQHandler
    def_irq_handler    SENT1_Slow_0_IRQHandler
    def_irq_handler    SENT1_RxErr_0_IRQHandler
    def_irq_handler    SENT1_Fast_1_IRQHandler
    def_irq_handler    SENT1_Slow_1_IRQHandler
    def_irq_handler    SENT1_RxErr_1_IRQHandler
    def_irq_handler    SENT1_Fast_2_IRQHandler
    def_irq_handler    SENT1_Slow_2_IRQHandler
    def_irq_handler    SENT1_RxErr_2_IRQHandler
    def_irq_handler    SIPI0_ErrorIrqHandler
    def_irq_handler    SIPI0_CrcErrorIrqHandler
    def_irq_handler    SIPI0_Ch0ResponseOrAckIrqHandler
    def_irq_handler    SIPI0_Ch1ResponseOrAckIrqHandler
    def_irq_handler    SIPI0_Ch2ResponseOrAckIrqHandler
    def_irq_handler    SIPI0_Ch3ResponseOrAckIrqHandler
    def_irq_handler    SIPI0_TriggerOrMaxCountReachedIrqHandler
    def_irq_handler    LFAST0_0_IRQHandler
    def_irq_handler    LFAST0_1_IRQHandler
    def_irq_handler    LFAST0_2_IRQHandler
    def_irq_handler    LFAST0_3_IRQHandler
    def_irq_handler    LFAST0_4_IRQHandler
    def_irq_handler    JTAGM_IRQHandler
    def_irq_handler    JDC_IRQHandler
    def_irq_handler    CAN0_0_IRQHandler
    def_irq_handler    CAN0_1_IRQHandler
    def_irq_handler    CAN0_5_IRQHandler
    def_irq_handler    CAN0_2_IRQHandler
    def_irq_handler    CAN0_3_IRQHandler
    def_irq_handler    CAN0_4_IRQHandler
    def_irq_handler    CAN1_0_IRQHandler
    def_irq_handler    CAN1_1_IRQHandler
    def_irq_handler    CAN1_5_IRQHandler
    def_irq_handler    CAN1_2_IRQHandler
    def_irq_handler    CAN1_3_IRQHandler
    def_irq_handler    CAN1_4_IRQHandler
    def_irq_handler    CAN2_0_IRQHandler
    def_irq_handler    CAN2_1_IRQHandler
    def_irq_handler    CAN2_5_IRQHandler
    def_irq_handler    CAN2_2_IRQHandler
    def_irq_handler    CAN2_3_IRQHandler
    def_irq_handler    CAN2_4_IRQHandler
    def_irq_handler    CAN3_0_IRQHandler
    def_irq_handler    CAN3_1_IRQHandler
    def_irq_handler    CAN3_5_IRQHandler
    def_irq_handler    CAN3_2_IRQHandler
    def_irq_handler    CAN3_3_IRQHandler
    def_irq_handler    CAN3_4_IRQHandler
    def_irq_handler    EMIOS0_8_IRQHandler
    def_irq_handler    EMIOS0_9_IRQHandler
    def_irq_handler    EMIOS0_10_IRQHandler
    def_irq_handler    EMIOS0_11_IRQHandler
    def_irq_handler    EMIOS0_12_IRQHandler
    def_irq_handler    EMIOS0_13_IRQHandler
    def_irq_handler    EMIOS0_14_IRQHandler
    def_irq_handler    EMIOS0_15_IRQHandler
    def_irq_handler    EMIOS0_16_IRQHandler
    def_irq_handler    EMIOS0_17_IRQHandler
    def_irq_handler    EMIOS0_18_IRQHandler
    def_irq_handler    EMIOS0_19_IRQHandler
    def_irq_handler    EMIOS0_20_IRQHandler
    def_irq_handler    EMIOS0_21_IRQHandler
    def_irq_handler    EMIOS0_22_IRQHandler
    def_irq_handler    EMIOS0_23_IRQHandler
    def_irq_handler    EMIOS1_8_IRQHandler
    def_irq_handler    EMIOS1_9_IRQHandler
    def_irq_handler    EMIOS1_10_IRQHandler
    def_irq_handler    EMIOS1_11_IRQHandler
    def_irq_handler    EMIOS1_12_IRQHandler
    def_irq_handler    EMIOS1_13_IRQHandler
    def_irq_handler    EMIOS1_14_IRQHandler
    def_irq_handler    EMIOS1_15_IRQHandler
    def_irq_handler    EMIOS1_16_IRQHandler
    def_irq_handler    EMIOS1_17_IRQHandler
    def_irq_handler    EMIOS1_18_IRQHandler
    def_irq_handler    EMIOS1_19_IRQHandler
    def_irq_handler    EMIOS1_20_IRQHandler
    def_irq_handler    EMIOS1_21_IRQHandler
    def_irq_handler    EMIOS1_22_IRQHandler
    def_irq_handler    EMIOS1_23_IRQHandler
    def_irq_handler    ETPU_GE_IRQHandler
    def_irq_handler    ETPU0_CIS0_IRQHandler
    def_irq_handler    ETPU0_CIS1_IRQHandler
    def_irq_handler    ETPU0_CIS2_IRQHandler
    def_irq_handler    ETPU0_CIS3_IRQHandler
    def_irq_handler    ETPU0_CIS4_IRQHandler
    def_irq_handler    ETPU0_CIS5_IRQHandler
    def_irq_handler    ETPU0_CIS6_IRQHandler
    def_irq_handler    ETPU0_CIS7_IRQHandler
    def_irq_handler    ETPU0_CIS8_IRQHandler
    def_irq_handler    ETPU0_CIS9_IRQHandler
    def_irq_handler    ETPU0_CIS10_IRQHandler
    def_irq_handler    ETPU0_CIS11_IRQHandler
    def_irq_handler    ETPU0_CIS12_IRQHandler
    def_irq_handler    ETPU0_CIS13_IRQHandler
    def_irq_handler    ETPU0_CIS14_IRQHandler
    def_irq_handler    ETPU0_CIS15_IRQHandler
    def_irq_handler    ETPU0_CIS16_IRQHandler
    def_irq_handler    ETPU0_CIS17_IRQHandler
    def_irq_handler    ETPU0_CIS18_IRQHandler
    def_irq_handler    ETPU0_CIS19_IRQHandler
    def_irq_handler    ETPU0_CIS20_IRQHandler
    def_irq_handler    ETPU0_CIS21_IRQHandler
    def_irq_handler    ETPU0_CIS22_IRQHandler
    def_irq_handler    ETPU0_CIS23_IRQHandler
    def_irq_handler    ETPU0_CIS24_IRQHandler
    def_irq_handler    ETPU0_CIS25_IRQHandler
    def_irq_handler    ETPU0_CIS26_IRQHandler
    def_irq_handler    ETPU0_CIS27_IRQHandler
    def_irq_handler    ETPU0_CIS28_IRQHandler
    def_irq_handler    ETPU0_CIS29_IRQHandler
    def_irq_handler    ETPU0_CIS30_IRQHandler
    def_irq_handler    ETPU0_CIS31_IRQHandler
    def_irq_handler    ETPU1_CIS0_IRQHandler
    def_irq_handler    ETPU1_CIS1_IRQHandler
    def_irq_handler    ETPU1_CIS2_IRQHandler
    def_irq_handler    ETPU1_CIS3_IRQHandler
    def_irq_handler    ETPU1_CIS4_IRQHandler
    def_irq_handler    ETPU1_CIS5_IRQHandler
    def_irq_handler    ETPU1_CIS6_IRQHandler
    def_irq_handler    ETPU1_CIS7_IRQHandler
    def_irq_handler    ETPU1_CIS8_IRQHandler
    def_irq_handler    ETPU1_CIS9_IRQHandler
    def_irq_handler    ETPU1_CIS10_IRQHandler
    def_irq_handler    ETPU1_CIS11_IRQHandler
    def_irq_handler    ETPU1_CIS12_IRQHandler
    def_irq_handler    ETPU1_CIS13_IRQHandler
    def_irq_handler    ETPU1_CIS14_IRQHandler
    def_irq_handler    ETPU1_CIS15_IRQHandler
    def_irq_handler    ETPU1_CIS16_IRQHandler
    def_irq_handler    ETPU1_CIS17_IRQHandler
    def_irq_handler    ETPU1_CIS18_IRQHandler
    def_irq_handler    ETPU1_CIS19_IRQHandler
    def_irq_handler    ETPU1_CIS20_IRQHandler
    def_irq_handler    ETPU1_CIS21_IRQHandler
    def_irq_handler    ETPU1_CIS22_IRQHandler
    def_irq_handler    ETPU1_CIS23_IRQHandler
    def_irq_handler    ETPU1_CIS24_IRQHandler
    def_irq_handler    ETPU1_CIS25_IRQHandler
    def_irq_handler    ETPU1_CIS26_IRQHandler
    def_irq_handler    ETPU1_CIS27_IRQHandler
    def_irq_handler    ETPU1_CIS28_IRQHandler
    def_irq_handler    ETPU1_CIS29_IRQHandler
    def_irq_handler    ETPU1_CIS30_IRQHandler
    def_irq_handler    ETPU1_CIS31_IRQHandler
    def_irq_handler    BCTU0_TRI_IRQHandler
    def_irq_handler    BCTU0_ADC0_IRQHandler
    def_irq_handler    BCTU0_ADC1_IRQHandler
    def_irq_handler    BCTU0_ADC2_IRQHandler
    def_irq_handler    BCTU0_ADC3_IRQHandler
    def_irq_handler    BCTU0_LIST_IRQHandler
    def_irq_handler    REACM_G_IRQHandler
    def_irq_handler    REACM_CH0_IRQHandler
    def_irq_handler    REACM_CH1_IRQHandler
    def_irq_handler    REACM_CH2_IRQHandler
    def_irq_handler    REACM_CH3_IRQHandler
    def_irq_handler    REACM_CH4_IRQHandler
    def_irq_handler    REACM_CH5_IRQHandler
    def_irq_handler    REACM_CH6_IRQHandler
    def_irq_handler    REACM_CH7_IRQHandler
    def_irq_handler    REACM_CH8_IRQHandler
    def_irq_handler    REACM_CH9_IRQHandler
    def_irq_handler    DECFILTER0_IN_IRQHandler
    def_irq_handler    DECFILTER0_OUT_IRQHandler
    def_irq_handler    DECFILTER0_ERR_IRQHandler
    def_irq_handler    DECFILTER1_IN_IRQHandler
    def_irq_handler    DECFILTER1_OUT_IRQHandler
    def_irq_handler    DECFILTER1_ERR_IRQHandler
