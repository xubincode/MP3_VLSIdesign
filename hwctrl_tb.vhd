--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:45:12 07/18/2019
-- Design Name:   
-- Module Name:   /nas/ei/share/TUEIEDA/LabVLSI/ss19/ge52ceb/prj/playcontrol/hwctrl_tb.vhd
-- Project Name:  playcontrol
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: hwctrl
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
 
ENTITY hwctrl_tb IS
END hwctrl_tb;
 
ARCHITECTURE behavior OF hwctrl_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT hwctrl
    PORT(
        clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           mute : in STD_LOGIC;
			  pause : in STD_LOGIC;
			  incvol : in STD_LOGIC;
			  decvol : in STD_LOGIC;
			  dec_status : in STD_LOGIC; 
			  hw_full : in  STD_LOGIC;
			  pause_lcd : out std_logic;
			  mute_lcd : out std_logic;
			  vol_key : out std_logic;
           hw_din : out  STD_LOGIC_VECTOR (31 downto 0);
           hw_wr : out  STD_LOGIC
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal mute : std_logic := '0';
   signal hw_full : std_logic := '0';
	signal pause :  STD_LOGIC:= '0';
	signal incvol : STD_LOGIC:= '0';
	signal decvol :  STD_LOGIC:= '0';
	signal dec_status : STD_LOGIC:= '0'; 

 	--Outputs
   signal hw_din : std_logic_vector(31 downto 0);
   signal hw_wr : std_logic;
	signal pause_lcd : std_logic;
	signal mute_lcd : std_logic;
	signal vol_key : std_logic;
   -- Clock period definitions
   constant clk_period : time := 1us;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: hwctrl PORT MAP (
          clk => clk,
          reset => reset,
          mute => mute,
			 pause => pause,
			 incvol => incvol,
			 decvol => decvol,
			 dec_status => dec_status,
			 hw_full => hw_full,
			 pause_lcd => pause_lcd,
			 mute_lcd => mute_lcd,
			 vol_key => vol_key,
          hw_din => hw_din,
          hw_wr => hw_wr
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
      -- hold reset state for 100ms.
      wait for 10us;	
		
		hw_full <= '1';
		wait for 10us;
		hw_full <= '0';
		wait for 10 us;
		decvol <= '1';
		wait for 1 us;
		decvol <= '0';
		wait for 10 us;
		decvol <= '1';
		wait for 1 us;
		decvol <= '0';	
		wait for 10 us;
		incvol <= '1';
		wait for 1 us;
		incvol <= '0';
				wait for 10 us;

   end process;

END;
