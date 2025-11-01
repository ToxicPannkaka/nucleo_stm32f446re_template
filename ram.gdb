set pagination off
target extended-remote :4242
monitor reset halt
load
set $sp = _estack
set $pc = Reset_Handler
set {unsigned int}0xE000ED08 = (unsigned int)&__Vectors
tbreak main
continue
