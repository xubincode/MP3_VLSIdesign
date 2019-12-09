----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:30:43 07/17/2019 
-- Design Name: 
-- Module Name:    hwctrl - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.system_constants_pkg.all;

entity hwctrl is
    Port ( clk : in  STD_LOGIC;
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
			  vol_num : out unsigned (4 downto 0);
           hw_din : out  STD_LOGIC_VECTOR (31 downto 0);
           hw_wr : out  STD_LOGIC
			  );
end hwctrl;

architecture Behavioral of hwctrl is

	signal mute_aux : std_logic;
	signal LC : std_logic_vector (4 downto 0):= "00000"; -- max volume
	signal RC : std_logic_vector (4 downto 0):= "00000"; -- max volume
	signal vol_key_aux : std_logic ;

begin

IBUFcontrol	: process (clk,reset,mute)
begin
	
	if reset = reset_state then
		hw_wr <= '0';
		hw_din <= "00000000000000000000000000000000";
		mute_aux <= '0';
		pause_lcd <= '0';
		vol_key <= '0';
		vol_key_aux <= '0';
	
	elsif clk'event AND clk = clk_polarity then
	
		if	hw_full = '0' AND dec_status = '0' then
			if	mute = '1' AND mute_aux = '0' then 	-- MUTE
					hw_din <= "10000000000000001000000000000000";
					hw_wr <= '1';
					mute_aux <= '1';
					
					pause_lcd <= '0';
					vol_key <= '0';
					vol_key_aux <= '0';
					mute_lcd <= '1';

			elsif mute = '1' AND mute_aux = '1' then
					hw_din <= "1000000000000000000" & LC & "000" & RC;
					hw_wr <= '1';
					mute_aux <= '0';
					
					pause_lcd <= '0';
					vol_key <= '0';
					vol_key_aux <= '0';
					mute_lcd <= '1';
					
			elsif pause = '1' then			-- PAUSE
					hw_din <= "10010000000000000000000000000000";
					hw_wr <= '1';
					
					pause_lcd <= '1';
					vol_key <= '0';
					vol_key_aux <= '0';
					mute_lcd <= '0';
					
			elsif incvol = '1' then		-- INCREASE VOL
					if LC > "00000" then
						LC <= LC - 1;
					else 
						LC <= "00000";
					end if;
					if RC > "00000" then
						RC <= RC - 1;
					else 
						RC <= "00000";
					end if;
					
					pause_lcd <= '0';
					vol_key_aux <= '1';
					mute_lcd <= '0';
					
			elsif decvol = '1' then		--DECREASE VOL
					if LC < "11111" then
						LC <= LC + 1;
					else 
						LC <= "11111";
					end if;
					if RC < "11111" then
						RC <= LC + 1;
					else 
						RC <= "11111";
					end if;
					
					pause_lcd <= '0';
					vol_key_aux <= '1';
					mute_lcd <= '0';
					
			elsif vol_key_aux = '1' then
					hw_din <= "1000000000000000000" & LC & "000" & RC;
					hw_wr <= '1';
					vol_key <= '1';
					vol_key_aux <= '0';
					vol_num <= unsigned (RC);
			
			else	
					hw_wr <= '0';
					hw_din <= "00000000000000000000000000000000";
					
					pause_lcd <= '0';
					vol_key <= '0';
					mute_lcd <= '0';
					vol_key_aux <= '0';
					
			end if;
			
		end if;
	end if;
	
end process;
	

end Behavioral;

