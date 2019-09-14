#include <stm32f401xe.h>

void sleep() {
    for (int i = 0; i < 1000000; i++) __asm__("nop");
}

int main() {
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;
    GPIOA->MODER = (GPIOA->MODER & ~GPIO_MODER_MODE5) | GPIO_MODER_MODE5_0;

    while (1) {
        GPIOA->BSRR = GPIO_BSRR_BS5;
        sleep();
        GPIOA->BSRR = GPIO_BSRR_BR5;
        sleep();
    }
}
