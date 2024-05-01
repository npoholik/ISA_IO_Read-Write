//----------------------------------------------------------------------------------
// Engineers: Nikolas Poholik, Robert Sloyan
// 
// Create Date:    13:36:11 03/25/2024
// Description:    Set up hardware to perform ISA reads, where the ISA takes ADC 8 bit data and have the processor
//                 transfer this data into some quick medium
//
//----------------------------------------------------------------------------------

#include <stdio.h>
#include <conio.h>

int main() {
    unsigned char adcData;
    unsigned long count = 1;
    
    unsigned short i = 0;
    while(i < 1000) {
        // Poll from card to determine if data is ready
        while(1) {
            unsigned short status;
            inpw(0x03004, status);
            if (status = 1) {
                break;
            }
        }
        // Read new data
        inpw(0x03000, adcData);
        i++;
        
    }
    return 0;
}