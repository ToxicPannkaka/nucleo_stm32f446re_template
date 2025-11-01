/* SPDX-License-Identifier: MIT */
/**
 * @file    usart2_init.c
 * @brief   Configure GPIO and clocks, then bring up USART2 on STM32F446RE.
 *
 * WHAT THIS DOES (STEP BY STEP)
 *  1) Enable the clocks for GPIOA and USART2 so the hardware blocks are alive.
 *  2) Configure PA2 and PA3 to "Alternate Function" mode AF7:
 *     - PA2 becomes USART2_TX (transmit)
 *     - PA3 becomes USART2_RX (receive)
 *  3) Configure USART2 for 8 data bits, no parity, 1 stop bit (8N1),
 *     with the requested baud rate, and enable both TX and RX.
 *  4) Turn the peripheral ON (USART_Cmd).
 *
 * AFTER THIS:
 *  - Writing a byte to USART2 will appear on the ST-LINK Virtual COM Port.
 *  - Reading from USART2 will fetch bytes coming from your PC terminal.
 *
 * LIMITATIONS:
 *  - This is a minimal, blocking configuration for simplicity.
 *  - For high throughput or non-blocking behavior, consider interrupts/DMA.
 */

#include "usart2_init.h"

#include "stm32f4xx_rcc.h"
#include "stm32f4xx_gpio.h"
#include "stm32f4xx_usart.h"

void usart2_init(uint32_t baudrate)
{
    /* --- 1) Turn on the clocks -------------------------------------------
     * Peripherals are disabled after reset. You must enable their clocks or
     * any register access will appear to "do nothing".
     */
    RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOA, ENABLE);  /* PA2/PA3 live here */
    RCC_APB1PeriphClockCmd(RCC_APB1Periph_USART2, ENABLE); /* USART2 is on APB1 */

    /* --- 2) Configure pins PA2/PA3 for USART2 -----------------------------
     * "Alternate Function" (AF) means the pin is controlled by a peripheral
     * instead of acting as a raw input/output.
     * AF7 is the function number for USART2 on these pins.
     */
    GPIO_InitTypeDef gpio;
    GPIO_StructInit(&gpio);                  /* start from known defaults */
    gpio.GPIO_Pin   = GPIO_Pin_2 | GPIO_Pin_3;  /* PA2 (TX), PA3 (RX) */
    gpio.GPIO_Mode  = GPIO_Mode_AF;          /* alternate function (peripheral) */
    gpio.GPIO_Speed = GPIO_Speed_50MHz;      /* output slew rate; 50 MHz is fine */
    gpio.GPIO_OType = GPIO_OType_PP;         /* push-pull driver for TX */
    gpio.GPIO_PuPd  = GPIO_PuPd_UP;          /* pull-up so RX idles high (UART idle) */
    GPIO_Init(GPIOA, &gpio);

    /* Connect the pins to the correct peripheral function (AF7 for USART2) */
    GPIO_PinAFConfig(GPIOA, GPIO_PinSource2, GPIO_AF_USART2);  /* PA2 -> TX */
    GPIO_PinAFConfig(GPIOA, GPIO_PinSource3, GPIO_AF_USART2);  /* PA3 -> RX */

    /* --- 3) Configure USART2 itself --------------------------------------
     * We use the SPL helper which calculates the BRR (baud) etc for us based
     * on the current APB clocks (set earlier in SystemInit/clock tree).
     */
    USART_InitTypeDef usart;
    USART_StructInit(&usart);                /* default = 9600 8N1 */
    usart.USART_BaudRate            = baudrate;                 /* e.g. 115200 */
    usart.USART_WordLength          = USART_WordLength_8b;      /* 8 data bits */
    usart.USART_StopBits            = USART_StopBits_1;         /* 1 stop bit  */
    usart.USART_Parity              = USART_Parity_No;          /* no parity   */
    usart.USART_Mode                = USART_Mode_Tx | USART_Mode_Rx; /* both */
    usart.USART_HardwareFlowControl = USART_HardwareFlowControl_None; /* CTS/RTS off */
    USART_Init(USART2, &usart);

    /* --- 4) Enable the peripheral ---------------------------------------- */
    USART_Cmd(USART2, ENABLE);

    /* NOTE:
     *  - At this point, TX is ready to send bytes and RX will collect them.
     *  - If your baud looks wrong, double-check your system clocks (SystemInit).
     */
}
