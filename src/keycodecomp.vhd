----------------------------------------------------------------------------------
-- VLSI Design Lab
-- Engineer: Paula A. A. Graça
-- 
-- Create Date:    01:44:18 06/16/2019 
-- Design Name: 
-- Module Name:    keycodecomp - Behavioral 
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

entity keycodecomp is
    Port ( rd : out  STD_LOGIC;
           rd_ack : in  STD_LOGIC;
           data : in  STD_LOGIC_VECTOR (7 downto 0);
           empty : in  STD_LOGIC;
           listnext : out  STD_LOGIC;
           listprev : out  STD_LOGIC;
			  play : out STD_LOGIC;
			  stop : out STD_LOGIC;
			  pause : out STD_LOGIC;
			  mute : out STD_LOGIC;
			  incvol : out STD_LOGIC;
			  decvol : out STD_LOGIC;
			  forward : out STD_LOGIC;
			  backward : out STD_LOGIC;
			  preview :out STD_LOGIC
			  );
end keycodecomp;

architecture Behavioral of keycodecomp is

begin

	comp : process (rd_ack, data)
	begin
		if rd_ack = '1' then
			case data is
				when x"72" => -- NEXTFILE
					listnext <= '1';
					listprev <= '0';
					stop <= '0';
					play <= '0';
					pause <= '0';
					mute <= '0';
					incvol <= '0';
					decvol <= '0';
					forward <= '0';
					backward <= '0';
					preview <= '0';
				when x"75" => -- PREVFILE
					listprev <= '1';
					listnext <= '0';
					stop <= '0';
					play <= '0';
					pause <= '0';
					mute <= '0';
					incvol <= '0';
					decvol <= '0';
					forward <= '0';
					backward <= '0';
					preview <= '0';
				when x"76" => --PLAY
					play <= '1';
					listnext <= '0';
					listprev <= '0';	
					stop <= '0';
					pause <= '0';
					mute <= '0';
					incvol <= '0';
					decvol <= '0';
					forward <= '0';
					backward <= '0';
					preview <= '0';
				when x"14" => -- STOP
					stop <= '1';
					play <= '0';
					listnext <= '0';
					listprev <= '0';
					pause <= '0';		
					mute <= '0';	
					incvol <= '0';	
					decvol <= '0';
					forward <= '0';
					backward <= '0';
					preview <= '0';					
				when x"11" => -- PAUSE
					pause <= '1';
					listnext <= '0';
					listprev <= '0';	
					stop <= '0';
					play <= '0';
					mute <= '0';
					incvol <= '0';
					decvol <= '0';
					forward <= '0';
					backward <= '0';
					preview <= '0';
				when x"66" => --MUTE
					mute <= '1';
					listnext <= '0';
					listprev <= '0';
					stop <= '0';
					play <= '0';
					pause <= '0';
					incvol <= '0';
					decvol <= '0';
					forward <= '0';
					backward <= '0';
					preview <= '0';
				when x"79" => 	-- INCVOL
					incvol <= '1';
					listnext <= '0';
					listprev <= '0';
					stop <= '0';
					play <= '0';
					pause <= '0';
					mute <= '0';
					decvol <= '0';
					forward <= '0';
					backward <= '0';
					preview <= '0';
				when x"7B" =>  -- DECVOL
					decvol <= '1';
					listnext <= '0';
					listprev <= '0';
					stop <= '0';
					play <= '0';
					pause <= '0';
					mute <= '0';
					incvol <= '0';
					forward <= '0';
					backward <= '0';
					preview <= '0';
				when x"74" =>  -- FORWARD
					forward <= '1';
					listnext <= '0';
					listprev <= '0';
					stop <= '0';
					play <= '0';
					pause <= '0';
					mute <= '0';
					incvol <= '0';
					decvol <= '0';
					backward <= '0';
					preview <= '0';
				when x"6B" =>  -- BACKWARD
					backward <= '1';
					listnext <= '0';
					listprev <= '0';
					stop <= '0';
					play <= '0';
					pause <= '0';
					mute <= '0';
					incvol <= '0';
					decvol <= '0';
					forward <= '0';
					preview <= '0';
				when x"5A" =>
					preview <= '1';
					listnext <= '0';
					listprev <= '0';
					stop <= '0';
					play <= '0';
					pause <= '0';
					mute <= '0';
					incvol <= '0';
					decvol <= '0';
					forward <= '0';
					backward <= '0';
				when others =>
					listnext <= '0';
					listprev <= '0';
					stop <= '0';
					play <= '0';
					pause <= '0';
					mute <= '0';
					incvol <= '0';
					decvol <= '0';
					forward <= '0';
					backward <= '0';
					preview <= '0';
			end case;
		else 
			listnext <= '0';
			listprev <= '0';
			stop <= '0';
			play <= '0';
			pause <= '0';
			mute <= '0';
			incvol <= '0';
			decvol <= '0';
			forward <= '0';
			backward <= '0';
			preview <= '0';
		end if;
	end process;
	
	rd <= NOT empty;

end Behavioral;

