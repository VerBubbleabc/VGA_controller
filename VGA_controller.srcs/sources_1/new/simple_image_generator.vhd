----------------------------------------------------------------------------------
-- Engineer: Canh-Trung Nguyen
-- 
-- Design Name: 
-- Module Name: simple_image_generator - Behavioral
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

entity simple_image_generator is
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
end simple_image_generator;

architecture Behavioral of simple_image_generator is

type block_pixel is array (0 to font_size/2 - 1) of std_logic_vector (0 to font_size - 1);

constant off_state  : STD_LOGIC_VECTOR(0 to 3) := "0000";
constant on_state   : STD_LOGIC_VECTOR(0 to 3) := "1111";

constant A          : block_pixel := (
                                      0 =>  "0000000110000000",
                                      1 =>  "0000001111000000",
                                      2 =>  "0000011001100000",
                                      3 =>  "0000110000110000",
                                      4 =>  "0001111111111000",
                                      5 =>  "0011000000001100",
                                      6 =>  "0110000000000110",
                                      7 =>  "1100000000000011");
signal x_coord      : integer;
signal y_coord      : integer;

signal x_coord_letter : integer := 400;
signal y_coord_letter : integer := 250;
begin
-------------------------------------
-- IMGAGE GENERATOR
-------------------------------------
-- Recommendation: should divide IMG_gen into TEXT_GEN, LETTER_GEN
IMG_generator: process(pixel_clk, rst, VGA_DISP_en)
begin
    if rising_edge(pixel_clk) then
        if rst = '1' then
            IMG_R       <= off_state;
            IMG_G       <= off_state;
            IMG_B       <= off_state;
        elsif(VGA_DISP_en = '1') then
            -- default
            IMG_R   <= off_state;
            IMG_G   <= off_state;
            IMG_B   <= off_state;
        
            -- print a Rectangle at the top left conner
            if ( VGA_RAM_COL >= x_coord and VGA_RAM_COL < x_coord + unit_size and
                VGA_RAM_ROW >= y_coord and  VGA_RAM_ROW < y_coord + unit_size) then
                IMG_R   <= on_state;
                IMG_G   <= on_state;
                IMG_B   <= on_state;
            
            -- print a letter A at the center of screen
            elsif ( VGA_RAM_COL >= x_coord_letter and VGA_RAM_COL < x_coord_letter + font_size and
                VGA_RAM_ROW >= y_coord_letter and  VGA_RAM_ROW < y_coord + font_size/2) then
                if( A(VGA_RAM_ROW - y_coord_letter)(VGA_RAM_COL - x_coord_letter) = '1' ) then
                    IMG_R   <= on_state;
                    IMG_G   <= on_state;
                    IMG_B   <= on_state;
                end if;
            end if;
        end if;
    end if;
end process IMG_generator;

-------------------------------------
-- COORDINATE GENERATOR
-------------------------------------
COORD_generator: process(pixel_clk, rst)
begin
    if rising_edge(pixel_clk) then
        if rst = '1' then
            x_coord     <= min_x_coord;
            y_coord     <= min_y_coord;
            x_coord_letter <= 400;
            y_coord_letter <= 250;
        else
            -- Trigger the change of x_coord and y_coord
        end if;
    end if;
end process COORD_generator;
end Behavioral;
