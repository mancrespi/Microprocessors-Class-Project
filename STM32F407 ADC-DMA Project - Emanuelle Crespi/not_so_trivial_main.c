//ENEE440 Final Project
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h> //or not?

#define ONE_SEC 0x000FFFFF
#define ONE_MSEC ONE_SEC/1024
#define GRN		0x1
#define RED 	0x2
#define ORG 	0x3

// --- function prototypes
void RTC_24hr_config(void); // resets entire RCC backup domain
void RTC_get_BCD_24hour_time( uint8_t *HRS, uint8_t *MIN, uint8_t *SEC); 	//9. read RTC time (BCD) 
void RTC_get_BCD_date( uint8_t *MO, uint8_t *DAY, uint8_t *YR);				//10. read RTC date (BCD)
void setTimeandDate(uint32_t time_in_BCD, uint32_t date_in_BCD);
uint32_t SysTick_Config(uint32_t ticks);
void TIM5_INT_init(void);
void TIM2_INT_init(void);
int btnsTimeUpdate(int Btn, int time, int *hrs, int *min);

//structs - variable declarations
struct VCPfunctions {
	void (*VCP_put_char)(uint8_t buf);
	void (*VCP_send_str)(uint8_t* buf);
	void (*VCP_send_buffer)(uint8_t* buf, int len);
	int (*VCP_get_char)(uint8_t *buf);
	int (*VCP_get_string)(uint8_t *buf); 
};

const struct VCPfunctions *VCPfn;	//struct pointer		

// --- global variables	
uint8_t RTC_HR;
uint8_t RTC_MIN;
uint8_t RTC_SEC;
uint8_t RTC_DAY;
uint8_t RTC_MO;
uint8_t RTC_YR;
uint32_t SystemCoreClock;
uint32_t color = RED;
uint32_t time = 0; 			//keep track of current time
uint32_t digit = 0;			//to display on 7seg
uint32_t btn = 0;				//for reading buttons
uint32_t num = 0;

uint8_t LED1_color = 0;
uint8_t LED2_color = 0;
uint8_t LED3_color = 0;
uint8_t LED4_color = 0;
uint8_t LED5_color = 0;
uint8_t LED6_color = 0;

uint32_t TIM2count;

uint8_t USB_VCP_ON = 0;
uint8_t theByte;				//for processing on VCP request
int rxDataFlag;					//to read return value on VCP function call


// --- global flags
uint8_t btn_read = 0;
uint8_t rotE_read = 0;
uint8_t led_disp = 0;
uint8_t SVC0 = 0;
uint8_t SVC1 = 0;
uint8_t SVC2 = 0;
uint8_t SVC3 = 0;
uint8_t SVC4 = 0;
uint8_t SVC5 = 0;
uint8_t SVC6 = 0;
uint8_t LED1 = 0;
uint8_t LED2 = 0;
uint8_t LED3 = 0;
uint8_t LED4 = 0;
uint8_t LED5 = 0;
uint8_t LED6 = 0;
uint8_t remote = 0;
uint8_t DANCE = 0;
uint8_t MAX = 7;
uint8_t ADC_ON;
uint8_t ADC_PREP;
uint8_t ADC_CAL;

delay(uint32_t wait){
	while( wait-- ){ ; }
}

int main (void) {
		uint32_t led_toggle = 1, led_cnt = 1;
		uint8_t *led_color, *led_num;
	
		// Some initializations for below 
		unsigned int num_display = 0;	//Number displayed on 7seg
		int hrs = 0, min = 0;			//for user clock calibration
		int state = 1;					//position in state machine 
		
		//Flags
		unsigned int setTime = 0;		//indicate when time has been set by user
		
		SystemCoreClock = 168000000;
		SystemCoreClockUpdate();                      // Get Core Clock Frequency   
		
		ST_P24SWITCH_init( ); 		//in P24v04r16A_GPIOinit -- initializes ST32F4 pins which read switches
		ST_P24DISPLAY_init( );		//in P24v04r16A_GPIOinit -- initialize ST32F4 output pins controlling P24 display pins
		clear_caths_and_anodes();
		
		//systick config and Systick_Handler is in STM32F4main01.c
		if (SysTick_Config( SystemCoreClock / 1000 ) ){ // SysTick 1 msec interrupts  
			clear_caths_and_anodes( );
			all_LEDs_ON(ORG);        // DBG/Capture error              
			while (1);
		}
		
		
		RTC_24hr_config();
		TIM5_INT_init();			//sets up TIM5 to interrupt every 2sec
		
		//Current Running Application (Buttons/7seg/RotE)
		while( !setTime ) {	//home MENU setup mode 
			clear_caths_and_anodes();
			//state machine
			switch(state)
			{
				case 0:
					btn = btn_state_machine();		
					//update time count to be displayed (setTime is set on button 13)
					//(Buttons: 1-2 toggle hrs, 3-4 toggle min)
					setTime = btnsTimeUpdate( btn, num_display, &hrs, &min);
					state = 1;
					break;
				case 1:
					colon_setup();
					if ( digit == 5 ) digit = 1;
					seg7_pattern( split_digit(num_display, 5 - digit), digit++ );
					state = 3;
					delay(2*ONE_MSEC);
					break;
				case 3:
					rot_Enc_setup( 0 );		//rotary encoder is 0 enabled
					signed int dir = process_rot_encoder();
					if( dir > 0 ) min += 1;
					if( dir < 0 ) min -= 1;
					state = 0;
					break;
			}
			
			num_display = clockInterfaceCalibrate(&hrs, &min);
			time = num_display;
		}
		
		time = num_display;		//time has been calibrated
		//TIM2 will initialize VCPfn for available function calls in high memory
		TIM2_INT_init();			//sets up TIM2 to periodically interrupt
		state = 0;
		btn = 0;
		
		//next task will include buttons/leds as task interface
		//and include communication via remote control via TIM2
		//can use Putty for remote control interface
		
		/****************************************************
		 * void (*VCP_put_char)(uint8_t buf);				
		 * void (*VCP_send_str)(uint8_t* buf);				
		 * void (*VCP_send_buffer)(uint8_t* buf, int len);	
		 * int (*VCP_get_char)(uint8_t *buf);				
		 * int (*VCP_get_string)(uint8_t *buf); 			
		 ****************************************************/
		
		//sets svc priority and initializes task table for context switching
		SvcHandlerInt_init(0x0F);
		
		//User Can now use buttons to enter different modes
		//Current Running Application (Buttons/7seg/LEDs)
		while(1){
			//state machine
			clear_caths_and_anodes();					//turns everything off
			switch(state)
			{
				case 0:					//Button scanner
					if (!ADC_CAL ){
						if ( !remote ) btn = btn_state_machine();
						if ( DANCE ) btn = ( read_TIM5_CNT() % 6 ) + 1;
					
						if ( btn == 1 ){
							if ( !LED1 ) LED1 ^= led_toggle;
							led_num = &LED1;
							led_color = &LED1_color;
						}else if ( btn == 2 ){
							if ( !LED2 ) LED2 ^= led_toggle;
							led_num = &LED2;
							led_color = &LED2_color;
						}else if ( btn == 3 ){
							if ( !LED3 ) LED3 ^= led_toggle;
							led_num = &LED3;
							led_color = &LED3_color;
						}else if ( btn == 4 ){
							if ( !LED4 ) LED4 ^= led_toggle;
							led_num = &LED4;
							led_color = &LED4_color;
						}else if ( btn == 5 ){
							if ( !LED5 ) LED5 ^= led_toggle;
							led_num = &LED5;
							led_color = &LED5_color;
						}else if ( btn == 6 ){
							if ( !LED6 ) LED6 ^= led_toggle;
							led_num = &LED6;
							led_color = &LED6_color;
						}else if ( btn == 7 ){
							SVC0 = 1;
						}else if ( btn == 8 ){
							SVC1 = 1;
						}else if ( btn == 9 ){
							SVC2 = 1;
						}else if ( btn == 10 ){
							SVC3 = 1;
						}else if ( btn == 11 ){
							SVC4 = 1;
						}else if ( btn == 12 ){
							SVC5 = 1;
						}else if ( btn == 13 ){
							SVC6 = 1;
						}
						
						if( btn  && btn <= 6 ){
							if ( DANCE ) {
								if ( *led_color == ORG ){
									*led_color = 0;
									*led_num ^= led_toggle;
								}else{
									*led_color += 1;
								}
							}
							else {
								if ( *led_color == RED ){
									*led_color = 0;
									*led_num ^= led_toggle;
								}else{
									*led_color += 1;
								}
							}
							btn = 0;
						}	
					}
					
					state = 1;
					break;
					
				case 1:					//Display Refresh
					if ( !ADC_CAL ){
						colon_setup();
						if ( digit == 5 ) digit = 1;	
						seg7_pattern( split_digit(time, 5 - digit), digit++ );									
						delay(5*ONE_MSEC);
					}
					state = 2;
					break;
					
				case 2:					//LED toggles
					if ( led_cnt == 7 ) led_cnt = 1;
						
					// LED state machine
					switch ( led_cnt ){
						case 1:
							if ( LED1 ) LED_color_ON( 1, LED1_color );
							break;
						case 2:
							if ( LED2 ) LED_color_ON( 2, LED2_color );
							break;
						case 3:
							if ( LED3 ) LED_color_ON( 3, LED3_color );
							break;
						case 4:
							if ( LED4 ) LED_color_ON( 4, LED4_color );
							break;
						case 5:
							if ( LED5 ) LED_color_ON( 5, LED5_color );
							break;
						case 6:
							if ( LED6 ) LED_color_ON( 6, LED6_color );
							break;
					} led_cnt++;
					
					if ( !ADC_CAL ){
						delay(4*ONE_MSEC);
					}else{
						delay(4*ONE_MSEC);
					}
					
					state = 0;
					break;
			}
			
			//Set up the current time to display by reading from RTC
			RTC_get_BCD_24hour_time(&RTC_HR,&RTC_MIN, &RTC_SEC); 	//see time in Keil debugger
			//RTC_get_BCD_date( &RTC_MO, &RTC_DAY, &RTC_YR);			  //see date in Keil debugger
			
			//converting from BCD to decimal
			time = (RTC_HR >> 4)*1000 + (RTC_HR & 0xF)*100 + (RTC_MIN >> 4)*10 + (RTC_MIN & 0xF);
		}
			
		return 0;
	}
