----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:42:49 PM
-- Design Name: 
-- Module Name: controller_fsm - FSM
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

entity controller_fsm is
    Port ( i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
end controller_fsm;

architecture FSM of controller_fsm is

    --Define State Types--
    type sm_state is (reset, loadA, loadB, displayResult);	
    
	signal current_state, next_state: sm_state;

begin

    --Next State Logic--
    next_state <= reset             when current_state = displayResult  else
                  loadA             when current_state = reset          else
                  loadB             when current_state = loadA          else
                  displayResult     when current_state = loadB          else
                  reset; 
    
    --Output Logic--
    with current_state select
    o_cycle <= "0001" when reset,
               "0010" when loadA,
               "0100" when loadB,
               "1000" when displayResult,
               "0000" when others;        

-- State register ------------
    --asynchronous reset b/c I would have to add a clock signal to make it synchronous
	state_register : process(i_adv, i_reset)
	begin
        if i_reset = '1' then
            current_state <= reset;
        elsif rising_edge(i_adv) then
            current_state <= next_state;
        end if;
	end process state_register;
	
end FSM;