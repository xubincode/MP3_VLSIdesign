--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   02:16:47 06/16/2019
-- Design Name:   
-- Module Name:   /nas/ei/share/TUEIEDA/LabVLSI/ss19/ge52ceb/prj/playcontrol/keycodecomp_tb.vhd
-- Project Name:  playcontrol
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: keycodecomp
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
 
ENTITY keycodecomp_tb IS
END keycodecomp_tb;
 
ARCHITECTURE behavior OF keycodecomp_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT keycodecomp
    PORT(
         rd : OUT  std_logic;
         rd_ack : IN  std_logic;
         data : IN  std_logic_vector (7 downto 0);
         empty : IN  std_logic;
         listnext : OUT  std_logic;
         listprev : OUT  std_logic;
			play : out STD_LOGIC;
			stop : out STD_LOGIC
        );
    END COMPONENT;
    

   --Inputs
   signal rd_ack : std_logic := '0';
   signal data : std_logic_vector (7 downto 0):= x"00";
   signal empty : std_logic := '0';

 	--Outputs
   signal rd : std_logic;
   signal listnext : std_logic;
   signal listprev : std_logic;
	signal play : STD_LOGIC;
	signal stop : STD_LOGIC;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: keycodecomp PORT MAP (
          rd => rd,
          rd_ack => rd_ack,
          data => data,
          empty => empty,
          listnext => listnext,
          listprev => listprev,
			 play => play,
			 stop => stop
        );
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100ms.
		data <= x"76"; -- play
      wait for 10ms;	
		rd_ack <= '1';
      wait for 10ms;
		rd_ack <= '0';
		data <= x"75"; -- listprev
		wait for 10ms;
		rd_ack <= '1';
		data <= x"72"; -- listnext
		wait for 10ms;
		rd_ack <= '1';
		data <= x"14"; -- stop
		wait for 10ms;
		rd_ack <= '1';

      -- insert stimulus here 

      wait;
   end process;

END;
