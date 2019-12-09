LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY arbitermultiplexer_tb IS
END arbitermultiplexer_tb;
 
ARCHITECTURE behavior OF arbitermultiplexer_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT arbitermultiplexer
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         input : IN  std_logic_vector(29 downto 0);
         output : OUT  std_logic_vector(9 downto 0);
         req : IN  std_logic_vector(2 downto 0);
         gnt : OUT  std_logic_vector(2 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal input : std_logic_vector(29 downto 0) := (others => '0');
   signal req : std_logic_vector(2 downto 0) := (others => '0');

 	--Outputs
   signal output : std_logic_vector(9 downto 0);
   signal gnt : std_logic_vector(2 downto 0);

   -- Clock period definitions
   constant clk_period : time := 1ms;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: arbitermultiplexer PORT MAP (
          clk => clk,
          reset => reset,
          input => input,
          output => output,
          req => req,
          gnt => gnt
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
		input (29 downto 20) <= "1001001001";
		input (19 downto 10) <= "1010101010";
		input (9 downto 0) <= "1111100000";

		req <= "100" after 1 ms, "110" after 3 ms, "111" after 5 ms, "001" after 7 ms, "000" after 9 ms ;

      wait;
   end process;

END;
