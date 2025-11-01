/* ======================================================================== 
 *  STM32F446RE RAM Linker Script (Improved)
 *  Runs everything from SRAM at 0x20000000
 *  Intended for debugging / RAM-based testing (contents lost on reset)
 * ======================================================================== */

MEMORY
{
    RAM (xrw) : ORIGIN = 0x20000000, LENGTH = 128K
}

/* ------------------------------------------------------------------------
 * Entry & core symbols
 * ------------------------------------------------------------------------ */
ENTRY(Reset_Handler)

/* Top of RAM: initial stack pointer value from vector table */
_estack         = ORIGIN(RAM) + LENGTH(RAM);

/* Tweakable minimums (link-time reservations) */
_Min_Heap_Size  = 0x200; /* 512 B  */
_Min_Stack_Size = 0x400; /* 1 KB   */

/* ------------------------------------------------------------------------ 
 * SECTIONS 
 * ------------------------------------------------------------------------ */
SECTIONS
{
    /* --------------------------------------------------------------------
     * Code, vector table & const data in RAM
     * -------------------------------------------------------------------- */
    .text :
    {
        . = ALIGN(4);

        /* Vector table at the start of .text in RAM */
        __Vectors = .;
        KEEP(*(.isr_vector))
        __Vectors_End = .;

        /* Regular code and consts */
        *(.text*)               /* Program code */
        *(.rodata*)             /* Constant data */

        /* C++/unwind support (harmless if unused) */
        *(.ARM.extab* .gnu.linkonce.armextab.*)
        *(.ARM.exidx* .gnu.linkonce.armexidx.*)

        /* init/fini, constructors/destructors (C/C++) */
        KEEP(*(.init))
        KEEP(*(.fini))
        KEEP(*(.ctors*))
        KEEP(*(.dtors*))

        *(.glue_7) *(.glue_7t)  /* ARM/Thumb veneer glue */

        . = ALIGN(4);
        _etext = .;
    } > RAM

    /* --------------------------------------------------------------------
     * Initialized data in RAM (no copy from Flash)
     * -------------------------------------------------------------------- */
    .data :
    {
        . = ALIGN(4);
        _sdata = .;
        *(.data*)
        . = ALIGN(4);
        _edata = .;
    } > RAM

    /* For startup code compatibility: pretend LMA==VMA */
    _sidata = _sdata;

    /* --------------------------------------------------------------------
     * Zero-initialized data
     * -------------------------------------------------------------------- */
    .bss (NOLOAD) :
    {
        . = ALIGN(4);
        _sbss = .;
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;
    } > RAM

    /* --------------------------------------------------------------------
     * Optional: .noinit region (kept across soft-resets) 
     * -------------------------------------------------------------------- */
    .noinit (NOLOAD) :
    {
        . = ALIGN(4);
        _snoinit = .;
        *(.noinit*)
        . = ALIGN(4);
        _enoinit = .;
    } > RAM

    /* --------------------------------------------------------------------
     * Heap & stack model:
     *   - Heap grows up from end of bss/noinit
     *   - Stack grows down from top of RAM
     *   We compute symbols and assert they don't overlap.
     * -------------------------------------------------------------------- */
    .heap (NOLOAD) :
    {
        . = ALIGN(8);
        __HeapBase = .;
        . = . + _Min_Heap_Size;    /* reserve minimum heap */
        __HeapLimit = .;
    } > RAM

    /* Compute stack markers from top-of-RAM (no bytes are actually emitted) */
    __StackTop   = ORIGIN(RAM) + LENGTH(RAM);
    __StackLimit = __StackTop - _Min_Stack_Size;

    /* Backward-compat symbols */
    PROVIDE(__stack_start__ = __StackLimit);
    PROVIDE(__stack_end__   = __StackTop);

    /* ARM/GDB compatibility */
    PROVIDE(__StackLimit = __StackLimit);
    PROVIDE(__StackTop   = __StackTop);
    PROVIDE(__HeapBase   = __HeapBase);
    PROVIDE(__HeapLimit  = __HeapLimit);

    /* --------------------------------------------------------------------
     * Discard unneeded sections
     * -------------------------------------------------------------------- */
    /DISCARD/ :
    {
        *(.note*)
        *(.comment*)
        *(.eh_frame*)
    }
}

/* ------------------------------------------------------------------------
 * Build-time safety: ensure heap ends before stack begins
 * ------------------------------------------------------------------------ */
ASSERT(__HeapLimit <= __StackLimit, "RAM overflow: heap and stack overlap");

/* Aliaser som vissa standard-impl för _sbrk förväntar sig */
PROVIDE(end        = __HeapBase);
PROVIDE(_end       = __HeapBase);
PROVIDE(__bss_start__ = _sbss);
PROVIDE(__bss_end__   = _ebss);


/* ========================================================================
 * End of file
 * ======================================================================== */

