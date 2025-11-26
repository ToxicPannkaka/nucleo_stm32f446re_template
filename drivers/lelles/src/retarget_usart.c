/* SPDX-License-Identifier: MIT */
/**
 * @file    retarget_usart.c
 * @brief   Route newlib's syscalls to USART2 so printf/scanf work on bare metal.
 *
 * WHY THIS FILE EXISTS
 *  - The C library (newlib) implements printf/scanf, but it doesn't know how
 *    to talk to your board. On an OS, it would call the OS. On bare metal,
 *    it calls these "syscall stubs" instead. You provide them.
 *  - Here we implement a minimal set: _write (for printf), _read (for scanf),
 *    and a few others newlib expects. We send/receive bytes via USART2.
 *
 * BIG PICTURE
 *  - printf("Hello\n") -> newlib writes to file descriptor 1 (stdout)
 *  - newlib calls _write(fd=1, buffer, len)
 *  - Our _write() loops and pushes each byte into USART2 TX (blocking)
 *  - On the PC, you open the Nucleo USB Virtual COM Port and see the text
 *
 * REQUIREMENTS
 *  - Build WITHOUT semihosting (SEMIHOSTING=0), or you'll get duplicate stubs.
 *  - Make sure USART2 is initialized BEFORE first printf (call usart2_init()).
 *  - SPL is used here for register access: stm32f4xx_usart.h etc.
 *
 * LIMITATIONS
 *  - This is a simple, blocking approach: it waits until the UART is ready
 *    for each byte. For higher performance, consider interrupt/DMA solutions.
 */

#include <sys/unistd.h>   /* STDIN_FILENO / STDOUT_FILENO / STDERR_FILENO */
#include <sys/stat.h>     /* struct stat, S_IFCHR */
#include <errno.h>
#include <stdint.h>

#include "stm32f4xx_usart.h"

/* --- Portable fallback: define S_IFCHR if the headers didn't --- */
#ifndef S_IFCHR
#  ifdef _IFCHR
#    define S_IFCHR _IFCHR
#  else
     /* POSIX value (octal) commonly used by newlib: character device bitmask */
#    define S_IFCHR 0020000
#  endif
#endif

/* ---------------- User-tunable options ---------------------------------- */

/**
 * If 1: convert '\n' to "\r\n" on TX.
 * Many serial terminals expect CR+LF for a newline.
 * If 0: send raw '\n' only.
 */
#ifndef RETARGET_TX_CRLF
#define RETARGET_TX_CRLF    1
#endif

/**
 * If 1: _read() waits (blocks) until it has received exactly len bytes.
 * If 0: _read() returns immediately if no data is available (EAGAIN).
 */
#ifndef RETARGET_BLOCKING_READ
#define RETARGET_BLOCKING_READ 1
#endif

/* ---------------- Small helpers (single-byte TX/RX) --------------------- */

/**
 * @brief Send one byte out on USART2 (blocking).
 * @note  Waits for TXE (Transmit Data Register Empty) before writing.
 */
static inline void usart2_write_byte(uint8_t ch)
{
    /* Wait until TX data register is empty:
     *  - TXE=1 means we can write the next byte into the DR register.
     */
    while ((USART2->SR & USART_SR_TXE) == 0) { /* spin */ }
    USART_SendData(USART2, ch);  /* SPL writes to DR; masks width correctly */
}

/**
 * @brief Read one byte from USART2 (blocking).
 * @note  Waits for RXNE (Received Data Ready) before reading.
 */
static inline uint8_t usart2_read_byte(void)
{
    /* Wait until there is a byte to read:
     *  - RXNE=1 means the DR register has valid data.
     */
    while ((USART2->SR & USART_SR_RXNE) == 0) { /* spin */ }
    return (uint8_t)USART_ReceiveData(USART2);
}

/* ---------------- newlib syscall implementations ------------------------ */

/**
 * @brief  Write bytes to a file descriptor.
 * @param  fd   Expected: 1 (stdout) or 2 (stderr)
 * @param  buf  Pointer to the bytes to send
 * @param  len  Number of bytes to send
 * @return len on success, -1 on error with errno set.
 *
 * HOW IT WORKS
 *  - newlib calls this when you do printf/puts/fwrite to stdout/stderr.
 *  - We loop through the buffer and push each byte into USART2.
 *  - Optionally translate '\n' -> "\r\n" for nicer terminals.
 */
int _write(int fd, const void *buf, size_t len)
{
    if (fd != STDOUT_FILENO && fd != STDERR_FILENO) {
        errno = EBADF;                 /* "Bad file descriptor" */
        return -1;
    }

    const uint8_t *p = (const uint8_t *)buf;

    for (size_t i = 0; i < len; ++i) {
#if RETARGET_TX_CRLF
        if (p[i] == '\n') {
            usart2_write_byte('\r');   /* Prepend CR before LF for CRLF */
        }
#endif
        usart2_write_byte(p[i]);
    }

    /* Make sure the last frame has actually gone out on the wire:
     *  - TC=1 (Transmission Complete) means the shift register is empty.
     *  - Without this, a reset right after write() might cut off the last byte.
     */
    while ((USART2->SR & USART_SR_TC) == 0) { /* spin */ }

    return (int)len;                   /* report "all bytes written" */
}

/**
 * @brief  Read bytes from a file descriptor.
 * @param  fd   Expected: 0 (stdin)
 * @param  buf  Buffer to store received bytes
 * @param  len  Number of bytes requested
 * @return Number of bytes read, or -1 on error (errno set).
 *
 * HOW IT WORKS
 *  - newlib calls this when you do scanf/getchar/fread from stdin.
 *  - In blocking mode: waits for exactly 'len' bytes and fills the buffer.
 *  - In non-blocking mode: returns immediately if no data is available.
 */
int _read(int fd, void *buf, size_t len)
{
    if (fd != STDIN_FILENO) {
        errno = EBADF;                 /* stdin only in this simple demo */
        return -1;
    }

    uint8_t *p = (uint8_t *)buf;

#if RETARGET_BLOCKING_READ
    for (size_t i = 0; i < len; ++i) {
        p[i] = usart2_read_byte();     /* wait for and read each byte */
    }
    return (int)len;
#else
    size_t count = 0;
    while (count < len) {
        if ((USART2->SR & USART_SR_RXNE) == 0) {
            /* No data right now. If we haven't read anything yet, signal EAGAIN. */
            if (count == 0) { errno = EAGAIN; return -1; }
            break;
        }
        p[count++] = (uint8_t)USART_ReceiveData(USART2);
    }
    return (int)count;                 /* could be 0..len */
#endif
}

/* The remaining syscalls are minimal stubs to keep newlib happy on bare metal.
 * We do not have a filesystem here, so they return "not implemented".
 */
int _close(int fd)                      { (void)fd; errno = ENOSYS; return -1; }
int _lseek(int fd, int ptr, int dir)    { (void)fd; (void)ptr; (void)dir; errno = ENOSYS; return -1; }
int _open(const char *n, int f, int m)  { (void)n; (void)f; (void)m; errno = ENOSYS; return -1; }

/**
 * @brief Tell newlib that stdout/stderr are "character devices", not files.
 *        This makes functions like isatty() and stdio buffering behave better.
 */
int _isatty(int fd)
{
    return (fd == STDOUT_FILENO || fd == STDERR_FILENO);
}

/**
 * @brief Provide file status for character streams (stdout/stderr).
 *        Required by newlib; we set the mode to "character device".
 */
int _fstat(int fd, struct stat *st)
{
    (void)fd;
    if (!st) { errno = EINVAL; return -1; }
    st->st_mode = S_IFCHR;
    return 0;
}
