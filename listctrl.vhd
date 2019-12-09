----------------------------------------------------------------------------------
-- VLSI Design Lab
-- Engineer: Paula A. A. Graça
-- 
-- Create Date:    03:03:25 06/16/2019 
-- Design Name: 
-- Module Name:    listctrl - Behavioral 
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

entity listctrl is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           listnext : in  STD_LOGIC;
           listprev : in  STD_LOGIC;
           req : out  STD_LOGIC; 
           gnt : in  STD_LOGIC;
           busi : out  STD_LOGIC_VECTOR (7 downto 0); 
           busiv : out  STD_LOGIC; 
           ctrl : out  STD_LOGIC; 
           busy : in  STD_LOGIC;
           info_start : out  STD_LOGIC;
           info_ready : in  STD_LOGIC);
end listctrl;

architecture Behavioral of listctrl is
	
	type state is (idle, wrdy, winfo);
	signal curr_state : state := idle;

begin
-- calculates next state and sets output values
next_n_out: process (clk, reset)
	begin 
		-- reset
		if reset =  '1' then
			curr_state <= idle;
			req <= '0';
			busiv <= '0';
			--ctrl <= '-';
			info_start <= '0';
			
		elsif clk = '1' and clk'event then
			case curr_state is 
				when idle =>
								-- A1
								if listnext = '0' and listprev = '0' then 
									curr_state <= idle;
									req <= '0';
									busiv <= '0';
									--ctrl <= '-';
									info_start <= '0';
								-- A2
								else 
									curr_state <= wrdy;
									req <= '1';
									busiv <= '0';
									--ctrl <= '-';
									info_start <= '0';
									if listnext = '1' then
										busi <= x"00";
									else -- listprev ='1'
										busi <= x"01";
									end if;
								end if;
				L
				when wrdy =>
								-- A3
								if gnt = '0' OR busy = '1' then 
									curr_state <= wrdy;
									req <= '1';
									busiv <= '0';
									--ctrl <= '-';
									info_start <= '0';
								-- A4
								else -- gnt = '1' AND busy = '0'
									curr_state <= winfo;
									req <= '1';
									busiv <= '1';
									ctrl <= '1';
									info_start <= '1';
									
								end if;
								
				when winfo =>
								-- A5
								if info_ready = '0' then
								curr_state <= winfo;
								req <= '1';
								busiv <= '0';
								--ctrl <= '-';
								info_start <= '0';
								-- A6
								else -- info_ready = '1'
								curr_state <= idle;
								req <= '0';
								busiv <= '0';
								--ctrl <= '-';
								info_start <= '0';
								end if;
			end case;
		end if;
	end process;


end Behavioral;
