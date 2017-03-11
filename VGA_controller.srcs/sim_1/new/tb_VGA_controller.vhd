----------------------------------------------------------------------------------
-- Engineer: Canh-Trung Nguyen
-- 
-- Design Name: 
-- Module Name: tb_VGA_controller - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_VGA_controller is
end tb_VGA_controller;

architecture Behavioral of tb_VGA_controller is

component VGA_controller is
    Generic (
            H_sync  : integer := 96;
            H_back  : integer := 48;
            H_front : integer := 16;
            H_pixel : integer := 640;
            H_pol   : std_logic := '0'; -- active low
            
            V_sync  : integer := 2;
            V_back  : integer := 33;
            V_front : integer := 10;
            V_pixel : integer := 480;
            V_pol   : std_logic := '0'  -- active high
                );
    Port ( rst                          : in STD_LOGIC;
           pixel_clk                    : in STD_LOGIC;     -- driven from clock divider - 84.36 MHz
           
           VGA_DISP_en                  : out STD_LOGIC;
           VGA_RAM_ROW                  : out INTEGER;      -- access to get pixel data
           VGA_RAM_COL                  : out INTEGER;      -- access to get pixel data
           
           
           VGA_HS                       : out STD_LOGIC;    -- active low, horizontal synchronization pulse
           VGA_VS                       : out STD_LOGIC);   -- active high, vertical synchronization pulse
end component;

signal pixel_clk    : std_logic := '0';
signal rst          : std_logic := '1';
signal VGA_DISP_en  : STD_LOGIC;
signal VGA_RAM_ROW  : INTEGER;      -- access to get pixel data
signal VGA_RAM_COL  : INTEGER;      -- access to get pixel data    
signal VGA_HS       : STD_LOGIC;    -- active low, horizontal synchronization pulse
signal VGA_VS       : STD_LOGIC;

constant clk_period : time := 10 ns;

begin  
   uut: VGA_controller port map (
        rst,
        pixel_clk,
        VGA_DISP_en,
        VGA_RAM_ROW,
        VGA_RAM_COL,
        VGA_HS,
        VGA_VS); 

       -- Clock process definitions( clock with 50% duty cycle is generated here.
   clk_process :process
   begin
        pixel_clk <= '0';
        wait for clk_period/2;  --for 0.5 ns signal is '0'.
        pixel_clk <= '1';
        wait for clk_period/2;  --for next 0.5 ns signal is '1'.
   end process;
   -- Stimulus process
  stim_proc: process
   begin         
        wait for 7 ns;
        rst <='1';
        wait for 50 ns;
        rst <='0';
        wait;
  end process;
end Behavioral;