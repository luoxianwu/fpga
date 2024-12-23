################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/bsp/driver/gpio/gpio.c 

OBJS += \
./src/bsp/driver/gpio/gpio.o 

C_DEPS += \
./src/bsp/driver/gpio/gpio.d 


# Each subdirectory must supply rules for building sources it contributes
src/bsp/driver/gpio/%.o: ../src/bsp/driver/gpio/%.c src/bsp/driver/gpio/subdir.mk
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv-none-embed-gcc -march=rv32imc -mabi=ilp32 -msmall-data-limit=8 -mno-save-restore -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections  -g3 -DLSCC_STDIO_UART_APB -I"C:\Users\x-luo\proj\hw4\SW\riscv_mc_helloworld/src" -I"C:\Users\x-luo\proj\hw4\SW\riscv_mc_helloworld\src\RTD" -I"C:\Users\x-luo\proj\hw4\SW\riscv_mc_helloworld\src\bsp\driver\spi_controller" -I"C:\Users\x-luo\proj\hw4\SW\riscv_mc_helloworld/src/bsp" -I"C:\Users\x-luo\proj\hw4\SW\riscv_mc_helloworld/src/bsp/driver" -I"C:\Users\x-luo\proj\hw4\SW\riscv_mc_helloworld/src/bsp/driver/gpio" -I"C:\Users\x-luo\proj\hw4\SW\riscv_mc_helloworld/src/bsp/driver/riscv_mc" -I"C:\Users\x-luo\proj\hw4\SW\riscv_mc_helloworld/src/bsp/driver/uart" -std=gnu11 --specs=picolibc.specs -DPICOLIBC_INTEGER_PRINTF_SCANF -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


