# Microprocessors-Class-Project
Drivers for STM32F407 board to communicate with buttons, leds, and 7-segment display

STM32F407 with P24(top board) and Peripheral Setups
*****************************************************************************
PLEASE REFER TO display_led_switch_functions.c FOR WELL COMMENTED SOURCE CODE
*****************************************************************************

Initial Setup
- Download and install the STLink software for the STM32 series		
	[http://www.st.com/web/en/catalog/tools/PF258168]
- Run the MakeBlinky.bat by double clicking in the ENEE440_Final_Project directory. 
	[The compiler will generate a Blinky.hex to be programmed on the board]
- First Perform a Full Chip Erase using the STLink Software
- Now use the STLink utility to Program and Verify the USBvcp13.hex file to the board
- Now use the STLink utility to Program and Verify the Blinky.hex file to the board
- You should now see 00:00 shown on the 7-segment display (Refer to pg6)
- Calibrate the time using the rotary encoder and BUTTONS 1-4 on the left side of the board
- Press BUTTON 13 (the rightmost button under the rotary encoder) to enter the Home Menu


User Available Functions in display_led_switch_functions.c				

Display-LED-Switch-Functions	    							 			 
The following functions are available for the communication between the STM32F4 and P24 board (eagle schematic) so that available GPIOs are used to enable/disable user level interfaces on the hardware. 

Instructions are included giving a brief explanation of how they should be used in main.						 

These function calls are linked with the object code in display_led_switch.asm drivers to communicate the correct cathode/anode pattern to the P24 U_CA/U_AN Flip-Flops using GPIOS A,B and C on the STM32F4 board The GPIO initializations are in a separate file called P24v04r16A_GPIOinit.asm and linked in the makefile		

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
7-SEGMENT DISPLAY FUNCTIONS							 
	---->	clear all cathode/anode patterns 	
	---->	use dig_display_setup(dig) to set up digit to display or all_digits_ON() for all digits (anode pattern)	 
	---->	use display_Num(num) or seg7_pattern(num,digit) to write a number to display (cathode pattern)								
LEDs 1-6 FUNCTIONS									 
	---->	clear all cathode/anode patterns 				 
	---->	use init_color(color) initialize a color for the LEDs(anode pattern)	 
	---->	use led_ON(led_num) to turn on on led	(cathode pattern)	 
  
BUTTONS 1-13 FUNCTIONS								 	 
  	---->	clear all cathode/anode patterns 			 
	---->	use enable_button(button) to set up a button	 (cathode pattern)    
	---->	use read_button() to return the button that is pressed  					 
ROTARY ENCODER FUNCTIONS								 
	---->	clear all cathode/anode patterns 											 
	---->	use rot_Enc_setup(0) to set up rotary encoder (anode pattern)    
	---->	use read_rot_EncA() and read_rot_EncB() to read encoder values A and B 	
	---->	use process_rot_encoder() to process any right or left turns 				 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Contact GitHub API Training Shop Blog About
© 2016 GitHub, Inc. Terms Privacy Security Status Help
