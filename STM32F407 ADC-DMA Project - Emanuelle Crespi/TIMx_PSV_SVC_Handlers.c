#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

#define GRN		0x1
#define RED 	0x2
#define ORG 	0x3

// --- global variables
uint8_t RTC_HR;
uint8_t RTC_MIN;
uint8_t RTC_SEC;
uint8_t RTC_DAY;
uint8_t RTC_MO;
uint8_t RTC_YR;
uint32_t color;
uint32_t time;
uint32_t digit;
uint32_t btn;	
uint32_t num;

uint8_t LED1_color;
uint8_t LED2_color;
uint8_t LED3_color;
uint8_t LED4_color;
uint8_t LED5_color;
uint8_t LED6_color;

uint32_t TIM2count;

uint8_t nl = '\n';
uint8_t char_1 = '1';
uint8_t char_2 = '2';
uint8_t char_3 = '3';
uint8_t char_4 = '4';
uint8_t char_5 = '5';
uint8_t char_6 = '6';
uint8_t *ADC_on = "adcon";
uint8_t *ADC_off = "adcoff";
uint8_t *calibADC = "adccal";
uint8_t *dance_str = "dance";
uint8_t *DANCE_str = "DANCE";
uint8_t *bye = "bye";
uint8_t *exitcalibADC = "done";

// --- global flags
uint8_t USB_VCP_ON;
uint8_t btn_read; 
uint8_t rotE_read;
uint8_t led_disp;
uint8_t SVC0;
uint8_t SVC1;
uint8_t SVC2;
uint8_t SVC3;
uint8_t SVC4;
uint8_t SVC5;
uint8_t SVC6;
uint8_t LED1;
uint8_t LED2;
uint8_t LED3;
uint8_t LED4;
uint8_t LED5;
uint8_t LED6;
uint8_t ADC_ON = 0;
uint8_t ADC_PREP = 0;
uint8_t ADC_CAL = 0;
uint8_t MAX;
uint8_t task2_start = 0;
uint8_t wake_up_message = 0;
uint8_t remote;
uint8_t DANCE;
uint8_t RESET = 0;

//structs - variable declarations
struct VCPfunctions {
	void (*VCP_put_char)(uint8_t buf);
	void (*VCP_send_str)(uint8_t* buf);
	void (*VCP_send_buffer)(uint8_t* buf, int len);
	int (*VCP_get_char)(uint8_t *buf);
	int (*VCP_get_string)(uint8_t *buf); 
};

const struct VCPfunctions *VCPfn;	//struct pointer
uint8_t theByte;				//for processing on VCP request
uint8_t buf[25];						// for processing strings
uint8_t buf_chars = 0;  //
uint8_t char_cnt = 0;		//
int rxDataFlag;					//to read return value on VCP function call

void clear_buffer(uint32_t len){
		uint8_t clr = '\b';
		unsigned int i;
	
		for(i = 0; i < len; i++)
			VCPfn->VCP_put_char(clr);	
}

uint32_t strlen(uint8_t *word){
		uint8_t cnt;
		for( cnt = 0; word[cnt] && word[cnt] != '\0'; cnt++);
		return cnt;
}

uint8_t mystrcmp( uint8_t *word1, uint8_t *word2 ){
		uint8_t cnt, flag = 0;
	  uint32_t len = strlen( word1 );
		
		for( cnt = 0; cnt < len; cnt++){
				if ( word1[cnt] != word2[cnt] ){
						flag = 1; 
						break;
				}
		}
		
		return flag;
}

void TIM2_IRQHandler(void){
	static uint8_t LEDsave[6];
	static uint8_t LEDcolorsave[6];
	static int saved = 0;
	
	clear_TIM2_TIF_UIF( );			//clear TIM5 interrupt
	
	if ( !USB_VCP_ON ){
		//must first setup COM link via microUSB
		VCPfn = pVCP_init();
		USB_VCP_ON = 1;
	}
	
	rxDataFlag= VCPfn->VCP_get_char(&theByte);
	
	if ( rxDataFlag	){
		uint8_t *message;
		uint8_t len;
		
		if( !wake_up_message ){
			message = "--------------------------------Data Display--------------------------------\n\0";
			len = strlen(message);
			VCPfn->VCP_send_buffer( message, len );
			clear_buffer( len-1 );
			wake_up_message = 1;
			btn = 0;
		}else{
			VCPfn->VCP_put_char(theByte);
			
			//implement a button press on a character or enter some state on a word
			if ( !ADC_CAL && remote && theByte == char_1 ) {
				message = "--->BTN 1 PRESSED\n";
				VCPfn->VCP_send_buffer(message, 18);
				clear_buffer(18);
				if ( !LED1 ) LED1 ^= 1;
				btn = 1;		
			}
			else if ( !ADC_CAL && remote && theByte == char_2 ) {
				message = "--->BTN 2 PRESSED\n";
				VCPfn->VCP_send_buffer(message, 18);
				clear_buffer(18);
				if ( !LED2 ) LED2 ^= 1;
				btn = 2;
			}
			else if ( !ADC_CAL && remote && theByte == char_3 ){
				message = "--->BTN 3 PRESSED\n";
				VCPfn->VCP_send_buffer(message, 18);
				clear_buffer(18);
				if ( !LED3 ) LED3 ^= 1;
				btn = 3;
			}
			else if ( !ADC_CAL && remote && theByte == char_4 ){
				message = "--->BTN 4 PRESSED\n";
				VCPfn->VCP_send_buffer(message, 18);
				clear_buffer(18);
				if ( !LED4 ) LED4 ^= 1;
				btn = 4;
			}
			else if ( !ADC_CAL && remote && theByte == char_5 ){
				message = "--->BTN 5 PRESSED\n";
				VCPfn->VCP_send_buffer(message, 18);
				clear_buffer(18);
				if ( !LED5 ) LED5 ^= 1;
				btn = 5;
			}
			else if ( !ADC_CAL && remote && theByte == char_6 ){
				message = "--->BTN 6 PRESSED\n";
				VCPfn->VCP_send_buffer(message, 18);
				clear_buffer(18);
				if ( !LED6 ) LED6 ^= 1;
				btn = 6;
			}
			else if( theByte == 0xD ){
				if  ( !remote ){
					message = "REMOTE IS ON\n\0";
				}else{
					message = "REMOTE IS OFF\n\0";
				}
				
				remote ^= 1;
				
				len = strlen(message);
				VCPfn->VCP_send_buffer( message, len );
				clear_buffer( len-1 );
			}
			else if( remote && theByte == 32 ){				
				//process word after space bar is pressed
				if ( !ADC_CAL && !mystrcmp( ADC_on, buf ) ){
						ADC_ON = 1; 
						message = "--->ADC Mode ON\n\0";
						len = strlen(message);
						VCPfn->VCP_send_buffer( message, len );
						clear_buffer( len );
				}
				else if ( !ADC_CAL && !mystrcmp( ADC_off, buf ) ){
						ADC_ON = 0;
						message = "--->ADC Mode OFF\n\0";
						len = strlen(message);
						VCPfn->VCP_send_buffer( message, len );
						clear_buffer( len );
				}
				else if ( !mystrcmp( calibADC, buf ) && !ADC_ON && !ADC_CAL ){
						ADC_CAL = 1;
						message = "--->TURN CLOCKWISE TO CALIBRATE\n\0";
						len = strlen(message);
						VCPfn->VCP_send_buffer( message, len );
						clear_buffer( len );
						LED1 = 1;
						LED2 = 1;
						LED3 = 1;
						LED4 = 1;
						LED5 = 1;
						LED6 = 1;
						LED1_color = RED;
						LED2_color = RED;
						LED3_color = RED;
						LED4_color = RED;
						LED5_color = RED;
						LED6_color = RED;
				}
				else if ( !mystrcmp( exitcalibADC, buf ) && !ADC_ON && ADC_CAL ){
						message = "--->DONE CALIBRATING\n\0";
						len = strlen(message);
						VCPfn->VCP_send_buffer( message, len );
						clear_buffer( len );
						ADC_CAL = 0;
						ADC_PREP = 0;
						LED1 = 0;
						LED2 = 0;
						LED3 = 0;
						LED4 = 0;
						LED5 = 0;
						LED6 = 0;
						LED1_color = 0;
						LED2_color = 0;
						LED3_color = 0;
						LED4_color = 0;
						LED5_color = 0;
						LED6_color = 0;
				}
				else if ( !ADC_CAL && !mystrcmp( dance_str, buf ) || !mystrcmp( DANCE_str, buf ) ){
						if ( !mystrcmp( DANCE_str, buf ) ){
							DANCE = 1;
							message = "DANCE! \\_('_' )_/\n\0";
							
							if ( !saved ){
								LEDsave[0] = LED1;
								LEDsave[1] = LED2;
								LEDsave[2] = LED3;
								LEDsave[3] = LED4;
								LEDsave[4] = LED5;
								LEDsave[5] = LED6;
								
								LEDcolorsave[0] = LED1_color;
								LEDcolorsave[1] = LED2_color;
								LEDcolorsave[2] = LED3_color;
								LEDcolorsave[3] = LED4_color;
								LEDcolorsave[4] = LED5_color;
								LEDcolorsave[5] = LED6_color;
								saved = 1;
							}
						}else{
							DANCE = 0;
							message = "Party's over bud (-_-. )\n\0";
							LED1 = LEDsave[0];
							LED2 = LEDsave[1];
							LED3 = LEDsave[2];
							LED4 = LEDsave[3];
							LED5 = LEDsave[4];
							LED6 = LEDsave[5];
							LED1_color = LEDcolorsave[0];
							LED2_color = LEDcolorsave[1];
							LED3_color = LEDcolorsave[2];
							LED4_color = LEDcolorsave[3];
							LED5_color = LEDcolorsave[4];
							LED6_color = LEDcolorsave[5];
							saved = 0;
						}
						
						len = strlen(message);
						VCPfn->VCP_send_buffer( message, len );
						clear_buffer( len );
				}
				else if ( !ADC_CAL && !mystrcmp( bye, buf ) ){
					message = "....See you later\n\0";
					len = strlen(message);
					VCPfn->VCP_send_buffer( message, len );
					clear_buffer( len );
				}
				
				buf_chars = 0;
				clear_buffer(char_cnt);
				char_cnt = 0;
				
			}
			else{
				//build a word from the char input
				buf[buf_chars++] = theByte;
				char_cnt++;
			}
			
		}
		
	}
	
	start_timer2( );							//start up timer (could probably comment this out...?)
}


void TIM5_IRQHandler(void){
	clear_TIM5_TIF_UIF( );			//clear TIM5 interrupt
	if ( ADC_CAL ){
		static uint8_t check = 0;
		clear_caths_and_anodes();
		rot_Enc_setup( 0 );		//rotary encoder is 0 enabled
		signed int dir = process_rot_encoder();
		if( dir > 0 ){
			ADC_PREP++;
			if ( ADC_PREP == 7 ) ADC_PREP = 6;
			check = ADC_PREP;
		}
		else if( dir < 0 ){
			check = ADC_PREP;
			if ( ADC_PREP ) ADC_PREP--;
		}else{
			check = 0;
		}
		
		//Toggle LED interface based on turn direction
		switch ( check ){
			case 1:
				if ( dir > 0 ) LED1_color = GRN;
				if ( dir < 0 ) LED1_color = RED;
				break;
			case 2:
				if ( dir > 0 ) LED2_color = GRN;
				if ( dir < 0 ) LED2_color = RED;
				break;
			case 3:
				if ( dir > 0 ) LED3_color = GRN;
				if ( dir < 0 ) LED3_color = RED;
				break;
			case 4:
				if ( dir > 0 ) LED4_color = GRN;
				if ( dir < 0 ) LED4_color = RED;
				break;
			case 5:
				if ( dir > 0 ) LED5_color = GRN;
				if ( dir < 0 ) LED5_color = RED;
				break;
			case 6:
				if ( dir > 0 ) LED6_color = GRN;
				if ( dir < 0 ) LED6_color = RED;
				break;
		}
		
	}
	start_timer5();							//start up timer (could probably comment this out...?)
}


/*----------------------------------------------------------------------------
  SysTick_Handler
 *----------------------------------------------------------------------------*/
void SysTick_Handler(void) {
	if ( SVC0 ) {
		SVC_trap(0);	
	}
	else if ( SVC1 ) {
		SVC_trap(1);	
	}
	else if ( SVC2 ) {
		SVC_trap(2);
	}	
	else if ( SVC3 ) {
		SVC_trap(3);
	}	
	else if ( SVC4 ) {
		SVC_trap(4);
	}
	else if ( SVC5 ) {
		SVC_trap(5);
	}
	else if ( SVC6 ) {
		SVC_trap(6);
	}
	else {
		//could use other traps			
	}
}  //exit handler

void PendSV_Handler(void){
	PendSVInt_clear();			//clear PendSV interrupt in ICSR
	uint8_t *message;
	uint8_t len;
	if ( USB_VCP_ON ){
		if ( SVC0 ) {
			message = "\rSVC0 Task\n\0";
			len = strlen(message);
			VCPfn->VCP_send_buffer( message, len );
			clear_buffer( len-1 );
			SVC0 = 0;
		}
		else if ( SVC1 ) {
			message = "\rSVC1 Task\n\0";
			len = strlen(message);
			VCPfn->VCP_send_buffer( message, len );
			clear_buffer( len-1 );
			SVC1 = 0;
		}
		else if ( SVC2 ) {
			message = "\rSVC2 Task\n\0";
			len = strlen(message);
			VCPfn->VCP_send_buffer( message, len );
			clear_buffer( len-1 );
			SVC2 = 0;
		}
		else if ( SVC3 ) {
			message = "\rSVC3 Task\n\0";
			len = strlen(message);
			VCPfn->VCP_send_buffer( message, len );
			clear_buffer( len-1 );
			SVC3 = 0;
		}
		else if ( SVC4 ) {
			message = "\rSVC4 Task\n\0";
			len = strlen(message);
			VCPfn->VCP_send_buffer( message, len );
			clear_buffer( len-1 );
			SVC4 = 0;
		}
		else if ( SVC5 ) {
			message = "\rSVC5 Task\n\0";
			len = strlen(message);
			VCPfn->VCP_send_buffer( message, len );
			clear_buffer( len-1 );
			SVC5 = 0;
		}
		else if ( SVC6 ) {
			message = "\rSVC6 Task\n\0";
			len = strlen(message);
			VCPfn->VCP_send_buffer( message, len );
			clear_buffer( len-1 );
			SVC6 = 0;
		}
		else {
			message = "\rHow did we get here???\n\0";
			len = strlen(message);
			VCPfn->VCP_send_buffer( message, len );
			clear_buffer( len-1 );			
		}
		
		buf_chars = 0;
		clear_buffer(char_cnt);
		char_cnt = 0;
	}
	//implement task switch
}

void SVC_Handler(void){ 
	PendSvInt_init(0xFF);	//set PendSV in ICSR with lowest priority in NVIC
	
	
} //exit handler
