///////////////////////		ENEE440 - Microprocessors - Spring 2016 - Emanuelle Crespi			/////////////////////////////////
//	-----------------------------------------------------------------------------------------------------------------    
//											Display-LED-Switch-Functions	    							 			 
//	-----------------------------------------------------------------------------------------------------------------	
//		The following functions are available for the communication between the STM32F4 and P24 board (eagle schematic) 
//		so that avaible GPIOs are used to enable/disable user level interfaces on the hardware. 						 
//																														 // 
//		Instructions are included giving a brief explanation of how they should be used in main.						 
//		These function calls are linked with the object code in display_led_switch.asm drivers to ommunicate the correct
//		cathode/anode pattern to the P24 U_CA/U_AN Flip-Flops using GPIOS A,B and C on the STM32F4 board				 
//		The GPIO initializations are in a seperate file called P24v04r16A_GPIOinit.asm and linked in the makefile		
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <stdint.h>
#define ONE_SEC 0x000FFFFF
#define GRN		0x1
#define RED 	0x2
#define ORG 	0x3

//Systick will decrement TimingDelay
extern volatile uint32_t TimingDelay;

void Wait( unsigned int time ){	
	//TimingDelay = time;
	//while( TimingDelay != 0 );
	unsigned int count = 0;
	while( count++ < time );
}

/*
	Clear all the pins corresponding to the U_CA latch cathodes 
	(writes 1 to the cathode latches)
*/
void all_Cathodes_Off(){
	disable_Caths();
	turn_off_Cathodes();
	clock_Caths();
	enable_Caths();
}

/*
	Clear all the pins corresponding to the U_AN anodes
	(writes a 1 to each anode latch)
*/
void all_Anodes_Off(){
	disable_Anods();
	turn_off_Anodes();
	clock_Anods();
	enable_Anods();
}

/*
	Turns everything off by clearing all of the cathode and anode patterns
*/
void clear_caths_and_anodes(){
	all_Anodes_Off( );
	all_Cathodes_Off( );
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	-----------------------------------------------------------------------------------------------------------------    
//											7-SEGMENT DISPLAY FUNCTIONS									 				 
//	-----------------------------------------------------------------------------------------------------------------	 
//	---->	clear all cathode/anode patterns 										 						 			 
//	---->	use dig_display_setup(dig) to set up digit to display or all_digits_ON() for all digits		(anode pattern)	 
//	---->	use display_Num(num) or seg7_pattern(num,digit) to write a number to display	(cathode pattern)		   	 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*  display_Num( unsigned int num )
	Writes the necessary cathode pattern (A-G) for num on the seven segment display
	
	Assumes a call to dig_display_setup( unsigned int dig ) or all_digits_ON() has been made
	so that the pattern will be visible on the display
*/
void display_Num( uint32_t num ){
	disable_Caths( );
	
	switch ( num ){
		case 0:
		display_0( );
		break;
		
		case 1:
		display_1( );
		break;
		
		case 2:
		display_2( );
		break;
		
		case 3:
		display_3( );
		break;
		
		case 4:
		display_4( );
		break;
		
		case 5:
		display_5( );
		break;
		
		case 6:
		display_6( );
		break;
		
		case 7:
		display_7( );
		break;
		
		case 8:
		display_8( );
		break;
		
		case 9:
		display_9( );
		break;
		
		case 10:
		display_A( );
		break;
		
		case 11:
		display_b( );
		break;
		
		case 12:
		display_C( );
		break;
		
		case 13:
		display_d( );
		break;
		
		case 14:
		display_E( );
		break;
		
		case 15:
		display_F( );
		break;
	}
	
	clock_Caths( );
	enable_Caths( );
}

/*	clear_segment_Caths()
	Writes the necessary cathode pattern to clear segments A-G on the display
*/
void clear_segment_Caths(){
	disable_Caths( );
	clear_digit( );
	clock_Caths( );
	enable_Caths( );
}

/*	turn_off_7segs()
	Helper function to clear the digit and colon anodes on the 7seg display
*/
void turn_off_7segs(){
	disable_Anods();
	colon_undo();
	dig_1_undo();
	dig_2_undo();
	dig_3_undo();
	dig_4_undo();
	clock_Anods();
	enable_Anods();
}

/*	dig_display_setup( unsigned int dig )
	Sets up the anode for a digit to be enabled on the 7seg display
*/
void dig_display_setup( uint32_t dig ){
	disable_Anods( );
	
	switch ( dig ){
		case 1:
		dig_1_setup( );	
		break;
		
		case 2:
		dig_2_setup( );
		break;
		
		case 3:
		dig_3_setup( );
		break;

		case 4:
		dig_4_setup( );
		break;
	}
	
	clock_Anods( );
	enable_Anods( );
}

/*	all_digits_ON()
	Sets up the anodes for all of the digits to display on the 7-seg
*/
void all_digits_ON(){
	unsigned int i;
	for( i = 1; i <= 4; i++){
		dig_display_setup(i);
	}
}

/*	seg7_pattern(unsigned int num, int digit)
	Sets up a cathode pattern for a particular digit/anode on the 7-seg display 
*/
void seg7_pattern(uint32_t num, uint32_t digit){
	dig_display_setup( digit );
	display_Num( num );
}

/*
	Splits 4 digit number into single digits
	returns array with each digit
*/ 
uint32_t split_digit( uint32_t num, uint32_t digit) 
{
	int i;
	for(i = 1; i < digit; i++)	
	{
		num /= 10;
	}
	return num % 10;
}




///////////////////////////////////////////////////////////////////////////////////////////////
//	--------------------------------------------------------------------------------------   
//										LEDs 1-6 FUNCTIONS									 
//	--------------------------------------------------------------------------------------   
//		---->	clear all cathode/anode patterns 											 
//		---->	use init_color(color) initialize a color for the LED/s	  (anode pattern)	 
//		---->	use led_ON(led_num) to turn on on led					(cathode pattern)	 
///////////////////////////////////////////////////////////////////////////////////////////////

/*	init_color( unsigned int color )
	Sets up the anodes for a particular color to show on LEDs 1-6
	(writes a 0 to the necessary pin/latch)
*/
void init_color( uint32_t color ){
	disable_Anods();
	switch (color){
		case GRN:
		init_GREEN();
		clock_Anods();
		enable_Anods();
		undo_GREEN();
		break;
		
		case RED:
		init_RED();
		clock_Anods();
		enable_Anods();
		undo_RED();
		break;
		
		case ORG:
		init_GREEN();
		clock_Anods();
		init_RED();
		clock_Anods();
		enable_Anods();
		undo_GREEN();
		undo_RED();
		break;
	}	
	
	
}

/*	undo_color( unsigned int color)
	Unsets an anode for the color on LEDs 1-6
	(writes a 1 to the necessary pin/latch)
*/
void undo_color( uint32_t color ){
	disable_Anods();
	switch (color){
		case GRN:
		undo_GREEN();
		break;
		
		case RED:
		undo_RED();
		break;
		
		case ORG:
		undo_GREEN();
		undo_RED();
		break;
	}	
	
	clock_Anods();
	enable_Anods();
}

/*	led_ON(unsigned int led_num)
	Writes a 0 to the pin/latch to turn on LED --> led_num
	Assumes a call to init_color has been made beforehand
*/
void led_ON( uint32_t led_num ){
	switch (led_num){
		case 1:
		led_1_setup(0);
		break;
		
		case 2:
		led_2_setup(0);
		break;
		
		case 3:
		led_3_setup(0);
		break;
		
		case 4:
		led_4_setup(0);
		break;
		
		case 5:
		led_5_setup(0);
		break;
		
		case 6:
		led_6_setup(0);
		break;
	}
}

/*	led_OFF(unsigned int led_num)
	Writes a 1 to the pin/latch to turn off an LED --> led_num
	Assumes a call to init_color has been made beforehand
*/
void led_OFF( uint32_t led_num ){	
	switch (led_num){
		case 1:
		led_1_setup(1);
		break;
		
		case 2:
		led_2_setup(1);
		break;
		
		case 3:
		led_3_setup(1);
		break;
		
		case 4:
		led_4_setup(1);
		break;
		
		case 5:
		led_5_setup(1);
		break;
		
		case 6:
		led_6_setup(1);
		break;
	}
}

/*	all_LEDs_ON(unsigned int color)
	Writes a 0 to the pins/latches to turn on all LEDs 1-6
	Uses the color to initialize the anodes before writing to the cathodes
*/
void all_LEDs_ON( uint32_t color ){
	unsigned int i;
	init_color( color );
	for(i = 1; i <= 6; i++){
		led_ON( i );
	}
}

/*	all_LEDs_OFF(unsigned int color)
	Writes a 1 to the pins/latches to to turn off all LEDs 1-6
	Uses color to undo the anode that was set along with the cathodes 
*/
void all_LEDs_OFF( uint32_t color ){
	unsigned int i;
	undo_color( color );
	for(i = 1; i <= 6; i++){
		led_OFF( i );
	}
}

void LED_color_ON( uint32_t led, uint8_t color){
	init_color( color );
	led_ON( led );
}

/*	led_pattern()
	Simple LED pattern to set on the board
*/
void led_pattern(){
	unsigned int color = GRN;
	all_LEDs_ON(color);
}





///////////////////////////////////////////////////////////////////////////////////////////////
//	--------------------------------------------------------------------------------------   
//									BUTTONS 1-13 FUNCTIONS								 	 
//	--------------------------------------------------------------------------------------   
//		---->	clear all cathode/anode patterns 											 
//		---->	use enable_button(button) to set up a button	 		(cathode pattern)    
//		---->	use read_button() to return the button that is preassed  					 
///////////////////////////////////////////////////////////////////////////////////////////////

/*	odd_button_pressed( )
	Returns true if PA15 is 0 (for the odd buttons)
*/
uint32_t odd_button_pressed( ){
	return ( read_PA15( ) == 0 );
}

/*	even_button_pressed( )
	Returns true if PC8 is 0 (for the even buttons)
*/
uint32_t even_button_pressed( ){
	return ( read_PC8( ) == 0 );
}

/*	enable_button( unsigned int button )
	Enables a button column 1-2, 3-4, etc.. by writing a 0 to the necessary latch/pin (cathode)
*/
void enable_button( uint32_t button ){
	if (button == 1 || button == 2){
		setup_1_2(0);
	}else if( button == 3 || button == 4){
		setup_3_4(0);
	}else if( button == 5 || button == 6){
		setup_5_6(0);
	}else if( button == 7 || button == 8){
		setup_7_8(0);
	}else if( button == 9 || button == 10){
		setup_9_10(0);
	}else if( button == 11 || button == 12 ){
		setup_11_12(0);
	}else if( button == 13 ){
		setup_13(0);
	}else{
		return;
	}
}

/*	disable_button( unsigned int button )
	Disables a button column 1-2, 3-4, etc.. by writing a 1 to the necessary latch/pin (cathode)
*/
void disable_button(uint32_t button){
	if (button == 1 || button == 2){
		setup_1_2(1);
	}else if( button == 3 || button == 4){
		setup_3_4(1);
	}else if( button == 5 || button == 6){
		setup_5_6(1);
	}else if( button == 7 || button == 8){
		setup_7_8(1);
	}else if( button == 9 || button == 10){
		setup_9_10(1);
	}else if( button == 11 || button == 12 ){
		setup_11_12(1);
	}else if( button == 13 ){
		setup_13(1);
	}else{
		return;
	}
}

/*	read_button()
	Returns the button that has been pressed
	Button has to be enabled and pressed to be true
*/
uint32_t read_button(){
	if ( odd_button_pressed() ){
		if( read_1_2() == 0 ){
			return 1;
		}else if( read_3_4() == 0 ){
			return 3;
		}else if( read_5_6() == 0 ){
			return 5;
		}else if( read_7_8() == 0 ){
			return 7;
		}else if( read_9_10() == 0 ){
			return 9;
		}else if( read_11_12() == 0 ){
			return 11;
		}else if( read_13() == 0 ){
			return 13;
		}else{
			return 0;
		}
	}else if ( even_button_pressed() ){
		if( read_1_2() == 0 ){
			return 2;
		}else if( read_3_4() == 0 ){
			return 4;
		}else if( read_5_6() == 0 ){
			return 6;
		}else if( read_7_8() == 0 ){
			return 8;
		}else if( read_9_10() == 0 ){
			return 10;
		}else if( read_11_12() == 0 ){
			return 12;
		}else{
			return 0;
		}
	}else{
		return 0;
	}
}

//DBG_func( unsigned int num)
//For debugging purposes
void DBG_func( unsigned int num ){
	//DBG Routine
	clear_caths_and_anodes();
	all_digits_ON();					
	display_Num( num );
	Wait(ONE_SEC/2);
}

/*	button_finder()
	Scans through each button column to see whether it has been pressed
	returns the button # that has beeen pressed
	returns 0 if no button has been pressed
*/
uint32_t button_finder(){
	unsigned int i;
	for ( i = 1; i <= 13; i++ ){
		enable_button( i );
		
		if( read_button() == i ){
			//DBG_func( (unsigned int) i );
			return i;
		}
		
		disable_button(i);
	}
	
	return 0;
}

/*
	Determines if a button has been pressed. 
	returns that btn # if a btn press is confirmed
 */
int btn_state_machine()
{
	static int btn_state = 0;	//state for btn st machine
	static unsigned int btn = 0;
	static unsigned int confirmed_btn = 0;
	static int wait = 0;		//This is the filter time for debouncing of the switches

	//enable_button(count);
	switch(btn_state)
	{
		//Read first press
		case 0:
			confirmed_btn = 0;
			btn = 0;
			btn = button_finder();
			//DBG_func( (unsigned int) btn);
			if(btn != 0)
				btn_state = 1;
			break;

		//filter debouncing
		case 1:
			if(button_finder() != btn)
			{
				btn_state = 0;
				btn = 0;
			}
			//wait # cycles
			else
			{
				if(wait == 200)
				{
					btn_state = 2;
					wait = 0;
				}
				else
				{
					wait ++;	
				}
			}
			break;

		case 2:
			//confirm press
			if(button_finder() == btn)
			{
				confirmed_btn = btn;
			}

			btn_state = 0;
			break;
	}
	//if ( confirmed_btn != 0 ) DBG_func( (unsigned int) btn);
	return confirmed_btn;
}



///////////////////////////////////////////////////////////////////////////////////////////////
//	--------------------------------------------------------------------------------------   
//									ROTARY ENCODER FUNCTIONS								 
//	--------------------------------------------------------------------------------------   
//		---->	clear all cathode/anode patterns 											 
//		---->	use rot_Enc_setup(0) to set up rotary encoder 	 		  (anode pattern)    
//		---->	use read_rot_EncA() and read_rot_EncB() to read encoder values A and B 	 	 
//		---->	use process_rot_encoder() to process any right or left turns 				 
///////////////////////////////////////////////////////////////////////////////////////////////

/*	rot_Enc_setup(unsigned int set)
	Enables the rotary encoder when a 0 is passed as an argument 
	Disables the rotary encoder taking any other # as an argument
	(writes 0 or 1 to enable/diable the anode as needed)
*/	
void rot_Enc_setup( uint32_t set ){
	disable_Anods();
	if ( !set ){
		enable_rotEnc();
	}else{
		disable_rotEnc();
	}
	clock_Anods();
	enable_Anods();
}

/*	read_rot_EncA()
	Returns encoder's A state
*/
uint32_t read_rot_EncA(){
	return read_PC8();
}

/*	read_rot_EncB()
	Returns encoder's B state
*/
uint32_t read_rot_EncB(){
	return read_PA15();
}

/*	encoder_state()
	Consider the encoder message as a 2-bit binary number (AB) + 1
*/
static unsigned int encoder_state(){
	return ( ( read_rot_EncA() << 1 ) | read_rot_EncB() ) + 1;
}

/*	get_direction( unsigned int prev, unsigned int curr )
	Rotary encoder state machine - states are considered 1-4
	returns 1 to indicate a right turn
	returns -1 to indicate a left turn
	returns 0 otherwise
*/
static signed int get_direction( unsigned int prev, unsigned int curr ){
	signed int direction;
	switch ( curr ){
			case 1:
				if ( prev == 3 ){
					direction = -1;
				}else if ( prev == 2 ){
					direction = 1;
				}else{
					direction = 0;
				}
				break;
			
			case 2:
				if ( prev ==  1 ){
					direction = -1;
				}else if ( prev == 4 ){
					direction = 1;
				}else{
					direction = 0;
				}
				break;
				
			case 3:
				if ( prev == 4 ){
					direction = -1;
				}else if ( prev == 1 ){
					direction = 1;
				}else{
					direction = 0;
				}
				break;
				
			case 4:
				if ( prev == 2 ){
					direction = -1;
				}else if ( prev == 3 ){
					direction = 1;
				}else{
					direction = 0;
				}
				break;
		}
		
		return direction;
}

/*	process_rot_encoder( )
	Returns 0 until a first and next state have been set then
	returns the direction processed by get_direction(first, next)
*/
signed int process_rot_encoder( ){
	static unsigned int first = 0, next = 0; 
	signed int direction;
	
	if( !first ){
		first = encoder_state();
		return 0;
	}
	
	if( !next ){
		next = encoder_state();
		return 0;
	}
	
	direction = get_direction( first, next );
	first = 0;
	next = 0;
	
	return direction;
}

