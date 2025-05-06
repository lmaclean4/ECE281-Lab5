----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/25/2025 12:37:48 PM
-- Design Name: 
-- Module Name: sevenseg_decoder - Behavioral
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

entity sevenseg_decoder is
    Port (
        i_Hex   : in  STD_LOGIC_VECTOR(3 downto 0);
        o_seg_n : out STD_LOGIC_VECTOR(6 downto 0)
    );
end sevenseg_decoder;

architecture Behavioral of sevenseg_decoder is
    -- Internal signal: standard order (a, b, c, d, e, f, g)
    signal seg_int : STD_LOGIC_VECTOR(6 downto 0);
begin
    process(i_Hex)
    begin
        case i_Hex is
            when "0000" =>  -- 0: segments a,b,c,d,e,f on; g off
                seg_int <= "0000001";
            when "0001" =>  -- 1: segments b,c on; others off
                seg_int <= "1001111";
            when "0010" =>  -- 2: segments a,b,d,e,g on
                seg_int <= "0010010";
            when "0011" =>  -- 3: segments a,b,c,d,g on
                seg_int <= "0000110";
            when "0100" =>  -- 4: segments b,c,f,g on
                seg_int <= "1001100";
            when "0101" =>  -- 5: segments a,c,d,f,g on
                seg_int <= "0100100";
            when "0110" =>  -- 6: segments a,c,d,e,f,g on
                seg_int <= "0100000";
            when "0111" =>  -- 7: segments a,b,c on
                seg_int <= "0001111";
            when "1000" =>  -- 8: all segments on
                seg_int <= "0000000";
            when "1001" =>  -- 9: segments a,b,c,d,f,g on
                seg_int <= "0001100";
            when "1010" =>  -- A: segments a,b,c,e,f,g on
                seg_int <= "0001000";
            when "1011" =>  -- B: segments c,d,e,f,g on (lowercase "b")
                seg_int <= "1100000";
            when "1100" =>  -- C: segments a,d,e,f on
                seg_int <= "1110010";
            when "1101" =>  -- D: segments b,c,d,e,g on
                seg_int <= "1000010";
            when "1110" =>  -- E: segments a,d,e,f,g on
                seg_int <= "0110000";
            when "1111" =>  -- F: segments a,e,f,g on
                seg_int <= "0111000";
            when others =>
                seg_int <= "1111111"; -- All off if invalid input
        end case;
    end process;
    
    -- Reverse the order to match board wiring:
    -- Basys3_Master.xdc maps seg[0] to segment a (physical W7) and seg[6] to segment g.
    o_seg_n(0) <= seg_int(6);
    o_seg_n(1) <= seg_int(5);
    o_seg_n(2) <= seg_int(4);
    o_seg_n(3) <= seg_int(3);
    o_seg_n(4) <= seg_int(2);
    o_seg_n(5) <= seg_int(1);
    o_seg_n(6) <= seg_int(0);
end Behavioral;

