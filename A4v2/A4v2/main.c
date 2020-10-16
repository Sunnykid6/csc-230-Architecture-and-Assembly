#include <string.h>
#include "CSC230.h"
#include "CSC230_LCD.c"


#define MAX_STRING_LEN 17
char *l1ptr;
char *l2ptr;
char *msg1 = "Hopefully This scrolls ";
char *msg2 = "This just scrolls on the second line ";
int chkButton;
/*
Tried to implement what I had in assignment 3 for having a split scroll
decided to try to speed and slow down scroll. However the _delay_ms would
not let me use the speed variable name and was confused as to why. So now
this only pauses and resumes scrolling.
*/
//int speed = 500;

int main(void){
	char line1[MAX_STRING_LEN];
	line1[MAX_STRING_LEN - 1] = '\0';
	l1ptr = msg1;
	
	char line2[MAX_STRING_LEN];
	line2[MAX_STRING_LEN - 1] = '\0';
	l2ptr = msg2;
	
	lcd_init();
	ADCSRA = 0x87;
	ADMUX = 0x40;
	
	
	for(;;){
		lcd_xy(0, 0);
			
		lcd_blank(MAX_STRING_LEN);
		copyMessage1(l1ptr, line1, msg1);
			
		lcd_xy(0, 0);
		lcd_puts(line1);	
		
		lcd_xy(0, 1);
		
		lcd_blank(MAX_STRING_LEN);
		copyMessage2(l2ptr, line2, msg2);
		
		lcd_xy(0, 1);
		lcd_puts(line2);
		
		movPointer();
		chkButton = checkButton();
		doButton(chkButton);
		_delay_ms(750);
		
	}

		
		
}
void copyMessage1(char* ptr, char* copiedMsg, char *msg){
	
	int i = 0;
	for(i = 0; i < MAX_STRING_LEN - 1; i++){
		if(*ptr == '\0'){
			ptr = msg;
		}
		else{
			*copiedMsg = *ptr;
			copiedMsg++;
			ptr++;
		}
	}
}

void copyMessage2(char* ptr, char* copiedMsg, char *msg){
	
	int i = 0;
	for(i = 0; i < MAX_STRING_LEN - 1; i++){
		if(*ptr == '\0'){
			ptr = msg;
		}
		else{
			*copiedMsg = *ptr;
			copiedMsg++;
			ptr++;
		}
	}
}

void movPointer(){
	
	if(*l1ptr == '\0'){
		l1ptr = msg1;
	}
	l1ptr++;
		
	if(*l2ptr == '\0'){
		l2ptr = msg2;
	}
	l2ptr++;
		
}

int checkButton(){
	
	int whichButton;
	ADCSRA |= 0x40;
	
	while(ADCSRA & 0x40){
		;
	}
	
	unsigned int lowVal = ADCL;
	unsigned int highVal = ADCH;
	
	lowVal = lowVal + (highVal << 8);
	if(lowVal > 1000){
		whichButton = 0;
	}
	
	if(lowVal < 50){
		whichButton =  1;
	}
	else if(lowVal < 195){
		whichButton = 2;
	}
	else if(lowVal < 380){
		whichButton = 3;
	}
	else if(lowVal < 555){
		whichButton = 4;	
	}
	else{
		whichButton = 5;
	}
	
	return whichButton;
	
}

void doButton(int whichButton){
	
	int checkButton2;
	
	if(whichButton == 2){
		checkButton2 = checkButton();
		while(checkButton2 != 3){
			checkButton2 = checkButton();
		}
	}
}
