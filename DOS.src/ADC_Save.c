//----------------------------------------------------------------------------------
// Engineers: Nikolas Poholik, Robert Sloyan
// 
// Create Date:    13:36:11 03/25/2024
// Description:    Set up hardware to perform ISA reads, where the ISA takes ADC 8 bit data and have the processor
//                 transfer this data into a text file 
//
//----------------------------------------------------------------------------------

#include <stdio.h>
#include <conio.h>

int main() {
    unsigned short adcData;
    unsigned long long count = 1;
    char *fileName = "ADC_Data.txt";

    // Open text file for writes
    FILE *fp = fopen(fileName, "w");
    // Check for a valid text file opening, terminate program if it cannot be found
    if (fp == NULL) {
        printf("Error when accessing text file for ADC Data");
        return -4;
    }
    
    while(1) {
        // Read data from the ISA bus

        // Increment data count


        // Maybe look for discrepancies?

        //Write data into text file (printing to console will be too slow and cause the transfer to slow significantly)
        fprintf(fp, "Data read %lu: %hu\n", count, adcData);
    }
    // If while loop breaks at any point close the text file and terminate the program
    fclose(fp); 
    return 0;
}