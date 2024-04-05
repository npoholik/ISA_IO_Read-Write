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
USE ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
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
			  countOut : buffer STD_LOGIC_VECTOR(7 downto 0) := "00000000");    --
end userDesign;

----------------------------------------------------------------------------------
-- ***Architecture Begin*** --

architecture Behavioral of userDesign is
-- ***Signal Declaration*** --
    signal count: integer range 1 to 32767 := 1;                            -- 
    signal genClk: STD_LOGIC;                                               --
    signal latchData: STD_LOGIC;                                            --
    signal clkDiv : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000001";    --
-- ***Architecture Begin*** --
begin
    -- Following signals are not yet utilized, but are important for ISA spec and will be included in further iterations
	CHRDY <= 'Z';
	MEM16 <= 'Z';
	IO16 <= 'Z';
	SD <= "ZZZZZZZZZZZZZZZZ";
    
    -- Check if IOWC is asserted, and if the address is set to desired 0x03000 
    -- If these are true, the counter will be transmitted
    ISABus: process(SA, SD, IORC, IOWC)
    begin 
        if IOWC = '1' and SA = x"03000" then
            clkDiv <= SD;
        end if;
    end process;
    
    -- Create a counter capable of being variably divided by an input signal 
	Counter: process(clk_50) 
        variable divCounter : integer range 0 to 65535 := 0;
    begin
        if clkDiv = "0000000000000000" then                            -- Special Case when Divisor = 0; must shift 50 MHz clock into countOut or else 50 MHz counter is unachievable (closest will be 25 MHz as there will always be a divisor of 1 for counter)
              countOut <= countOut(6 downto 0) & clk_50;
        elsif rising_edge(clk_50) then
                if divCounter >= to_integer(unsigned(clkDiv))-1 then   -- Use one less than the given clkDiv signal to ensure that the hardware will have easy to understand divisions (1 = 25 MHz, 2 = 12.5 MHz ONLY if clkDiv -1 is used)
                    divCounter := 0;
                    countOut <= std_logic_vector(unsigned(countOut)+1);
                else 
                    divCounter := divCounter + 1;
                end if;
        end if;
    end process;   
---*** End Architecture 
end Behavioral;
