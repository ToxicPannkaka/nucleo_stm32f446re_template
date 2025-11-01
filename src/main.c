
#include <stdio.h>
#include "usart2_init.h"
int main(void){
    usart2_init(115200);
    int hasPrinted = 0;
    while(1){
        if(!hasPrinted) {
            printf("I am alive!\n");
            fflush(stdout);
            hasPrinted = 1;
        }
    }
}