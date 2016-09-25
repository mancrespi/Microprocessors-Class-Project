REM  makeSTM32F4_P24IO_Blinky.bat wmh 2013-03-16 : compile STM32F4DISCOVERY/P24v04 LED demo and .asm opcode demo 
REM !!this version adds -L and -l switches which allow linking to Cortex M3 library functions
set path=.\;C:\yagarto\bin;
set VER=12



REM assemble with '-g' omitted where we want to hide things in the AXF
arm-none-eabi-as -g -mcpu=cortex-m4 -o drivers.o display_led_switch_drivers.asm
arm-none-eabi-as -g -mcpu=cortex-m4 -o TIM5.o TIM5_INT_barebones_init.asm
arm-none-eabi-as -g -mcpu=cortex-m4 -o TIM2.o TIM2_INT_barebones_init.asm
arm-none-eabi-as -g -mcpu=cortex-m4 -o aStartup.o SimpleStartSTM32F407_01.asm
arm-none-eabi-as -g -mcpu=cortex-m4 -o GPIOinit.o P24v04r16A_GPIOinit.asm
arm-none-eabi-as -g -mcpu=cortex-m4 -o RTCsetup.o RTCsetup_functions.asm 
arm-none-eabi-as -g -mcpu=cortex-m4 -o USB_VCP13.o USBvcp13_funcs.asm 
arm-none-eabi-as -g -mcpu=cortex-m4 -o task_switching_code.o PSV_SVC_task_switch_routines.asm 

REM compiling C
arm-none-eabi-gcc -I./  -c -mthumb -O0 -g -mcpu=cortex-m4 -save-temps not_so_trivial_main.c -o cMain.o
arm-none-eabi-gcc -I./  -c -mthumb -O0 -g -mcpu=cortex-m4 -save-temps STM32F4main01.c -o cMain2.o
arm-none-eabi-gcc -I./  -c -mthumb -O0 -g -mcpu=cortex-m4 -save-temps TIMx_PSV_SVC_Handlers.c -o cHandlers.o
arm-none-eabi-gcc -I./  -c -mthumb -O0 -g -mcpu=cortex-m4 -save-temps display_led_switch_functions.c -o dls_functions.o
arm-none-eabi-gcc -I./  -c -mthumb -O0 -g -mcpu=cortex-m4 -save-temps RTC_functions.c -o RTCfunctions.o
arm-none-eabi-gcc -I./  -c -mthumb -O0 -g -mcpu=cortex-m4 -save-temps helper_funcs_main.c -o helpers.o

REM linking
arm-none-eabi-gcc -nostartfiles -g -Wl,--no-gc-sections -Wl,-Map,Blinky.map -Wl,-T link_USBvcp_demo.ld -oBlinky.elf ./*.o -lgcc
 
REM hex file
arm-none-eabi-objcopy -O ihex Blinky.elf Blinky.hex

REM AXF file
copy Blinky.elf Blinky.AXF
pause

del *.i
del *.s

REM list file
arm-none-eabi-objdump -S  Blinky.axf >Blinky.lst
