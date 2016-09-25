#include <stdint.h>

//maintain a 24hr format for the clock refresh display 
//return time in decimal format
uint32_t clockInterfaceCalibrate(int *hrs, int *min){
	int minCheck = *min, hrsCheck;
	
	//maintain a 24hr format for the clock refresh display 
	if( minCheck <= -1 || minCheck >= 60 ) {
		if ( minCheck > 0 ){ 
			*hrs += 1;
			*min = 0;
		}else{ 
			*hrs -= 1; 
			*min = 59;
		}
	}
			
	hrsCheck = *hrs;
	if( hrsCheck == 25 ) *hrs = 0;
	if( hrsCheck == -1 ) *hrs = 24;
	
	return (*hrs)*100 + *min;
}

// return 0 on buttons -> 1-2 toggle hrs, 3-4 toggle min
// setup RTC and return 1 on button 13
int btnsTimeUpdate(int Btn, uint32_t time, int *hrs, int *min){
	if ( Btn == 13 ){
		unsigned int BCD_hrs = ( (time/1000) << 4 ) | ( (time/100) % 10 );
		unsigned int BCD_min = ( (( time % 100 ) / 10 ) << 4 ) | ( time % 10 );
		setTimeandDate( BCD_hrs << 16 | BCD_min << 8, 0x0 );
		return 1;
	}else{
					if( Btn == 1 ){ *hrs += 1;
		}else if( Btn == 2 ){ *hrs -= 1;
		}else if( Btn == 3 ){ *min += 1;
		}else if( Btn == 4 ){ *min -= 1;
		}else {}
		
		return 0;
	}
}
