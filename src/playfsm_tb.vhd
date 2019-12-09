--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:52:27 07/09/2019
-- Design Name:   
-- Module Name:   /nas/ei/share/TUEIEDA/LabVLSI/ss19/ge52ceb/prj/playcontrol/playfsm_tb.vhd
-- Project Name:  playcontrol
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: playfsm
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY playfsm_tb IS
END playfsm_tb;
 
ARCHITECTURE behavior OF playfsm_tb IS 
 
    COMPONENT playfsm
    PORT(
			  clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           gnt : in  STD_LOGIC;
           busy : in  STD_LOGIC;
           play : in  STD_LOGIC;
           stop : in  STD_LOGIC;
           playfile_end : in  STD_LOGIC;
			  listnext : in  STD_LOGIC;
           listprev : in  STD_LOGIC;
           req : out  STD_LOGIC;
           ctrl : out  STD_LOGIC;
           busiv : out  STD_LOGIC;
           busi : out  STD_LOGIC_VECTOR (7 downto 0);
			  track_end : out STD_LOGIC;
           enable_mon : out  STD_LOGIC;
			  dec_rst : out std_logic
			  --ibuf_command : out std_logic_vector (2 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal gnt : std_logic := '0';
   signal busy : std_logic := '0';
   signal play : std_logic := '0';
   signal stop : std_logic := '0';
   signal playfile_end : std_logic := '0';
	signal listnext : STD_LOGIC := '0';
   signal listprev : STD_LOGIC := '0';

 	--Outputs
   signal req : std_logic;
   signal ctrl : std_logic;
   signal busiv : std_logic;
   signal busi : std_logic_vector (7 downto 0);
	signal track_end : STD_LOGIC;
   signal enable_mon : std_logic;
	signal dec_rst : std_logic;
	--signal ibuf_command : std_logic_vector (2 downto 0);

   -- Clock period definitions
   constant clk_period : time := 1us;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: playfsm PORT MAP (
          clk => clk,
          reset => reset,
          gnt => gnt,
          busy => busy,
          play => play,
          stop => stop,
          playfile_end => playfile_end,
			 listnext => listnext,
			 listprev => listprev,
          req => req,
          ctrl => ctrl,
          busiv => busiv,
          busi => busi,
			 track_end => track_end,
          enable_mon => enable_mon,
			 dec_rst => dec_rst
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		

      reset <= '1' after 3 us, '0' after 4 us;
		wait for 5 us;
		play <= '1' after 3 us, '0' after 4 us;
		playfile_end <= '1' after 15 us;
		gnt <= '1' after 7 us, '0' after 10 us;
		busy <= '1' after 5 us, '0' after 8 us;
		wait for 15 us;
		listnext <= '1';
		wait for clk_period*10;

   end process;

END;
