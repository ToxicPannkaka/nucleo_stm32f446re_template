/**
 * @file    module_name.h
 * @author  Your Name
 * @brief   Header file for module_name module
 *
 * This file contains the interface for the module_name module.
 * All public functions, constants, types, and macros are defined here.
 */

#ifndef MODULE_NAME_H
#define MODULE_NAME_H

/* ======== INCLUDES ========= */
#include <stdint.h>
#include <stdbool.h>

/* ======== CONSTANTS AND DEFINES ========= */

/**
 * @brief Example macro definition
 */
#define MODULE_NAME_EXAMPLE_MACRO  42

/* ========= TYPES, ENUMS, ETC ========= */

/**
 * @brief Example enumeration
 */
typedef enum {
    MODULE_NAME_OK = 0,
    MODULE_NAME_ERROR = 1
} module_name_status_t;

/**
 * @brief Example struct
 */
typedef struct {
    uint8_t field1;
    uint16_t field2;
} module_name_data_t;

/* ========= FUNCTIONS ========== */

/**
 * @brief Initializes the module
 *
 * This function initializes the module and sets it up for use.
 *
 * @param none
 * @return Status of the initialization
 */
module_name_status_t module_name_init(void);

/**
 * @brief Sets a value in the module
 *
 * @param data Pointer to the data to set
 * @return Status of the operation
 */
module_name_status_t module_name_set(const module_name_data_t *data);

/**
 * @brief Gets a value from the module
 *
 * @param data Pointer to a structure where the data will be stored
 * @return Status of the operation
 */
module_name_status_t module_name_get(module_name_data_t *data);

#endif // MODULE_NAME_H
