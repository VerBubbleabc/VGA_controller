----------------------------------------------------------------------------------
-- Engineer: Canh-Trung Nguyen
--
-- Design Name: 
-- Module Name: clock_divider - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
--      clock source : 50 MHz
--      target source: 25 MHz
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clock_divider is
    Generic (
            source_clk   : integer := 50000000;     -- 50 MHz
            target_clk   : integer := 25000000      -- 25 MHz
            );
    Port (  rst          : in STD_LOGIC;
            clk          : in STD_LOGIC;
            pixel_clk    : out STD_LOGIC
           );
end clock_divider;

architecture Behavioral of clock_divider is
constant max_counter        : integer := (source_clk/target_clk);

begin
clk_divider: process(rst, clk)
variable counter: integer range 0 to max_counter;
begin
    if (rst = '1') then
        counter     := 0;
        pixel_clk   <= '0';
    elsif rising_edge(clk) then
        counter     := counter + 1;
        if (counter  = max_counter) then
            counter     := 0;
            pixel_clk   <= not(pixel_clk);
        end if;
        
    end if;
end process clk_divider;
end Behavioral;