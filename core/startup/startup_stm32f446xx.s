/* STM32F446x Startup for GCC (RAM/FLASH compatible)
 * - Places vector table in .isr_vector (align 128B)
 * - Copies .data, zeros .bss
 * - Sets SCB->VTOR to &__Vectors (works for RAM builds)
 * - Calls SystemInit, __libc_init_array, main
 */

.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

/* Externs from C/Lib/Linker */
.global  Reset_Handler
.extern  SystemInit
.extern  __libc_init_array
.extern  main

/* From linker script */
.extern  _estack
.extern  _sidata
.extern  _sdata
.extern  _edata
.extern  _sbss
.extern  _ebss
.extern  __HeapBase
.extern  __HeapLimit

/* Vector table ----------------------------------------------------------- */
.section .isr_vector, "a", %progbits
.balign 128
.global __Vectors
.global __Vectors_End
.type   __Vectors, %object

__Vectors:
  .word  _estack            /* Initial SP */
  .word  Reset_Handler      /* Reset */
  .word  NMI_Handler
  .word  HardFault_Handler
  .word  MemManage_Handler
  .word  BusFault_Handler
  .word  UsageFault_Handler
  .word  0                  /* Reserved */
  .word  0                  /* Reserved */
  .word  0                  /* Reserved */
  .word  0                  /* Reserved */
  .word  SVC_Handler
  .word  DebugMon_Handler
  .word  0                  /* Reserved */
  .word  PendSV_Handler
  .word  SysTick_Handler

  /* External Interrupts (STM32F446xx) */
  .word  WWDG_IRQHandler
  .word  PVD_IRQHandler
  .word  TAMP_STAMP_IRQHandler
  .word  RTC_WKUP_IRQHandler
  .word  FLASH_IRQHandler
  .word  RCC_IRQHandler
  .word  EXTI0_IRQHandler
  .word  EXTI1_IRQHandler
  .word  EXTI2_IRQHandler
  .word  EXTI3_IRQHandler
  .word  EXTI4_IRQHandler
  .word  DMA1_Stream0_IRQHandler
  .word  DMA1_Stream1_IRQHandler
  .word  DMA1_Stream2_IRQHandler
  .word  DMA1_Stream3_IRQHandler
  .word  DMA1_Stream4_IRQHandler
  .word  DMA1_Stream5_IRQHandler
  .word  DMA1_Stream6_IRQHandler
  .word  ADC_IRQHandler
  .word  CAN1_TX_IRQHandler
  .word  CAN1_RX0_IRQHandler
  .word  CAN1_RX1_IRQHandler
  .word  CAN1_SCE_IRQHandler
  .word  EXTI9_5_IRQHandler
  .word  TIM1_BRK_TIM9_IRQHandler
  .word  TIM1_UP_TIM10_IRQHandler
  .word  TIM1_TRG_COM_TIM11_IRQHandler
  .word  TIM1_CC_IRQHandler
  .word  TIM2_IRQHandler
  .word  TIM3_IRQHandler
  .word  TIM4_IRQHandler
  .word  I2C1_EV_IRQHandler
  .word  I2C1_ER_IRQHandler
  .word  I2C2_EV_IRQHandler
  .word  I2C2_ER_IRQHandler
  .word  SPI1_IRQHandler
  .word  SPI2_IRQHandler
  .word  USART1_IRQHandler
  .word  USART2_IRQHandler
  .word  USART3_IRQHandler
  .word  EXTI15_10_IRQHandler
  .word  RTC_Alarm_IRQHandler
  .word  OTG_FS_WKUP_IRQHandler
  .word  TIM8_BRK_TIM12_IRQHandler
  .word  TIM8_UP_TIM13_IRQHandler
  .word  TIM8_TRG_COM_TIM14_IRQHandler
  .word  TIM8_CC_IRQHandler
  .word  DMA1_Stream7_IRQHandler
  .word  FMC_IRQHandler
  .word  SDIO_IRQHandler
  .word  TIM5_IRQHandler
  .word  SPI3_IRQHandler
  .word  UART4_IRQHandler
  .word  UART5_IRQHandler
  .word  TIM6_DAC_IRQHandler
  .word  TIM7_IRQHandler
  .word  DMA2_Stream0_IRQHandler
  .word  DMA2_Stream1_IRQHandler
  .word  DMA2_Stream2_IRQHandler
  .word  DMA2_Stream3_IRQHandler
  .word  DMA2_Stream4_IRQHandler
  .word  0                         /* Reserved */
  .word  0                         /* Reserved */
  .word  CAN2_TX_IRQHandler
  .word  CAN2_RX0_IRQHandler
  .word  CAN2_RX1_IRQHandler
  .word  CAN2_SCE_IRQHandler
  .word  OTG_FS_IRQHandler
  .word  DMA2_Stream5_IRQHandler
  .word  DMA2_Stream6_IRQHandler
  .word  DMA2_Stream7_IRQHandler
  .word  USART6_IRQHandler
  .word  I2C3_EV_IRQHandler
  .word  I2C3_ER_IRQHandler
  .word  OTG_HS_EP1_OUT_IRQHandler
  .word  OTG_HS_EP1_IN_IRQHandler
  .word  OTG_HS_WKUP_IRQHandler
  .word  OTG_HS_IRQHandler
  .word  DCMI_IRQHandler
  .word  0                         /* Reserved */
  .word  0                         /* Reserved */
  .word  FPU_IRQHandler
  .word  0                         /* Reserved */
  .word  0                         /* Reserved */
  .word  SPI4_IRQHandler
  .word  0                         /* Reserved */
  .word  0                         /* Reserved */
  .word  SAI1_IRQHandler
  .word  0                         /* Reserved */
  .word  0                         /* Reserved */
  .word  0                         /* Reserved */
  .word  SAI2_IRQHandler
  .word  QUADSPI_IRQHandler
  .word  CEC_IRQHandler
  .word  SPDIF_RX_IRQHandler
  .word  FMPI2C1_EV_IRQHandler
  .word  FMPI2C1_ER_IRQHandler

__Vectors_End:
.size __Vectors, . - __Vectors

/* Reset Handler ---------------------------------------------------------- */
.section .text.Reset_Handler, "ax", %progbits
.align 2
.type   Reset_Handler, %function
Reset_Handler:
  /* Optionally set VTOR to the vector table address (works for RAM & FLASH) */
  ldr   r0, =0xE000ED08        /* SCB->VTOR */
  ldr   r1, =__Vectors
  str   r1, [r0]

  /* Copy .data (if any) */
  ldr   r0, =_sidata
  ldr   r1, =_sdata
  ldr   r2, =_edata
1:
  cmp   r1, r2
  bcc   2f
  b     3f
2:
  ldr   r3, [r0], #4
  str   r3, [r1], #4
  b     1b

3:
  /* Zero .bss */
  ldr   r1, =_sbss
  ldr   r2, =_ebss
  movs  r3, #0
4:
  cmp   r1, r2
  bcc   5f
  b     6f
5:
  str   r3, [r1], #4
  b     4b

6:
  /* System init (clocks, FPU, etc.) */
  bl    SystemInit

  /* C/C++ global constructors */
  bl    __libc_init_array

  /* Call main() */
  bl    main

  /* If main returns, loop forever */
  b     .

.size Reset_Handler, . - Reset_Handler

/* Default handlers ------------------------------------------------------- */
.section .text.Default_Handler, "ax", %progbits
.align 2
.global Default_Handler
.type   Default_Handler, %function
Default_Handler:
  b .

/* Weak aliases ----------------------------------------------------------- */
.macro WEAK_DEFAULT name
  .weak \name
  .thumb_set \name, Default_Handler
.endm

/* Core exceptions */
WEAK_DEFAULT NMI_Handler
WEAK_DEFAULT HardFault_Handler
WEAK_DEFAULT MemManage_Handler
WEAK_DEFAULT BusFault_Handler
WEAK_DEFAULT UsageFault_Handler
WEAK_DEFAULT SVC_Handler
WEAK_DEFAULT DebugMon_Handler
WEAK_DEFAULT PendSV_Handler
WEAK_DEFAULT SysTick_Handler

/* IRQs */
WEAK_DEFAULT WWDG_IRQHandler
WEAK_DEFAULT PVD_IRQHandler
WEAK_DEFAULT TAMP_STAMP_IRQHandler
WEAK_DEFAULT RTC_WKUP_IRQHandler
WEAK_DEFAULT FLASH_IRQHandler
WEAK_DEFAULT RCC_IRQHandler
WEAK_DEFAULT EXTI0_IRQHandler
WEAK_DEFAULT EXTI1_IRQHandler
WEAK_DEFAULT EXTI2_IRQHandler
WEAK_DEFAULT EXTI3_IRQHandler
WEAK_DEFAULT EXTI4_IRQHandler
WEAK_DEFAULT DMA1_Stream0_IRQHandler
WEAK_DEFAULT DMA1_Stream1_IRQHandler
WEAK_DEFAULT DMA1_Stream2_IRQHandler
WEAK_DEFAULT DMA1_Stream3_IRQHandler
WEAK_DEFAULT DMA1_Stream4_IRQHandler
WEAK_DEFAULT DMA1_Stream5_IRQHandler
WEAK_DEFAULT DMA1_Stream6_IRQHandler
WEAK_DEFAULT ADC_IRQHandler
WEAK_DEFAULT CAN1_TX_IRQHandler
WEAK_DEFAULT CAN1_RX0_IRQHandler
WEAK_DEFAULT CAN1_RX1_IRQHandler
WEAK_DEFAULT CAN1_SCE_IRQHandler
WEAK_DEFAULT EXTI9_5_IRQHandler
WEAK_DEFAULT TIM1_BRK_TIM9_IRQHandler
WEAK_DEFAULT TIM1_UP_TIM10_IRQHandler
WEAK_DEFAULT TIM1_TRG_COM_TIM11_IRQHandler
WEAK_DEFAULT TIM1_CC_IRQHandler
WEAK_DEFAULT TIM2_IRQHandler
WEAK_DEFAULT TIM3_IRQHandler
WEAK_DEFAULT TIM4_IRQHandler
WEAK_DEFAULT I2C1_EV_IRQHandler
WEAK_DEFAULT I2C1_ER_IRQHandler
WEAK_DEFAULT I2C2_EV_IRQHandler
WEAK_DEFAULT I2C2_ER_IRQHandler
WEAK_DEFAULT SPI1_IRQHandler
WEAK_DEFAULT SPI2_IRQHandler
WEAK_DEFAULT USART1_IRQHandler
WEAK_DEFAULT USART2_IRQHandler
WEAK_DEFAULT USART3_IRQHandler
WEAK_DEFAULT EXTI15_10_IRQHandler
WEAK_DEFAULT RTC_Alarm_IRQHandler
WEAK_DEFAULT OTG_FS_WKUP_IRQHandler
WEAK_DEFAULT TIM8_BRK_TIM12_IRQHandler
WEAK_DEFAULT TIM8_UP_TIM13_IRQHandler
WEAK_DEFAULT TIM8_TRG_COM_TIM14_IRQHandler
WEAK_DEFAULT TIM8_CC_IRQHandler
WEAK_DEFAULT DMA1_Stream7_IRQHandler
WEAK_DEFAULT FMC_IRQHandler
WEAK_DEFAULT SDIO_IRQHandler
WEAK_DEFAULT TIM5_IRQHandler
WEAK_DEFAULT SPI3_IRQHandler
WEAK_DEFAULT UART4_IRQHandler
WEAK_DEFAULT UART5_IRQHandler
WEAK_DEFAULT TIM6_DAC_IRQHandler
WEAK_DEFAULT TIM7_IRQHandler
WEAK_DEFAULT DMA2_Stream0_IRQHandler
WEAK_DEFAULT DMA2_Stream1_IRQHandler
WEAK_DEFAULT DMA2_Stream2_IRQHandler
WEAK_DEFAULT DMA2_Stream3_IRQHandler
WEAK_DEFAULT DMA2_Stream4_IRQHandler
/* two reserved */
WEAK_DEFAULT CAN2_TX_IRQHandler
WEAK_DEFAULT CAN2_RX0_IRQHandler
WEAK_DEFAULT CAN2_RX1_IRQHandler
WEAK_DEFAULT CAN2_SCE_IRQHandler
WEAK_DEFAULT OTG_FS_IRQHandler
WEAK_DEFAULT DMA2_Stream5_IRQHandler
WEAK_DEFAULT DMA2_Stream6_IRQHandler
WEAK_DEFAULT DMA2_Stream7_IRQHandler
WEAK_DEFAULT USART6_IRQHandler
WEAK_DEFAULT I2C3_EV_IRQHandler
WEAK_DEFAULT I2C3_ER_IRQHandler
WEAK_DEFAULT OTG_HS_EP1_OUT_IRQHandler
WEAK_DEFAULT OTG_HS_EP1_IN_IRQHandler
WEAK_DEFAULT OTG_HS_WKUP_IRQHandler
WEAK_DEFAULT OTG_HS_IRQHandler
WEAK_DEFAULT DCMI_IRQHandler
/* two reserved */
WEAK_DEFAULT FPU_IRQHandler
/* two reserved */
WEAK_DEFAULT SPI4_IRQHandler
/* two reserved */
WEAK_DEFAULT SAI1_IRQHandler
/* three reserved */
WEAK_DEFAULT SAI2_IRQHandler
WEAK_DEFAULT QUADSPI_IRQHandler
WEAK_DEFAULT CEC_IRQHandler
WEAK_DEFAULT SPDIF_RX_IRQHandler
WEAK_DEFAULT FMPI2C1_EV_IRQHandler
WEAK_DEFAULT FMPI2C1_ER_IRQHandler

/* End */
