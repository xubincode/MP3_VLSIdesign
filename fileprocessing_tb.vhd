--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   02:15:31 07/02/2019
-- Design Name:   
-- Module Name:   /nas/ei/share/TUEIEDA/LabVLSI/ss19/ge52ceb/prj/playcontrol/fileprocessing_tb.vhd
-- Project Name:  playcontrol
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: fileprocessing
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
 
ENTITY fileprocessing_tb IS
END fileprocessing_tb;
 
ARCHITECTURE behavior OF fileprocessing_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT fileprocessing
    PORT(
         clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           busov : in  STD_LOGIC;
           buso : in  STD_LOGIC_VECTOR (31 downto 0); --file information or file data
           info_start : in  STD_LOGIC;
           lcdc_busy : in  STD_LOGIC;
			  pause : in std_logic;
			  mute : in std_logic;
			  vol_key : in std_logic;
			  vol_num : in unsigned (4 downto 0);
			  forward : in std_logic;
			  backward : in std_logic;
			  percent : in STD_LOGIC_VECTOR(31 downto 0);
           file_size : out  STD_LOGIC_VECTOR (31 downto 0);
           chrm_wdata : out  STD_LOGIC_VECTOR (7 downto 0) ;
           chrm_addr : out  STD_LOGIC_VECTOR (7 downto 0); --pag.41
           chrm_wr : out  STD_LOGIC;
           lcdc_cmd : out  STD_LOGIC_VECTOR (1 downto 0);
           info_ready : out  STD_LOGIC
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal busov : std_logic := '0';
   signal buso : std_logic_vector(31 downto 0) := (others => '0');
   signal info_start : std_logic := '0';
   signal lcdc_busy : std_logic := '0';
	signal pause : std_logic := '0';
	signal mute : std_logic := '0';
	signal vol_key : std_logic := '0';
	signal vol_num : unsigned (4 downto 0) := (others => '0');
	signal forward : std_logic;
	signal backward : std_logic;
	signal percent : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

 	--Outputs
   signal file_size : std_logic_VECTOR (31 downto 0);
   signal chrm_wdata : std_logic_vector(7 downto 0);
   signal chrm_addr : std_logic_vector(7 downto 0);
   signal chrm_wr : std_logic;
   signal lcdc_cmd : std_logic_vector(1 downto 0);
   signal info_ready : std_logic;

   -- Clock period definitions
   constant clk_period : time := 1ms;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: fileprocessing PORT MAP (
          clk => clk,
          reset => reset,
          busov => busov,
          buso => buso,
          info_start => info_start,
          lcdc_busy => lcdc_busy,
			 pause => pause,
			 mute => mute,
			 vol_key => vol_key,
			 vol_num => vol_num,
			 forward => forward,
			 backward => backward,
			 percent => percent,
          file_size => file_size,
          chrm_wdata => chrm_wdata,
          chrm_addr => chrm_addr,
          chrm_wr => chrm_wr,
          lcdc_cmd => lcdc_cmd,
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
      reset <= '1' after 1 ms, '0' after 2 ms;
       wait for 10us;	
		 
			info_start <= '1' after 1 ms, '0' after 2 ms;
			busov <= '1' after 1 ms, '0' after 10 ms;
			buso <= x"10111213" after 2 ms, x"20212223" after 3 ms, x"30313233" after 4 ms;
			lcdc_busy <= '1' after 1 ms, '0' after 30 ms, '1' after 31 ms;
			pause <= '1' after 5 ms, '0' after 6 ms, '1' after 8 ms, '0' after 9 ms;
			mute <= '1' after 10 ms, '0' after 11ms;
			vol_key <= '1' after 18 ms, '0' after 19 ms;
			wait for clk_period*10;
			percent <= "00000000000000000000000000001000";

      wait;

   end process;

END;
