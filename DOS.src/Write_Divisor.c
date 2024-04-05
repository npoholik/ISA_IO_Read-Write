//----------------------------------------------------------------------------------
// Engineers: Nikolas Poholik, Robert Sloyan
// 
// Create Date:    13:36:11 03/25/2024
// Description:    Divide down and determine a reasonable divisor for a 50 MHz master clock to a user specified desired clock
//                 This is performed in a C program, as designing the VHDL logic for division will consume a large number of gates 
//
//----------------------------------------------------------------------------------

#include <stdio.h>
#include <conio.h>

// Define a function to round double precision floating points
// This is required because the MS DOS version on the card does not have this in the math.h library
int round(double num) {
    int ret; 
    ret = num;              // Implicitly cast double to an int (results in truncation)
    num = num - ret;        // Get a decimal value of 0.______ (Some Value Remaining)
    if (num >= 0.5) {       // Use the previous step to determine rounding
        ret += 1;
    }
    return ret;
}


int main() {
    double mainFreq = 50000000;         // Trying to divide down a 50 MHz master clock frequency of the board
    printf("What's your desired frequency\n");

    double desiredFreq = 0;
    scanf("%lf", &desiredFreq);
    unsigned short divisor;

    // Due to the nature of the hardware design, some edge cases must be considered
    // The hardware design allows the lowest possible frequency to be ~382 Hz. Any value beyond will result in a an overflow and incorrect divisor
    if (desiredFreq <= 382) {
        divisor = 65535;             // 65535 = 2^16-1; This is the maximum size in decimal that can be stored by the hardware for a divisor
    }
    // The second edge case is if the user wants a clock the same or higher than the maximum master clock
    // This simply results in a divisor of 0, as the highest achievable clock is already present
    // 0 Case is mostly handled on the hardware level
    else if (desiredFreq >= 50000000) {
        divisor = 0;
    }
    // If two edge cases are not present, simply perform a normal division operation to send to the card
    else {
        divisor = (unsigned short)round(mainFreq/desiredFreq)/2;    // Divisor is an unsigned short as 16 bits is our maximum size 

    }
    printf("Your divisor is: %hu\n", divisor);
    outpw(0x03000, divisor);                    // Choosing 0x03000 (20 bits) address for the design 
}