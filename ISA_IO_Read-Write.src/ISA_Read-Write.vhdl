----------------------------------------------------------------------------------
-- Engineers: Nikolas Poholik, Robert Sloyan
-- 
-- Create Date:    13:36:11 03/18/2024
-- Design Name:    ISA_Read-Write
-- Module Name:    userDesign - Behavioral 
-- Project Name:   ISA_Read-Write
-- Target Devices: Xilinx Spartan XC3S1500 FGG320EGQ1117 D4242286A
-- Tool versions:  
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;

----------------------------------------------------------------------------------

entity userDesign is
    Port ( bclk : in  STD_LOGIC;
			  clk_50 : in std_logic;                                            -- Master clock of board
			  --LA: in std_logic_vector(23 downto 17);                          -- Latch address, exists in ISA spec but is unused for this particular design
			  SA: in std_logic_vector(19 downto 0);                             -- Address received from processor, determines if our card is being talked to
			  SD: inout std_logic_vector(15 downto 0);                          -- Data to/from processor depending on read/write
			  IOWC: in std_logic;                                               -- IO Write, asserted in order for the processor to write to the card
			  IORC: in std_logic;                                               -- IO read, asserted in order for the processor to read from the card
			  IO16 : out std_logic;                                             -- IO16 asserted alerts the bus that a 16 bit IO transfer will take place (not asserted -> 8 bits)
			  MEM16 : out std_logic;                                            -- MEM16 asserted alerts the bus that a 16 bit memory transfer will take place (not asserted -> 8 bits)
			  CHRDY: out std_logic;                                             -- CHRDY asserted will tell the steering logic to move onto the next transaction without wait states 

			  countOut : buffer STD_LOGIC_VECTOR(7 downto 0) := "00000000";     -- A counter with adjustable frequency from the processor that will influence A/D conversion rate 

              adcData : in std_logic_vector(7 downto 0) := x"00";               -- Data received from a conversion of the ADC chip
              adcWrite : out std_logic;                                         -- Signal to the ADC chip to initialize a new conversion
              adcINT : in std_logic := '0');                                    -- Interrupt signal to indicate a conversion has finished
end userDesign;

----------------------------------------------------------------------------------

architecture Behavioral of userDesign is
    -- ***Signal Declaration*** --
    ------------------------------------------------------------------------------
    -- ISA Write Specific:
    signal clkDiv : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";    -- 16 bit max divisor for the clk_50 

    -- ISA Read Specific:
    signal valid : STD_LOGIC;                                               -- A status bit to determine if new ADC data is ready
    signal latchData: STD_LOGIC;                                            -- A latch to indicate when new data is to be loaded from ADC
    signal procData : std_logic_vector(15 downto 0);                        -- Routes data from latch to the ISA Bus

    ------------------------------------------------------------------------------
-- ***Architecture Begin*** --
----------------------------------------------------------------------------------
begin

    adcWrite <= countOut(0); -- Begin conversions in the ADC with countOut(0) 

    -- Signals to inform bus control logic about the transfer to take place
    ISABus: process(SA, SD, IORC, IOWC)
    begin 
        -- Check if the card is being talked to, whether in regards to an IO read or write 
        if IOWC = '0' and SA = x"03000" then -- We will be performing an IO 16 bit write to the card
            CHRDY <= '1';
            IO16 <= '0';
            MEM16 <= 'Z';
            clkDiv <= SD;
        else 
            CHRDY <= 'Z';
            IO16 <= 'Z';
            MEM16 <= 'Z';
            SD <= "ZZZZZZZZZZZZZZZZ";
        end if;
        
        if IORC = '0' and SA = x"03000" then -- we will be performing an IO 8 bit read from the card 
            CHRDY <= '1';
            IO16 <= '1'; -- ADC data will be 8 bits, so IO16 will not be asserted
            MEM16 <= 'Z';
            SD <= procData;
        end if;
    end process;

    -- Create a Status Register to hold whether or not there is valid data from the ADC; this bit is cleared from a read from the processor
    SREG: process(adcINT, SA, SD, IORC, IOWC) 
    begin
        if adcINT = '1' then
            valid <= '1'; -- Determine if a read has been performed by ADC
        elsif IORC = '0' and SA = x"03000" then -- Determine if a read has been issued to processor
            valid <= '0';
        end if;
    end process;
    
    -- Create a process to latch data from the ADC to procData (which goes to SD on the bus)
    -- This exists to avoid any irregularities with data writing over itself if ADC data outpaces the bus
    Latch: process(countOut(0), valid)
    begin
        if countOut(0) = '1' and valid = '1' then
            latchData <= '1';
        end if;

        if latchData <= '1' then
            procData <= adcData & x"00"; -- little endian 
            latchData <= '0';
    end process;
    

    -- Create a counter capable of being variably divided by an input signal 
	Counter: process(clk_50) 
        variable divCounter : integer range 0 to 65535 := 0;
    begin
        if clkDiv = "0000000000000000" then                            -- Special Case when Divisor = 0; must shift 50 MHz clock into countOut or else 50 MHz counter is unachievable (closest will be 25 MHz as there will always be a divisor of 1 for counter)
              countOut <= countOut(6 downto 0) & clk_50;
        elsif rising_edge(clk_50) then
                if divCounter >= to_integer(unsigned(clkDiv)) - 1 then   -- Use one less than the given clkDiv signal to ensure that the hardware will have easy to understand divisions (1 = 25 MHz, 2 = 12.5 MHz ONLY if clkDiv -1 is used)
                    divCounter := 0;
                    countOut <= std_logic_vector(unsigned(countOut)+1);
                else 
                    divCounter := divCounter + 1;
                end if;
        end if;
    end process;  



--*** DELETE OR FIX***---
------------------------------------------------------------------------------------------------------------------------
--    signal count: integer range 1 to 32767 := 1;                            -- 
--    signal genClk: STD_LOGIC;                                               --
--    --signal readC : std_logic;  -- From C Program

--signal valid_prev : std_logic;
--signal valid_change : std_logic;
    -- Following signals are not yet utilized, but are important for ISA spec and will be included in further iterations
	--CHRDY <= 'Z';
	--MEM16 <= 'Z';
	--IO16 <= 'Z';
	--SD <= "ZZZZZZZZZZZZZZZZ";


    -- Create reg to hold status of valid, based on INT of adc and signal from C program
  --  status: process(countOut) 
 --   begin
 --       if rising_edge(countOut(0)) then
 --           valid <= adcINT; -- Fix later (not what we're trying to do exactly)
  --      end if;
  --  end process;

--    -- Detect non-clock edges of valid to determine if a new sample is ready
--    Valid_Detector: process(countOut) 
--    begin
--        if rising_edge(countOut(0)) then
--            valid_prev <= valid;

--            if valid_prev = '1' and valid = '0' then
--                valid_change <= '1';
--            end if;
--        end if;
--    end process;

--    -- Hardware Polling of ADC to Trigger a new Conversion and Transfer
--    ADC_Poll: process(countOut) 
--    begin
--        if rising_edge(countOut(0)) then
--            -- Check if INT is asserted, if so write data to reg and start new conversion
--            if valid_change = '1' then
--                procData <= adcData;
--                adcWrite <= '0';
--                end if;
--            end if;
--    end process;
------------------------------------------------------------------------------------------------------------------------

---*** End Architecture 
end Behavioral;
