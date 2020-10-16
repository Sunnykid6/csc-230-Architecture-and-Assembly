#include <string.h>
#include "CSC230.h"
#include "CSC230_LCD.c"


#define MAX_STRING_LEN 17
char *l1ptr;
char *l2ptr;
char *msg1= "Hopefully This scrolls";
char *msg2 = "This just scrolls on the second line";


int main(void){
	char line1[MAX_STRING_LEN];
	line1[MAX_STRING_LEN - 1] = '\0';
	l1ptr = msg1;
	
	lcd_init();
}