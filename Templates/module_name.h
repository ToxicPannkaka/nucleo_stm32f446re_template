/**
 * @file    module_name.h
 * @author  Your Name
 * @date    YYYY-MM-DD
 * @brief   Implementation of module_name.h
 */
#ifndef MODULE_NAME_H
#define MODULE_NAME_H

#include <stdint.h>
#include <stdbool.h>

// Constants
#define MODULE_NAME_MAX_VALUE  100

// Status codes
typedef enum {
    MODULE_STATUS_OK = 0,
    MODULE_STATUS_ERROR
} module_status_t;

// Public functions
module_status_t Module_Init(void);
module_status_t Module_DoSomething(int input);

#endif // MODULE_NAME_H
