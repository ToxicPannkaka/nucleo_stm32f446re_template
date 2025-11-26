/**
 * @file    module_name.c
 * @author  Your Name
 * @date    YYYY-MM-DD
 * @brief   Implementation of module_name.h
 */
#include "module_name.h"
#include <stdio.h>   // only if you need printing

// Internal stuff
static int internal_counter = 0;

// Private helpers
static void Module_PrivateHelper(void);

// Public functions
module_status_t Module_Init(void) {
    internal_counter = 0;
    return MODULE_STATUS_OK;
}

module_status_t Module_DoSomething(int input) {
    if (input > MODULE_NAME_MAX_VALUE) {
        return MODULE_STATUS_ERROR;
    }

    internal_counter += input;
    Module_PrivateHelper();
    return MODULE_STATUS_OK;
}

// Private functions
static void Module_PrivateHelper(void) {
    printf("Counter = %d\n", internal_counter);
}
