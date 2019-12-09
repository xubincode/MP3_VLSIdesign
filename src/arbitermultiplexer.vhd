----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:52:38 06/28/2019 
-- Design Name: 
-- Module Name:    arbitermultiplexer - Behavioral 
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
library work;
use work.system_constants_pkg.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity arbitermultiplexer is
	generic (
		M : integer := 10;
		N : integer := 3
		);
	port (
		clk : in std_logic ;
		reset : in std_logic ;
		input : in std_logic_vector ( M *N -1 downto 0);
		output : out std_logic_vector (M -1 downto 0);
		req : in std_logic_vector (N -1 downto 0);
		gnt : out std_logic_vector (N -1 downto 0)
		);
end arbitermultiplexer;

architecture Behavioral of arbitermultiplexer is
signal enable : std_logic := '0';
signal gnt_in_reg : std_logic_vector(N-1 downto 0);
signal gnt_out_reg : std_logic_vector(N-1 downto 0);
begin

	gnt <= gnt_out_reg;
	-- calculate output gnt value
	arbitration_logic : process (req)
	variable aux_req : std_logic := '0';
	begin
		-- navigate gnt
		for i in 0 to (N-1) loop 
			if i = 0 then
				gnt_in_reg(0) <= req(0);
			else
				-- begin always from index 0
				aux_req := '0';
				-- navigate req
				for curr in 0 to i loop
					-- if not in the last element -> OR
					if curr /= i then
						aux_req := aux_req OR req(curr);
					-- if in the last element -> AND
					else
						aux_req := not(aux_req) AND req(i);
					end if;
				end loop;
				gnt_in_reg(i) <= aux_req;
				
			end if;
		end loop;
	end process;
	
	-- calculate enable
	enable_calc : process (gnt_out_reg, req)
	--internal auxiliar variable
	variable en_aux : std_logic := '0';
	begin
			en_aux := '0';
			for b in 0 to (N-1) loop
				en_aux := en_aux or (req(b) and gnt_out_reg(b));
			end loop;
			enable <= not(en_aux);
		end process;

	-- register
	flipflop : process (clk, reset)
	begin
		if reset = reset_state then
		-- add reset statements here
			for c in 0 to (N-1) loop
				gnt_out_reg(c) <= '0';
			end loop;
	
		elsif clk'event and clk = clk_polarity then
			if enable = '1' then -- this ‘if ’ has no matching ‘else ’
			-- insert logic before the flip - flop
				gnt_out_reg <= gnt_in_reg;
			end if;
		end if;
	end process;
	
	-- calcualtes multiplexer output
	output_mux: process (input, gnt_out_reg)
	--internal auxiliar variable
	variable out_aux : std_logic := '0';
	begin
		for j in 0 to (M - 1) loop
			-- initialize empty total
			out_aux := '0';
			--navigate gnt and input + compute output
			for a in 0 to (N - 1) loop
				out_aux := out_aux or (gnt_out_reg(a) and input(a*M+j));
			end loop;
			output(j) <= out_aux;
		end loop;
	end process;
	

end Behavioral;

