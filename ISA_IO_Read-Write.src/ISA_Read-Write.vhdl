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
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;

----------------------------------------------------------------------------------

entity userDesign is
    Port ( bclk : in  STD_LOGIC;
			  clk_50 : in std_logic;                                            -- Master clock of board
			  --LA: in std_logic_vector(23 downto 17);                          -- Latch address, exists in ISA spec but is unused for this particular design
			  SA: in std_logic_vector(19 downto 0);                             -- 
			  SD: inout std_logic_vector(15 downto 0);                          --
			  IOWC: in std_logic;                                               -- IO Write, asserted in order to
			  IORC: in std_logic;                                               -- IO read, asserted in order to 
			  IO16 : out std_logic;                                             -- IO16 
			  MEM16 : out std_logic;                                            -- MEM16 
			  CHRDY: out std_logic;                                             -- BUS Control 
			  countOut : buffer STD_LOGIC_VECTOR(7 downto 0) := "00000000";    --
              -- ADC
              adcData : in std_logic_vector(7 downto 0) := x"00";
              adcWrite : out std_logic;
              adcINT : in std_logic := '0';
              valid : buffer std_logic);

end userDesign;

----------------------------------------------------------------------------------
-- ***Architecture Begin*** --

architecture Behavioral of userDesign is
-- ***Signal Declaration*** --
    signal count: integer range 1 to 32767 := 1;                            -- 
    signal genClk: STD_LOGIC;                                               --
    signal latchData: STD_LOGIC_VECTOR(15 downto 0);                                            --
    signal clkDiv : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";    --

    --signal procData : std_logic_vector(7 downto 0);
    --signal readC : std_logic;  -- From C Program

    signal valid_prev : std_logic;
    signal valid_change : std_logic;
    
-- ***Architecture Begin*** --
begin
    -- Following signals are not yet utilized, but are important for ISA spec and will be included in further iterations
	--CHRDY <= 'Z';
	--MEM16 <= 'Z';
	--IO16 <= 'Z';
	--SD <= "ZZZZZZZZZZZZZZZZ";
    
    -- Signals to inform bus control logic about the transfer to take place
    -- HOoRAY
    ISABus: process(SA, SD, IORC, IOWC)
    begin 
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
            SD <= latchData;
        end if;
    end process;

    
    SREG: process(adcINT, SA, SD, IORC, IOWC) 
    begin
        if adcINT = '1' then
            valid <= '1'; -- Determine if a read has been performed by ADC
        elsif IORC = '0' and SA = x"03000" then -- Determine if a read has been issued to processor
            valid <= '0';
        end if;
    end process;

    adcWrite <= countOut(0); -- Begin reads with countOut(0)
    
    Latch: process(countOut(0))
    begin
        if countOut(0) = '1' and valid = '1' then
            latchData <= adcData & x"00";
        end if;
    end process;
    
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

---*** End Architecture 
end Behavioral;
