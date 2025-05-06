--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        -- inputs
        clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(7 downto 0); -- operands and opcode
        btnU    :   in std_logic; -- reset
        btnC    :   in std_logic; -- fsm cycle
        
        -- outputs
        led :   out std_logic_vector(15 downto 0);
        -- 7-segment display segments (active-low cathodes)
        seg :   out std_logic_vector(6 downto 0);
        -- 7-segment display active-low enables (anodes)
        an  :   out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
  
	-- declare components and signals
	component controller_fsm is
    Port ( i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
    end component;
	
	component clock_divider is
	generic ( constant k_DIV : natural := 2	);
	port ( 	i_clk    : in std_logic;
			i_reset  : in std_logic;		   -- asynchronous
			o_clk    : out std_logic		   -- divided (slow) clock
	       );
	end component;
	
	component ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
    end component;
    
    component twos_comp is
    port (
        i_bin: in std_logic_vector(7 downto 0);
        o_sign: out std_logic;
        o_hund: out std_logic_vector(3 downto 0);
        o_tens: out std_logic_vector(3 downto 0);
        o_ones: out std_logic_vector(3 downto 0));
    end component;
    
    component  TDM4 is
	generic ( constant k_WIDTH : natural  := 4); -- bits in input and output
    Port ( i_clk		: in  STD_LOGIC;
           i_reset		: in  STD_LOGIC; -- asynchronous
           i_D3 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D2 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D1 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D0 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_data		: out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_sel		: out STD_LOGIC_VECTOR (3 downto 0));	-- selected data line (one-cold)
    end component;
    
    component sevenseg_decoder is
    Port ( i_Hex : in STD_LOGIC_VECTOR (3 downto 0);
           o_seg_n : out STD_LOGIC_VECTOR (6 downto 0));
    end component;
	
	signal f_A         : std_logic_vector(7 downto 0);
	signal f_B         : std_logic_vector(7 downto 0);
	signal w_cycle     : std_logic_vector(3 downto 0);
	signal w_reset     : std_logic;
	signal w_flags     : std_logic_vector(3 downto 0);
	signal w_clk       : std_logic;
	signal w_result    : std_logic_vector(7 downto 0);
	signal w_disp      : std_logic_vector(7 downto 0);
	signal w_D3        : std_logic;
	signal w_D2        : std_logic_vector(3 downto 0);
	signal w_D1        : std_logic_vector(3 downto 0);
	signal w_D0        : std_logic_vector(3 downto 0);
	signal w_sel       : std_logic_vector(3 downto 0);
	signal w_data      : std_logic_vector(3 downto 0);
	signal w_seg       : std_logic_vector(6 downto 0);
	signal w_an        : std_logic_vector(3 downto 0);
  
begin
	-- PORT MAPS ----------------------------------------
    controller_fsm_0 : controller_fsm
    port map( i_reset => w_reset,
              i_adv   => btnC,
              o_cycle => w_cycle(3 downto 0)
    );
    
    clock_divider_0 : clock_divider
	generic map( k_div   => 200000)
	port map( 	i_clk    => clk,
			    i_reset  => w_reset,		   -- asynchronous
			    o_clk    => w_clk		       -- divided (slow) clock
	);
	
	ALU_0 : ALU
    port map (  i_A => f_A,
                i_B => f_B,
                i_op => sw(2 downto 0),
                o_result => w_result,
                o_flags => w_flags(3 downto 0)
    );
    
    twos_comp_0 : twos_comp
    port map(
        i_bin => w_disp(7 downto 0),
        o_sign => w_D3,
        o_hund => w_D2(3 downto 0),
        o_tens => w_D1(3 downto 0),
        o_ones => w_D0(3 downto 0)
    );
    
    TDM4_0 : TDM4
	generic map( k_WIDTH => 4) -- bits in input and output
    port map (  i_clk		=> w_clk,
                i_reset		=> w_reset, -- asynchronous
                i_D3 		=> "0000",
		        i_D2 		=> w_D2,
		        i_D1 		=> w_D1,
		        i_D0 		=> w_D0,
		        o_data		=> w_data,
		        o_sel		=> w_sel	-- selected data line (one-cold)
    );
    
    sevenseg_decoder_0 : sevenseg_decoder
    port map( i_Hex     => w_data,
              o_seg_n   => w_seg
    );
	
	-- CONCURRENT STATEMENTS ----------------------------
	
	with w_cycle select
	w_disp <= f_A       when "0010",
	          f_B       when "0100",
	          w_result  when "1000",
	          x"00"     when others;
	          
	with w_cycle select
	an <= "1111"   when "0001",
	      w_sel    when others;
	      
	seg <= "1111111"   when (w_disp(7) = '0' and w_sel(3) = '0') else
	       "0111111"   when (w_disp(7) = '1' and w_sel(3) = '0') else
	       w_seg;  
	             
	led(15 downto 12) <= w_flags(3 downto 0);
	led(3 downto 0)   <= w_cycle(3 downto 0);
	
	w_reset <= btnU;
	
	--Register A with reset on w_cycle(1)--
	registerA_proc : process(w_cycle)
	begin
	   if rising_edge(w_cycle(1)) then
	       f_A <= sw;
	   end if;
    end process registerA_proc;
    
	--Register B with reset on w_cycle(2)--
	registerB_proc : process(w_cycle)
	begin
	   if rising_edge(w_cycle(2)) then
	       f_B <= sw;
	   end if;
    end process registerB_proc;
	
end top_basys3_arch;