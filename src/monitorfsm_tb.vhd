--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:03:29 07/10/2019
-- Design Name:   
-- Module Name:   /nas/ei/share/TUEIEDA/LabVLSI/ss19/ge52ceb/prj/playcontrol/monitorfsm_tb.vhd
-- Project Name:  playcontrol
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: monitorfsm
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
 
ENTITY monitorfsm_tb IS
END monitorfsm_tb;
 
ARCHITECTURE behavior OF monitorfsm_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT monitorfsm
    PORT(
			  clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           enable_mon : in  STD_LOGIC;
           file_size : in  STD_LOGIC_vector (31 downto 0); -- 4 bytes
           busy : in  STD_LOGIC;
           dbuf_almost_full : in  STD_LOGIC;
			  busov: in STD_LOGIC;
           gnt : in  STD_LOGIC;
			  dec_status : in std_logic;
			  sbuf_full : in std_logic;
			  forward : in std_logic;
           req : out  STD_LOGIC;
           busiv : out  STD_LOGIC;
           busi : out  STD_LOGIC_VECTOR (7 downto 0);
           ctrl : out  STD_LOGIC;
			  dbuf_wr : out STD_LOGIC;
			  playfile_end : out STD_LOGIC
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal enable_mon : std_logic := '0';
   signal file_size : std_logic_vector (31 downto 0) := x"00000BFF";
   signal busy : std_logic := '0';
   signal dbuf_almost_full : std_logic := '0';
	signal busov : STD_LOGIC := '0';
   signal gnt : std_logic := '0';
	signal dec_status : std_logic := '0';
	signal sbuf_full : std_logic := '0';
	signal forward : std_logic := '0';
 	--Outputs
   signal req : std_logic;
   signal busiv : std_logic;
   signal busi : std_logic_VECTOR (7 downto 0);
   signal ctrl : std_logic;
   signal dbuf_wr : std_logic;
   signal playfile_end : std_logic;

   -- Clock period definitions
   constant clk_period : time := 1us;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: monitorfsm PORT MAP (
          clk => clk,
          reset => reset,
          enable_mon => enable_mon,
          file_size => file_size,
          busy => busy,
          dbuf_almost_full => dbuf_almost_full,
			 busov => busov,
          gnt => gnt,
			 dec_status => dec_status,
			 sbuf_full => sbuf_full,
			 forward => forward,
          req => req,
          busiv => busiv,
          busi => busi,
          ctrl => ctrl,
          dbuf_wr => dbuf_wr,
          playfile_end => playfile_end
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
      reset <= '1', '0' after 2 us;
      -- hold reset state for 100ms.
      wait for 10us;	
file_size <= x"00000010";
enable_mon <= '1';
--enable_mon <= '1' after 1 us, '0' after 2 us, '1' after 3 us;	--'0' after 37 us;
--dbuf_almost_full <= '1', '0' after 4 us, '1' after 9 us, '0' after 34 us, '1' after 39 us, '0' after 64 us, '1' after 69 us, '0' after 94 us, '1' after 99 us;
busy <= '1' after 1 us, '0' after 6 us, '1' after 7 us, '0' after 9 us, '1' after 10 us, '0' after 13 us,
'1' after 31 us, '0' after 36 us, '1' after 37 us, '0' after 39 us, '1' after 40 us, '0' after 43 us,
'1' after 61 us, '0' after 66 us, '1' after 67 us, '0' after 69 us, '1' after 70 us, '0' after 73 us,
'1' after 91 us, '0' after 96 us, '1' after 97 us, '0' after 99 us, '1' after 100 us, '0' after 103 us;
gnt <= '1' after 6 us, '0' after 10 us,'1' after 36 us, '0' after 40 us,'1' after 66 us, '0' after 70 us,'1' after 96 us, '0' after 100 us;
      wait for clk_period*10;
--dec_status <= '0', '1' after 60 us;


forward <= '1' after 20 us, '0' after 21 us;
      -- insert stimulus here 
busov <= '1' after 3 us, '0' after 12 us;

      wait;
   end process;

END;
