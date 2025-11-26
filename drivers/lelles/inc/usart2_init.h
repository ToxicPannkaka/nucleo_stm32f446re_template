/* SPDX-License-Identifier: MIT */
/**
 * @file    usart2_init.h
 * @brief   Simple, blocking initialization of USART2 on STM32F446RE (Nucleo).
 *
 * BEGINNER NOTES
 *  - "USART" is the serial peripheral. We use USART2 because on Nucleo-F446RE
 *    its pins (PA2 TX, PA3 RX) are connected to the ST-LINK Virtual COM Port.
 *  - After calling usart2_init(115200), you can open a serial terminal on your
 *    PC (e.g., /dev/ttyACM0 @ 115200 8N1) and see text printed by printf(),
 *    if you also compile retarget_usart.c (which routes printf to USART2).
 *  - This header exposes a single function: usart2_init(baudrate).
 *
 * REQUIREMENTS
 *  - You are using the STM32F4 SPL (Standard Peripheral Library).
 *  - Add: -DSTM32F446xx -DUSE_STDPERIPH_DRIVER to your compile flags.
 */

#ifndef USART2_INIT_H
#define USART2_INIT_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

/**
 * @brief  Initialize USART2 (PA2 TX, PA3 RX) for basic, blocking I/O (8N1).
 * @param  baudrate  Typical value: 115200. Can be any supported standard baud.
 * @note   This ONLY configures basic TX/RX. No interrupts, no DMA.
 *         It is enough for printf() logging (with retarget_usart.c).
 */
void usart2_init(uint32_t baudrate);

#ifdef __cplusplus
}
#endif

#endif /* USART2_INIT_H */