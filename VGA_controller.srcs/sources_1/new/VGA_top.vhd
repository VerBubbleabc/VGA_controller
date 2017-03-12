----------------------------------------------------------------------------------
-- Engineer: Canh-Trung Nguyen
 
-- Module Name: VGA_top - Behavioral
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

entity VGA_top is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           VGA_HS : out STD_LOGIC;
           VGA_VS : out STD_LOGIC;
           VGA_R : out STD_LOGIC_VECTOR (0 to 3);
           VGA_G : out STD_LOGIC_VECTOR (0 to 3);
           VGA_B : out STD_LOGIC_VECTOR (0 to 3));
end VGA_top;

architecture Behavioral of VGA_top is

component clock_divider is
    Generic (
            source_clk   : integer := 50000000;     -- 50 MHz
            target_clk   : integer := 25000000      -- 25 MHz
            );
    Port ( rst          : in STD_LOGIC;
           clk          : in STD_LOGIC;
           pixel_clk    : out STD_LOGIC
           );
end component;

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
           -- interface with IMG_generator
           VGA_DISP_en                  : out STD_LOGIC;
           VGA_RAM_ROW                  : out INTEGER;      -- access to get pixel data - by default: generate vector of 32 bits
           VGA_RAM_COL                  : out INTEGER;      -- access to get pixel data
           -- We can use std_logic_vector(0 to 9): 10-bit 1K column (1K pixels)
           -- std_logic_vector(0 to 8): 9-bit row (500 pixels)
           
           -- interface with VGA port
           VGA_HS                       : out STD_LOGIC;    -- active low, horizontal synchronization pulse
           VGA_VS                       : out STD_LOGIC);   -- active high, vertical synchronization pulse
end component;

component simple_image_generator is
    Generic (
        min_x_coord     : integer := 144;
        min_y_coord     : integer := 35;
        font_size       : integer := 16; -- 16 x 16 pixel
        unit_size       : integer := 32  -- 32 pixels
    );
    Port ( 
           VGA_DISP_en  : in STD_LOGIC;
           VGA_RAM_COL  : in INTEGER;
           VGA_RAM_ROW  : in INTEGER;
           pixel_clk    : in STD_LOGIC;
           rst          : in STD_LOGIC;
           
           IMG_R        : out STD_LOGIC_VECTOR (0 to 3);
           IMG_G        : out STD_LOGIC_VECTOR (0 to 3);
           IMG_B        : out STD_LOGIC_VECTOR (0 to 3));
end component;


signal VGA_DISP_en  : STD_LOGIC;
signal VGA_RAM_COL  : INTEGER;
signal VGA_RAM_ROW  : INTEGER;
signal pixel_clk    : STD_LOGIC;

begin
U1: clock_divider port map (rst, clk, pixel_clk);
U2: VGA_controller port map (rst, pixel_clk, VGA_DISP_en, VGA_RAM_ROW, VGA_RAM_COL, VGA_HS, VGA_VS);
U3: simple_image_generator port map (VGA_DISP_en, VGA_RAM_COL, VGA_RAM_ROW, pixel_clk, rst, VGA_R, VGA_G, VGA_B);
end Behavioral;
