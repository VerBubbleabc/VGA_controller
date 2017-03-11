---------------------------------------------------------------------------------- 
-- Author: Canh-Trung Nguyen
-- 
-- Design Name: 
-- Module Name: VGA_controller - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
--          |H_sync| H_back| Pixel | H_front|
--          This code is dedicated for Altera DE1 board
--          Resolution 640 x 480 - 60 Hz
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

entity VGA_controller is
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
           -- interface with IMG_generator
           VGA_DISP_en                  : out STD_LOGIC;
           VGA_RAM_ROW                  : out INTEGER;      -- access to get pixel data - by default: generate vector of 32 bits
           VGA_RAM_COL                  : out INTEGER;      -- access to get pixel data
           -- We can use std_logic_vector(0 to 9): 10-bit 1K column (1K pixels)
           -- std_logic_vector(0 to 8): 9-bit row (500 pixels)
           
           -- interface with VGA port
           VGA_HS                       : out STD_LOGIC;    -- active low, horizontal synchronization pulse
           VGA_VS                       : out STD_LOGIC);   -- active high, vertical synchronization pulse
end VGA_controller;

architecture Behavioral of VGA_controller is

signal h_on                            : std_logic;        -- start display on screen -- horizontal
signal v_on                            : std_logic;        -- start display on screen -- vertical
signal v_counter_en                    : std_logic;        -- enable vertical counter (driven by horizontal counter)

constant h_sync_bound                  : integer   := H_sync;
constant h_sync_back_bound             : integer   := H_sync + H_back;
constant h_sync_back_disp_bound        : integer   := H_sync + H_back + H_pixel;
constant h_total_pixel                 : integer   := H_sync + H_back + H_pixel + H_front;

constant v_sync_bound                  : integer   := V_sync;
constant v_sync_back_bound             : integer   := V_sync + V_back;
constant v_sync_back_disp_bound        : integer   := V_sync + V_back + V_pixel;
constant v_total_pixel                 : integer   := V_sync + V_back + V_pixel + V_front;
begin
----------------------------------------------
-- Horizontal counter
----------------------------------------------
h_counter:process(pixel_clk,rst)
variable x_coord:   integer range 0 to h_total_pixel := 0; 
begin
    if rising_edge(pixel_clk) then
        if (rst = '1') then
            x_coord             := 0;
            VGA_HS              <= NOT(H_pol);
            v_counter_en        <= '0';
            h_on                <= '0';
            VGA_RAM_COL         <= 0;
        else
             VGA_RAM_COL        <= x_coord;
            -- Generate: VGA_HS_n
            if (x_coord < h_sync_bound) then
                VGA_HS          <= H_pol;
            else
                VGA_HS          <= NOT (H_pol);
            end if;
            
            -- Enable h_on
            if (x_coord >= h_sync_back_bound) and (x_coord < h_sync_back_disp_bound) then
                h_on            <= '1';
            else
                h_on            <= '0';
            end if;
            
            -- Trigger Vertical counter
            if (x_coord = 0) then
                v_counter_en    <= '1';
            else
                v_counter_en    <= '0';
            end if;
            
            -- Horizontal counter
            if (x_coord = h_total_pixel - 1) then
                x_coord         := 0;
                --v_counter_en    <= '1';
            else
                x_coord         := x_coord + 1;
                --v_counter_en    <= '0';
            end if;
        end if;
    end if;
end process h_counter;

----------------------------------------------
-- Vertical counter
----------------------------------------------
v_counter:process(pixel_clk, rst, v_counter_en)
variable y_coord:   integer range 0 to v_total_pixel := 0;
begin
if rising_edge(pixel_clk) then
    if (rst = '1') then
       y_coord          := 0;
       VGA_VS           <= NOT(V_pol);
       v_on             <= '0';
       VGA_RAM_ROW      <= 0;
       
    else     
       if(v_counter_en = '1') then
           VGA_RAM_ROW  <= y_coord;
           -- Generate: VGA_HS
           if (y_coord < v_sync_bound) then
               VGA_VS          <= V_pol;
           else
               VGA_VS          <= NOT (V_pol);
           end if;
           
           if (y_coord >= v_sync_back_bound) and (y_coord < v_sync_back_disp_bound) then
               v_on            <= '1';
           else
               v_on            <= '0';
           end if;
           
           if (y_coord = v_total_pixel - 1) then
              y_coord         := 0;
          else
               y_coord        := y_coord + 1;
          end if;
        end if;
   end if;
 end if;
end process v_counter;

----------------------------------------------
-- Enable sending data RGB
----------------------------------------------
VGA_DISP_en <= '1' when (v_on and h_on) = '1' else '0';

end Behavioral;
