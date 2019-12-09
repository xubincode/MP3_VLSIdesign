--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:41:17 06/16/2019
-- Design Name:   
-- Module Name:   /nas/ei/share/TUEIEDA/LabVLSI/ss19/ge52ceb/prj/playcontrol/listctrl_tb.vhd
-- Project Name:  playcontrol
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: listctrl
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
 
ENTITY listctrl_tb IS
END listctrl_tb;
 
ARCHITECTURE behavior OF listctrl_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT listctrl
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         listnext : IN  std_logic;
         listprev : IN  std_logic;
         req : OUT  std_logic;
         gnt : IN  std_logic;
         busi : OUT  std_logic_vector(7 downto 0);
         busiv : OUT  std_logic;
         ctrl : OUT  std_logic;
         busy : IN  std_logic;
         info_start : OUT  std_logic;
         info_ready : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal listnext : std_logic := '0';
   signal listprev : std_logic := '0';
   signal gnt : std_logic := '0';
   signal busy : std_logic := '0';
   signal info_ready : std_logic := '0';

 	--Outputs
   signal req : std_logic;
   signal busi : std_logic_vector(7 downto 0);
   signal busiv : std_logic;
   signal ctrl : std_logic;
   signal info_start : std_logic;

   -- Clock period definitions
   constant clk_period : time := 1ms;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: listctrl PORT MAP (
          clk => clk,
          reset => reset,
          listnext => listnext,
          listprev => listprev,
          req => req,
          gnt => gnt,
          busi => busi,
          busiv => busiv,
          ctrl => ctrl,
          busy => busy,
          info_start => info_start,
          info_ready => info_ready
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
	
		reset <= '0';
      wait for 10us;	
		listnext <= '1' after 2 ms, '0' after 6 ms;
		listprev <= '1' after 13 ms, '0' after 14 ms;
		busy <= '1' after 1 ms, '0' after 3 ms, '1' after 12 ms, '0' after 18 ms;
		gnt <= '1' after 4 ms, '0' after 5 ms, '1' after 19 ms, '0' after 20 ms;
		info_ready <= '1' after 7 ms, '0' after 9 ms;
		reset <= '1' after 22 ms;

      wait;
   end process;

END;
