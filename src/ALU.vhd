----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:50:18 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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

entity ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is

    component  ripple_adder is
    Port ( A : in STD_LOGIC_VECTOR (3 downto 0);
           B : in STD_LOGIC_VECTOR (3 downto 0);
           Cin : in STD_LOGIC;
           S : out STD_LOGIC_VECTOR (3 downto 0);
           Cout : out STD_LOGIC);
    end component ripple_adder;
    
    signal w_carry         : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal w_B_logic       : STD_LOGIC_VECTOR(7 downto 0) := x"00";
    signal w_S_ripple_out  : STD_LOGIC_VECTOR(7 downto 0) := x"00";
    signal w_Result        : STD_LOGIC_VECTOR(7 downto 0) := x"00";
    
begin

    --Adder--
    ripple_adder_0: ripple_adder
    port map(
        A   => i_A(3 downto 0),
        B   => w_B_logic(3 downto 0),
        Cin => i_op(0),
        S   => w_S_ripple_out(3 downto 0),
        Cout => w_carry(0)
    );
    
    ripple_adder_1: ripple_adder
    port map(
        A   => i_A(7 downto 4),
        B   => w_B_logic(7 downto 4),
        Cin => w_carry(0),
        S   => w_S_ripple_out(7 downto 4),
        Cout => w_carry(1)
    );
    
    --Input Logic--
    with i_op(0) select
    w_B_logic <= i_B      when '0',
                 NOT i_B  when '1',
                 i_B      when others;
                 
    --ALU Control--
    with i_op select
    w_Result <= w_S_ripple_out when "000",
                w_S_ripple_out when "001",
                i_A AND i_B    when "010",
                i_A OR i_B     when "011",
                x"00"          when others;
                
    --Flag Logic--
    --V / Overflow--
    o_flags(0) <= (NOT(i_op(0) XOR i_A(7) XOR i_B(7))) AND (i_A(7) XOR w_S_ripple_out(7)) AND (NOT i_op(1));
    --C / Carry--
    o_flags(1) <= (NOT i_op(1)) AND w_carry(1);
    --Z / zero--
    o_flags(2) <= not (w_Result(7) or w_Result(6) or w_Result(5) or w_Result(4) or
                   w_Result(3) or w_Result(2) or w_Result(1) or w_Result(0));
    --N / Negative--
    o_flags(3) <= w_Result(7);
    
    --Output Logic--
    o_result <= w_Result;

end Behavioral;