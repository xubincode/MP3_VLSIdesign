ip----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:34:42 07/01/2019 
-- Design Name: 
-- Module Name:    fileprocessing - Behavioral 
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
--use ieee.fixed_pkg.all;
library work;
use work.system_constants_pkg.all;

entity fileprocessing is
    Port ( clk : in  STD_LOGIC;
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
			  playing : in std_logic;
			  percent : in STD_LOGIC_VECTOR(31 downto 0);
           file_size : out  STD_LOGIC_VECTOR (31 downto 0);
           chrm_wdata : out  STD_LOGIC_VECTOR (7 downto 0) ;
           chrm_addr : out  STD_LOGIC_VECTOR (7 downto 0); --pag.41
           chrm_wr : out  STD_LOGIC;
           lcdc_cmd : out  STD_LOGIC_VECTOR (1 downto 0);
           info_ready : out  STD_LOGIC);
end fileprocessing;

architecture Behavioral of fileprocessing is

signal counter : std_logic_vector (3 downto 0);
signal count3 : std_logic;
signal refcounter : std_logic_vector (3 downto 0);
signal filenamereg : std_logic_vector (95 downto 0);
signal aux_lcdc_cmd : std_logic_vector (1 downto 0);
signal chrm_ready : std_logic;
signal aux_info_ready : std_logic;
signal pause_aux : std_logic := '0';
signal pause_rdy : std_logic := '0';
signal mute_aux : std_logic := '0';
signal mute_rdy : std_logic := '0';
signal vol_rdy : std_logic := '0';
signal forw_rdy : std_logic := '0';
signal back_rdy : std_logic := '0';
signal percent_rdy : std_logic := '0';

signal time_vol : std_logic_vector (21 downto 0) := "1111111111111111111111" ;
signal time_forw : std_logic_vector (21 downto 0) := "1111111111111111111111" ;
signal time_back : std_logic_vector (21 downto 0) := "1111111111111111111111" ;

signal play_counter : std_logic_vector (17 downto 0) := "000000000000000000" ;
signal vol_counter : std_logic_vector (2 downto 0) := "100";
signal percent_counter : std_logic_vector (2 downto 0) := "101";
signal percent_sig : std_logic := '1';
signal percent_val : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000000";

signal volume_percentage1 : STD_LOGIC_VECTOR (7 downto 0);
signal volume_percentage2 : STD_LOGIC_VECTOR (7 downto 0);
signal play_percentage1 : STD_LOGIC_VECTOR (7 downto 0);
signal play_percentage2 : STD_LOGIC_VECTOR (7 downto 0);

signal aux_total_counter : unsigned(31 downto 0);
signal aux_percent : unsigned(31 downto 0);

signal msb_file : integer;
signal msb_totalc : integer;
signal diff : integer;

signal aux_file_size : STD_LOGIC_VECTOR (31 downto 0);


begin

lcdc_cmd <= aux_lcdc_cmd;
info_ready <= aux_info_ready;

data_counter : process (clk , reset)
	begin
	if reset = reset_state then
		counter <= "1000" ; -- asynchronous global reset
	elsif clk'event and clk = clk_polarity then
		if info_start = '1' then -- synchronous reset
			counter <= "0000" ;
		elsif busov = '1' and counter /= "1000" then --stops after 8 DWORDs received
			counter <= counter +1;
		end if;
	end if;
end process ;

counter_switch : process (clk , reset)
begin
	if reset = reset_state then
		count3 <= '1';
		aux_info_ready <= '0';
	elsif clk'event and clk = clk_polarity then
		count3 <= counter (3);
		if count3 = '0' and counter (3) = '1' then
			aux_info_ready <= '1';
		else
			aux_info_ready <= '0';
	
		end if;
	end if;
end process ;

reg_buso : process (clk, reset) --storing in 12B reg, file size reg
begin
	if reset = reset_state then
		filenamereg <= (others => '0');
		file_size <= x"00000000";
	elsif (clk'event and clk = clk_polarity) then
	case counter is 
		when "0000" => -- counter < 3
			filenamereg (31 downto 0) <= buso; -- 32 byte information sent in DWORDs
		when "0001" => -- counter < 3
			filenamereg (63 downto 32) <= buso;
		when "0010" => -- counter < 3
			filenamereg (95 downto 64) <= buso;
		when "0111" => -- counter = 7 -> contains file size
			file_size <= buso;
			aux_file_size <= buso;
		when others =>
	end case;
	end if;
end process;

write_chrm :process ( clk , reset ) -- convert 32bit file name to 8 bit parts
begin
	if reset = reset_state then
		refcounter <= "1011"; 
		chrm_wr <= '0';
	elsif clk'event and clk = clk_polarity then
	
	---------------------------------------CALCULATE PLAY PERCENTAGE-------------------------------
		
							for n in 0 to 31 loop
								if aux_file_size(n) = '1' then
									msb_file <= n;
								end if;
							end loop;
							for n in 0 to 31 loop
								if percent(n) = '1' then
									msb_totalc <= n;
								end if;	
							end loop;
									
							diff <= msb_file - msb_totalc;
										case diff is
											when 0 =>
												play_percentage1 <= x"20";
												play_percentage2 <= x"20";
											when 1 =>
												play_percentage1 <= x"39";
												play_percentage2 <= x"35";
											when 2 =>
												play_percentage1 <= x"38";
												play_percentage2 <= x"38";
											when 3 =>
												play_percentage1 <= x"38";
												play_percentage2 <= x"32";
											when 4 =>
												play_percentage1 <= x"37";
												play_percentage2 <= x"35";
											when 5 =>
												play_percentage1 <= x"37";
												play_percentage2 <= x"30";
											when 6 =>
												play_percentage1 <= x"36";
												play_percentage2 <= x"36";
											when 7 =>
												play_percentage1 <= x"36";
												play_percentage2 <= x"31";
											when 8 =>
												play_percentage1 <= x"35";
												play_percentage2 <= x"35";
											when 9 =>
												play_percentage1 <= x"35";
												play_percentage2 <= x"31";
											when 10 =>
												play_percentage1 <= x"34";
												play_percentage2 <= x"36";
											when 11 =>
												play_percentage1 <= x"34";
												play_percentage2 <= x"32";
											when 12 =>
												play_percentage1 <= x"33";
												play_percentage2 <= x"38";
											when 13 =>
												play_percentage1 <= x"33";
												play_percentage2 <= x"36";
											when 14 =>
												play_percentage1 <= x"33";
												play_percentage2 <= x"31";
											when 15 =>
												play_percentage1 <= x"32";
												play_percentage2 <= x"39";
											when 16 =>
												play_percentage1 <= x"32";
												play_percentage2 <= x"37";
											when 17 =>
												play_percentage1 <= x"32";
												play_percentage2 <= x"35";
											when 18 =>
												play_percentage1 <= x"32";
												play_percentage2 <= x"33";
											when 19 =>
												play_percentage1 <= x"32";
												play_percentage2 <= x"30";
											when 20 =>
												play_percentage1 <= x"31";
												play_percentage2 <= x"38";
											when 21 =>
												play_percentage1 <= x"31";
												play_percentage2 <= x"36";
											when 22 =>
												play_percentage1 <= x"32";
												play_percentage2 <= x"34";
											when 23 =>
												play_percentage1 <= x"32";
												play_percentage2 <= x"32";
											when 24 =>
												play_percentage1 <= x"32";
												play_percentage2 <= x"30";
											when 25 =>
												play_percentage1 <= x"31";
												play_percentage2 <= x"37";
											when 26 =>
												play_percentage1 <= x"31";
												play_percentage2 <= x"34";
											when 27 =>
												play_percentage1 <= x"31";
												play_percentage2 <= x"32";
											when 28 =>
												play_percentage1 <= x"31";
												play_percentage2 <= x"30";
											when 29 =>
												play_percentage1 <= x"30";
												play_percentage2 <= x"38";
											when 30 =>
												play_percentage1 <= x"20";
												play_percentage2 <= x"36";
											when 31 =>
												play_percentage1 <= x"20";
												play_percentage2 <= x"33";
											when 32 =>
												play_percentage1 <= x"20";
												play_percentage2 <= x"30";
											when others =>
												play_percentage1 <= x"20";
												play_percentage2 <= x"20";
										end case;
											
	---------------------------------------------------------------------------------------------------
			
					
					if aux_info_ready = '1' then -- synchronous reset
							refcounter <= "0000";

					elsif refcounter /= "1011" then
							refcounter <= refcounter +1;
					end if;
				
					if refcounter /= "1011" then
							chrm_wr <= '1';
							chrm_addr <= "0000" & refcounter;
						--	percent_sig <= '0';
					
					--------- pause icon appear--------			
					elsif	pause = '1' AND pause_aux = '0' then 
						chrm_wr <= '1';
						pause_aux <= '1';
						chrm_addr <= x"0F";
						pause_rdy <= '1';
					
					--------- pause icon clear --------	
					elsif pause = '1' AND pause_aux = '1' then
						chrm_wr <= '1';
						pause_aux <= '0';
						chrm_addr <= x"0F";
						pause_rdy <= '1';
					
					--------- mute icon appear--------	
					elsif	mute = '1' AND mute_aux = '0' then 
						chrm_wr <= '1';
						mute_aux <= '1';
						chrm_addr <= x"0E";
						mute_rdy <= '1';
					
					--------- mute icon clear --------	
					elsif mute = '1' AND mute_aux = '1' then
						chrm_wr <= '1';
						mute_aux <= '0';
						chrm_addr <= x"0E";
						mute_rdy <= '1';
					
					--------- volume num appear--------	
					elsif vol_key = '1' then
						vol_rdy <= '0';
						vol_counter <= "000";
						time_vol <= "0000000000000000000000";
					--	percent_sig <= '0';

					--------- forward icon appear--------						
					elsif forward = '1' then
						time_forw <= "0000000000000000000000";
						chrm_wr <= '1';
						chrm_addr <= x"0D";
						forw_rdy <= '1';
						
					--------- backward icon appear--------
					elsif backward = '1' then
						time_back <= "0000000000000000000000";
						chrm_wr <= '1';
						chrm_addr <= x"0C";
						back_rdy <= '1';
					
					--------- playing percentage--------
					elsif percent_sig = '1' AND playing = '1' then 
						percent_counter <= "000";
						percent_rdy <= '0';
					
					else 
						pause_rdy <= '0';
						mute_rdy <= '0';
						chrm_wr <= '0';
						chrm_addr <= "00001111";
						percent_rdy <= '0';
						
					end if;
					
					--------- timer to clear forward icon --------	
					if time_forw /= "1111111111111111111111" then
						time_forw <= time_forw +1;
						if time_forw = "1111111111111111111111" then
							vol_rdy <= '0';
							chrm_wr <= '0';
						elsif time_forw = "1111111111111111111110" then 
							chrm_wr <= '1';
							chrm_addr <= x"0D";
						end if;
					end if;
					
					--------- timer to clear backward icon --------	
					if time_back /= "1111111111111111111111" then
						time_back <= time_back +1;
						if time_back = "1111111111111111111111" then
							vol_rdy <= '0';
							chrm_wr <= '0';
						elsif time_back = "1111111111111111111110" then 
							chrm_wr <= '1';
							chrm_addr <= x"0C";
						end if;
					end if;
					
					--------- tier to refresh play percentage --------	
					if play_counter /= "111111111111111111" then
						play_counter <= play_counter +1;
						if play_counter = "111111111111111110" then
							percent_sig <= '1';
							play_counter <= "000000000000000000";
						else
							percent_sig <= '0';
						end if;
					end if;
					
					--------- compute address of playing percentage --------	
					if percent_counter /= "101" then
						percent_counter <= percent_counter +1;
						chrm_wr <= '1';
						chrm_addr <= ("00010" & percent_counter) + 12;
					end if;
					
					--------- compute address of wdata --------	
					if vol_counter /= "101" then
						vol_counter <= vol_counter +1;
						chrm_wr <= '1';
						chrm_addr <= ("00000" & vol_counter) + 12;
					end if;
					--------- timer for volume chars --------	
					if time_vol /= "1111111111111111111111" then
						time_vol <= time_vol +1;
						if time_vol = "1111111111111111111111" then
							vol_rdy <= '0';
							chrm_wr <= '0';
						elsif time_vol >= "1111111111111111111011" then 
							chrm_wr <= '1';
							chrm_addr <= ("00000" & time_vol(2 downto 0)) + 9;
						end if;
					end if;
					
					case refcounter (3 downto 0) is -- select stored file name bytes for chrm_data
							when "0000" =>
								chrm_wdata <= filenamereg (7 downto 0);
							when "0001" =>
								chrm_wdata <= filenamereg (15 downto 8);
							when "0010" =>
								chrm_wdata <= filenamereg (23 downto 16);
							when "0011" =>
								chrm_wdata <= filenamereg (31 downto 24);
							when "0100" =>
								chrm_wdata <= filenamereg (39 downto 32);
							when "0101" =>
								chrm_wdata <= filenamereg (47 downto 40);
							when "0110" =>
								chrm_wdata <= filenamereg (55 downto 48);
							when "0111" =>
								chrm_wdata <= filenamereg (63 downto 56);
							when "1000" =>
								chrm_wdata <= filenamereg (71 downto 64);
							when "1001" =>
								chrm_wdata <= filenamereg (79 downto 72);
							when "1010" =>
								chrm_wdata <= filenamereg (87 downto 80);
							when others =>
								
								if pause = '1' AND pause_aux = '0' then
									chrm_wdata <= x"50";
								elsif pause = '1' AND pause_aux = '1' then
									chrm_wdata <= x"20";
								elsif mute = '1' AND mute_aux = '0' then
									chrm_wdata <= x"4D";
								elsif mute = '1' AND mute_aux = '1' then
									chrm_wdata <= x"20";				
								elsif forward = '1' then
									chrm_wdata <= x"3E";
								elsif backward = '1' then
									chrm_wdata <= x"3C";	
								elsif vol_counter /= "101" then	
								
	---------------------------------------CALCULATE VOLUME PERCENTAGE-------------------------------
											case vol_num is
														when "00000" => ---- 0
															volume_percentage1 <= x"30";
															volume_percentage2 <= x"30";
														when "00001" => ---- 1
															volume_percentage1 <= x"39";
															volume_percentage2 <= x"37";
														when "00010" => ---- 2
															volume_percentage1 <= x"39";
															volume_percentage2 <= x"33";
														when "00011" => ---- 3
															volume_percentage1 <= x"39";
															volume_percentage2 <= x"30";
														when "00100" => ---- 4
															volume_percentage1 <= x"38";
															volume_percentage2 <= x"37";
														when "00101" => ---- 5
															volume_percentage1 <= x"38";
															volume_percentage2 <= x"34";
														when "00110" => ---- 6
															volume_percentage1 <= x"38";
															volume_percentage2 <= x"31";
														when "00111" => ---- 7
															volume_percentage1 <= x"37";
															volume_percentage2 <= x"37";
														when "01000" => ---- 8
															volume_percentage1 <= x"37";
															volume_percentage2 <= x"34";
														when "01001" => ---- 9
															volume_percentage1 <= x"37";
															volume_percentage2 <= x"31";
														when "01010" => ---- 10
															volume_percentage1 <= x"36";
															volume_percentage2 <= x"38";
														when "01011" => ---- 11
															volume_percentage1 <= x"36";
															volume_percentage2 <= x"34";
														when "01100" => ---- 12
															volume_percentage1 <= x"36";
															volume_percentage2 <= x"31";
														when "01101" => ---- 13
															volume_percentage1 <= x"35";
															volume_percentage2 <= x"38";
														when "01110" => ---- 14
															volume_percentage1 <= x"35";
															volume_percentage2 <= x"35";
														when "01111" => ---- 15
															volume_percentage1 <= x"35";
															volume_percentage2 <= x"32";
														when "10000" => ---- 16
															volume_percentage1 <= x"34";
															volume_percentage2 <= x"38";
														when "10001" => ---- 17
															volume_percentage1 <= x"34";
															volume_percentage2 <= x"35";
														when "10010" => ---- 18
															volume_percentage1 <= x"34";
															volume_percentage2 <= x"32";
														when "10011" => ---- 19
															volume_percentage1 <= x"33";
															volume_percentage2 <= x"39";
														when "10100" => ---- 20
															volume_percentage1 <= x"33";
															volume_percentage2 <= x"35";
														when "10101" => ---- 21
															volume_percentage1 <= x"33";
															volume_percentage2 <= x"32";
														when "10110" => ---- 22
															volume_percentage1 <= x"32";
															volume_percentage2 <= x"39";
														when "10111" => ---- 23
															volume_percentage1 <= x"32";
															volume_percentage2 <= x"36";
														when "11000" => ---- 24
															volume_percentage1 <= x"32";
															volume_percentage2 <= x"33";
														when "11001" => ---- 25
															volume_percentage1 <= x"31";
															volume_percentage2 <= x"39";
														when "11010" => ---- 26
															volume_percentage1 <= x"31";
															volume_percentage2 <= x"36";
														when "11011" => ---- 27
															volume_percentage1 <= x"31";
															volume_percentage2 <= x"33";
														when "11100" => ---- 28
															volume_percentage1 <= x"31";
															volume_percentage2 <= x"30";
														when "11101" => ---- 29
															volume_percentage1 <= x"20";
															volume_percentage2 <= x"36";
														when "11110" => ---- 30
															volume_percentage1 <= x"20";
															volume_percentage2 <= x"33";
														when "11111" => ---- 31
															volume_percentage1 <= x"20";
															volume_percentage2 <= x"30";
														when others =>
															volume_percentage1 <= x"20";
															volume_percentage2 <= x"20";
											end case;
		--------------------------------------------------------------------------------------------------
								--------- characters for volume percentage --------				
											case vol_counter is
														when "000" => 
																if vol_num = 0 then
																	chrm_wdata <= x"31";
																else
																	chrm_wdata <= x"20";
																end if;
														when "001" =>
															chrm_wdata <= volume_percentage1;
														when "010" =>
															chrm_wdata <= volume_percentage2;
														when "011" =>
															chrm_wdata <= x"25";
															vol_rdy <= '1';
														when others =>
															vol_rdy <= '0';
															chrm_wr <= '0';
														end case;
								
								--------- timer for cleaning volume percentage --------								
								elsif time_vol >= "1111111111111111111011" AND time_vol /= "1111111111111111111111" then
									chrm_wdata <= x"20";
									if time_vol >= "1111111111111111111110" then
										vol_rdy <= '1';
									end if;
							   
								--------- timer for cleaning forward icon --------
								elsif time_forw >= "1111111111111111111110" AND time_forw /= "1111111111111111111111" then
									chrm_wdata <= x"20";

								--------- timer for cleaning backward icon --------	
								elsif time_back >= "1111111111111111111110" AND time_back /= "1111111111111111111111" then
									chrm_wdata <= x"20";

								--------- characters for the playing percentage --------	
								elsif percent_counter /= "101" then
									
											case percent_counter is
														when "000" => 
																chrm_wdata <= x"20";
														when "001" =>
															chrm_wdata <= play_percentage1;
														when "010" =>
															chrm_wdata <= play_percentage1;
														when "011" =>
															chrm_wdata <= x"25";
															percent_rdy <= '1';
														when others =>
															percent_rdy <= '0';
															chrm_wr <= '0';
														end case;
								else
									chrm_addr <= "0001" & refcounter;
									chrm_wdata <= x"20";
								end if;
					end case;
				
														
	end if;
end process;


process (clk , reset)
begin
	if reset = reset_state then
		chrm_ready <= '0';
	elsif clk'event and clk = clk_polarity then
		if aux_lcdc_cmd = "10" then
			chrm_ready <= '0';
		elsif refcounter = "1010" then 
			chrm_ready <= '1';
		elsif pause_rdy = '1' OR mute_rdy = '1' OR vol_rdy = '1' OR percent_rdy = '1' OR forw_rdy = '1' OR back_rdy = '1' then
			chrm_ready <= '1';
		end if;
	end if;
end process ;

refreshing : process (clk , reset)
begin
	if reset = reset_state then
		aux_lcdc_cmd <= "00" ; --no command
	elsif clk'event and clk = clk_polarity then
		if aux_lcdc_cmd = "10" then -- after sending refresh command, put no command
			aux_lcdc_cmd <= "00" ;
		elsif lcdc_busy = '0' and chrm_ready = '1' then -- lcdc and all info received in chrm
			aux_lcdc_cmd <= "10" ; -- refresh command
		end if;
	end if;
end process ;

end Behavioral;