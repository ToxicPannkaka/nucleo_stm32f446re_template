# STM32F4 Template Project

A clean, and flexible template for STM32F4 development using ARM GCC, Makefiles, and VS Code.  
This repository provides a ready-to-use project structure for quick prototyping, experimenting, or building larger embedded applications.

---

## Included Components

This template contains:

- **STM32F4xx Standard Peripheral Library**  
  Pre-included SPL sources and headers for convenient low-level access to MCU peripherals.

- **`.vscode/*.json` configuration files**  
  Tasks, IntelliSense, and debugging helpers for Visual Studio Code.

- **`Makefile`**  
  Simple build system for compiling, linking, and generating binaries. Easily customizable.

- **Linker scripts (RAM & FLASH)**  
  Both included. Default configuration builds for **RAM execution**.

- **Startup file**  
  Custom startup code supporting RAM-based execution.

- **Lelles Library**  
  My own collection of helper functions and modules for embedded development.

---

## Getting Started

### Requirements
- ARM GCC toolchain (`arm-none-eabi-gcc`)
- Make
- VS Code (optional)
- ST-Link or similar debugger (optional)

### Build
```bash
make
