#include <stdint.h>
/* Prototypes */
void setTime( uint32_t BCD_TIME );
void setDate( uint32_t BCD_DATE );
uint32_t read_INITF(void);
void RTC_PWR_enable(void);		//1. enable the RTC PWR clock 
void RTC_access_enable(void);	//2. enable access to RTC backup domain 
void RTC_use_LSI(void); 		//3. enable LSI oscillator as RTC source clock 
int RTC_LSI_notready(void);		//4. returns TRUE until LSI is ready
void RTC_use_24hour_time(void); //5. select 24-hour time
void RTC_clock_enable();		//6. enable the RTC clock
void RTC_set_BCD_24hour_time(uint8_t HRS,uint8_t MIN,uint8_t SEC); 			//7. set RTC time (BCD)
void RTC_set_BCD_date(uint8_t MO, uint8_t DAY, uint8_t YR); 				//8. set RTC date (BCD)			
uint8_t getHRS(void);
uint8_t getMIN(void);
uint8_t getSEC(void);
uint8_t getMO(void);
uint8_t getDAY(void);
uint8_t getYR(void);

// Enter/exit access mode for time/date intitializations
void enter_RTCinit_mode(void);
void exit_RTCinit_mode(void);


void wait_for_init_mode(){ 	//Poll INITF flag before entering init mode
		while ( !read_INITF() ){ ; }
}

void RTC_24hr_config(void){
	//RTC configuration
	RTC_PWR_enable();							// enable the RTC PWR clock 
	RTC_access_enable();						// enable access to RTC backup domain 
	RTC_use_LSI();								// enable LSI oscillator as RTC source clock 
	while( RTC_LSI_notready()) { ; } 			// wait until LSI oscillator is ready 
	RTC_use_24hour_time();						// select 24-hour time-keeping
	RTC_clock_enable();							// enable the RTC clock
}


void RTC_set_BCD_24hour_time(uint8_t HRS,uint8_t MIN,uint8_t SEC){
		setTime( HRS << 16 | MIN << 8 | SEC );
} 				//7. set RTC time (BCD)

void RTC_set_BCD_date(uint8_t MO,uint8_t DAY, uint8_t YR){
		setDate( YR << 16 | MO << 8 | DAY );
}				//8. set RTC date (BCD)	

void setTimeandDate(uint32_t time_in_BCD, uint32_t date_in_BCD){
		unsigned int MO = ( date_in_BCD & (0x0000FF00) ) >> 8;
	  unsigned int YR = ( date_in_BCD & (0x00FF0000) ) >> 16;
	  unsigned int DAY = ( date_in_BCD & (0x000000FF) );
		enter_RTCinit_mode();						//stop the clock for initializations
		RTC_set_BCD_24hour_time(( time_in_BCD & (0x00FF0000) ) >> 16,(time_in_BCD & (0x0000FF00) ) >> 8,time_in_BCD & (0x000000FF));	// set time=08:10:00 for demo (using hex because digits are BCD)
		RTC_set_BCD_date(MO, DAY, YR); 		// set date= 5/12/16 for demo (using hex because digits are BCD)				
	  exit_RTCinit_mode();
}

void RTC_get_BCD_24hour_time( uint8_t *HRS, uint8_t *MIN, uint8_t *SEC){
		*HRS = getHRS();
		*MIN = getMIN();
		*SEC = getSEC();
} 			//9. read RTC time (BCD) 


void RTC_get_BCD_date( uint8_t *MO, uint8_t *DAY, uint8_t *YR){
		*MO = getMO();
		*DAY = getDAY();
		*YR = getYR();
}				//10. read RTC date (BCD)