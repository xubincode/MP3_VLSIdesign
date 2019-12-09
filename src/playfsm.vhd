----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:53:13 07/09/2019 
-- Design Name: 
-- Module Name:    playfsm - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.system_constants_pkg.all;

entity playfsm is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           gnt : in  STD_LOGIC;
           busy : in  STD_LOGIC;
           play : in  STD_LOGIC;
           stop : in  STD_LOGIC;
			  pause : in STD_LOGIC;
			  mute : in STD_LOGIC;
			  incvol : in STD_LOGIC;
			  decvol : in STD_LOGIC;
			  forward : in STD_LOGIC;
			  backward : in STD_LOGIC;
           playfile_end : in  STD_LOGIC;
			  listnext : in  STD_LOGIC; -- //
           listprev : in  STD_LOGIC; --//
			  playing : out std_logic;
           req : out  STD_LOGIC;
           ctrl : out  STD_LOGIC;
           busiv : out  STD_LOGIC;
           busi : out  STD_LOGIC_VECTOR (7 downto 0);
			  track_end : out STD_LOGIC; -- output that informs if track ended outside the play/monitor
           enable_mon : out  STD_LOGIC;
			  pause_out : out STD_LOGIC;
			  mute_out : out STD_LOGIC;
			  incvol_out : out STD_LOGIC;
			  decvol_out : out STD_LOGIC;
			  forward_out : out STD_LOGIC;
			  backward_out : out STD_LOGIC;
			  dec_rst : out std_logic;
			  dbuf_rst : out std_logic;
			  sbuf_rst : out std_logic
			  );		  
end playfsm;

architecture Behavioral of playfsm is

	type state is (IDLE, REQINFO, PLAYON);
	signal next_state : state := IDLE;
	
	signal counter : std_logic_vector (19 downto 0) := "00000000000000000000";
	
begin

playfsm : process (clk, reset)
begin
		if reset = reset_state then
			next_state <= IDLE;
			req <= '0';
			busiv <= '0';
			busi <= x"00"; -- FILENEXT
			enable_mon <= '0';
			track_end <= '0';
			dec_rst <= '0';
			dbuf_rst <= '0';
			sbuf_rst <= '0';
			mute_out <= '0';
			incvol_out <= '0';
			decvol_out <= '0';
			forward_out <= '0';
			backward_out <= '0';
			
		elsif clk'event and clk=clk_polarity then
		
		-------------------- FEATURES SIGNALS --------------------------	
			if mute = '1' then			-- MUTE
				mute_out <= '1';
			else
				mute_out <= '0';
			end if;
			
			if pause = '1' then			-- PAUSE
				pause_out <= '1';
			else
				pause_out <= '0';
			end if;
						
			if incvol = '1' then			-- INC VOLUME
				incvol_out <= '1';
			else
				incvol_out <= '0';
			end if;
			
			if decvol = '1' then			-- INC VOLUME
				decvol_out <= '1';
			else
				decvol_out <= '0';
			end if;
			
			if forward = '1' then 		-- FFSEEK
				forward_out <= '1';
				dec_rst <= '1';
			else
				forward_out <= '0';
				dec_rst <= '0';
			end if;
			
			if backward = '1' then 		-- BFSEEK
				backward_out <= '1';
				dec_rst <= '1';
			else
				backward_out <= '0';
				dec_rst <= '0';
			end if;
			
		-------------------- PLAY FSM --------------------------
			case next_state is
				when IDLE => 
									-- A1
									if play = '1' AND busy = '0' then
										next_state <= REQINFO;
										req <= '1'; -- request access to FIO
										busiv <= '0';
										enable_mon <= '0';
										track_end <= '0';
										dec_rst <= '1';
									   dbuf_rst <= '1';
									   sbuf_rst <= '1';
										playing <= '0';
									
									-- A2
									else 
										next_state <= IDLE;
										req <= '0';
										busiv <= '0';
										enable_mon <= '0';
										track_end <= '0';
										playing <= '0';
										--pause_out <= '0';
									end if;
				when REQINFO =>
									-- A3 
									if gnt = '1' AND busy = '0' then
										next_state <= PLAYON;
										req <= '1'; 
										busiv <= '1';
										enable_mon <= '1'; 
										dec_rst <= '0';
									   dbuf_rst <= '0';
									   sbuf_rst <= '0';
										playing <= '1';
									-- A4
									else 
										next_state <= REQINFO;
										req <= '1'; -- request access to FIO
										busi <= x"03"; -- send OPEN command to FIO
										ctrl <= '1';
										busiv <= '0';
										enable_mon <= '0';
										track_end <= '0';
										dec_rst <= '0';
									   dbuf_rst <= '0';
									   sbuf_rst <= '0';
										playing <= '0';
										
									end if;
				when PLAYON =>	
				
									-- A5
									if playfile_end = '1' OR stop = '1' OR listprev = '1' OR listnext = '1' then
										next_state <= IDLE;
										track_end <= '1';
										req <= '0';
										busiv <= '0';
										ctrl <= '0';
										enable_mon <= '0';
										playing <= '0';
									
									-- A6
									else -- playfile_end = '0' AND stop = '0'	
										next_state <= PLAYON;
										req <= '0'; 
										busiv <= '0';
										enable_mon <= '1'; 
										playing <= '1';
										
									end if;
				when others => 
									next_state <= IDLE;
				end case;
		end if;
	end process;

end Behavioral;

