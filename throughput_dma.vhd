----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/07/2020 11:29:15 PM
-- Design Name: 
-- Module Name: throughput_dma - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity throughput_dma is
  Port (
  clk  : in std_logic;
  rst  : in std_logic;
  s2mm_wdata : in std_logic_vector(31 downto 0);
  s2mm_valid : in std_logic
   );
end throughput_dma;

architecture Behavioral of throughput_dma is

signal counter : integer := 0;
signal s2mm_data : integer := 0;

begin

  s2mm_data <= to_integer(unsigned(s2mm_wdata));

process(clk)
begin
  if rising_edge(clk) then
     if(rst = '0') then
       counter <= 0;
       elsif(s2mm_valid = '1') then
       
          if(s2mm_data > 511) then
          
        counter <= 0;
       else
        counter <= counter + 1;
        
        
        end if;
        end if;
      
        end if;
          
 end process;







end Behavioral;
