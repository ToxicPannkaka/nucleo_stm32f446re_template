/* =======================================================================
 *  STM32F446RE Linker Script
 *  Author: Linus Lindberg 
 *  MCU: STM32F446RE (Cortex-M4)
 *
 *  Description: 
 *      This linker script defines the memory layout and section mapping
 *      for STM32F446RE-based applications. It separates FLASH and RAM 
 *      regions, defines stack and heap boundaries, and provides symbols
 *      used by the C runtime initialization code.
 *
 *
 *
 * ======================================================================= */

/* -----------------------------------------------------------------------
 *                              MEMORY LAYOUT
 * -----------------------------------------------------------------------
 *  The STM32F446RE provides: 
 *  - 512KB of FLASH memory at 0x08000000
 *  - 128KB of SRAM at 0x20000000
 * ----------------------------------------------------------------------- */
MEMORY
{
    FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 512k /* Program memory (code, const) */
    RAM (xrw)  : ORIGIN = 0x20000000, LENGTH = 128k /* SRAM (data, stack, heap) */
}

/* -----------------------------------------------------------------------
 *                          ENTRY POINT
 * -----------------------------------------------------------------------
 *  The vector table's first entry is the initial stack pointer,
 *  and the second is the Reset_Handler, which serves as the entry point
 * ----------------------------------------------------------------------- */

ENTRY(Reset_Handler)

/* -----------------------------------------------------------------------
 *                      STACK & HEAP CONFIGURATION
 * ----------------------------------------------------------------------- 
 *  These symbols define default stack and heap sizes. 
 *  They can be overridden by user if needed.
 * ----------------------------------------------------------------------- */
_estack         = ORIGIN(RAM) + LENGTH(RAM) /* Top of stack */   
_Min_Heap_Size  = 0x200; /* 512 byte heap */
_Min_Stack_Size = 0x400; /* 1KB stack */

/* ------------------------------------------------------------------------
 *                              SECTIONS
 * ------------------------------------------------------------------------ 
 * Defines how input sections from object files are mapped into memory.
 * Each section aligns to 4 bytes to maintain ARM word boundaries.
 * ------------------------------------------------------------------------ */
SECTIONS
{
    /* =======================================================================
     *  VECTOR TABLE & CODE SECTION (.text)
     * ======================================================================= */
    .text :
    {   
        . = ALIGN(4)

        /* Keep the vector table (interrupts, Reset_Handler, etc. */
        KEEP(*(.isr_vector))
        
        /* Main code and functions */
        *(.text*)

        /* Constant data (e.g. const arrays, lookup tables) */
        *(.rodata*)

        . = ALIGN(4)
        _etext = .; /* Marks end of code section */
    } > FLASH
    
    /* =======================================================================
     *  INITIALIZED DATA (.data)
     * =======================================================================
     *  Variables with initial values are stored in Flash,
     *  then copied into RAM by startup code.
     * ======================================================================= */
    .data :
    {
        . = ALIGN(4)
        _sdata = .; /* Start of .data in RAM */

        *(.data*)
    
        . = ALIGN(4)
        _edata = .; /* End of .data in RAM */
    } > RAM AT > FLASH
    
    /* Symbol used by startup code for Flash-to-RAM copy */
    _sidata = LOADADDR(.data);

    /* ========================================================================
     *  ZERO-INITIALIZED DATA (.bss)
     * ========================================================================
     *  Variables with no initial values are placed here. 
     *  The startup code zeroes this region at runtime. 
     * ======================================================================== */
    .bss :
    {   
        . = ALIGN(4) 
        _sbss = .; /* Start of .bss in RAM */


        *(.bss*)
        *(COMMON) /* For uninitialized globals */
        
        . = ALIGN(4);
        _ebss = .; /* End of .bss in RAM */
    } > RAM

    /* ========================================================================
     *  HEAP & STACK 
     * ======================================================================== 
     * The stack grows downward from __stack_end__.
     * The heap grows upward from __heap_start__.
     * Ensure they do not overlap at runtime. 
     * ======================================================================== */

    ._user_heap_stack : 
    {
        . = ALIGN(8);
        PROVIDE(__heap_start__ = .);
        . = . + _Min_Heap_Size;
        PROVIDE(__heap_end__ = .);

        . = ALIGN(8);
        PROVIDE(__stack_start__ = .);
        . = . + _Min_Stack_Size;
        PROVIDE(__stack_end__ = .);

        PROVIDE(__StackLimit = __stack_start__);
        PROVIDE(__StackTop   = __stack_end__);
        PROVIDE(__HeapBase   = __heap_start__);
        PROVIDE(__HeapLimit  = __heap_end__);


    } > RAM

    /* ========================================================================
     *  DISCARD UNUSED SECTIONS 
     * ======================================================================== */
    /DISCARD/ :
    {
        *(.note*)
        *(.comment*)
        *(.eh_frame*)
    }
}

/* ========================================================================
 *                              END OF FILE
 * ======================================================================== */
