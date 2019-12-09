-------------------------------------------------------------------------------
-- vhdl test bench for playcontrol.vhd
-- vlsi design laboratory
-- institute for electronic design automation
-------------------------------------------------------------------------------
-- version 0.2
--
-- This testbench tests only the list and play functions. Further functions,
-- e.g. stop, pause, mute etc., are not tested. This testbench provides a
-- basis to test the playcontrol module and it does not guarantee that the list
-- and play functions will work after passing this testbench. Further test
-- cases should be added to this testbench for different designs. 
--
-- bil 03/08, qic 04/09
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity playcontrol_tb is

end playcontrol_tb;

architecture behavior of playcontrol_tb is

  component playcontrol is
    port(
      clk   : in std_logic;
      reset : in std_logic;

      key_empty  : in  std_logic;
      key_rd     : out std_logic;
      key_rd_ack : in  std_logic;
      key_data   : in  std_logic_vector(7 downto 0);

      ctrl  : out std_logic;
      busi  : out std_logic_vector(7 downto 0);
      busiv : out std_logic;
      busy  : in  std_logic;
      busov : in  std_logic;
      buso  : in  std_logic_vector(31 downto 0);

      chrm_wdata : out std_logic_vector(7 downto 0);
      chrm_wr    : out std_logic;
      chrm_addr  : out std_logic_vector(7 downto 0);
      lcdc_cmd   : out std_logic_vector(1 downto 0);
      lcdc_busy  : in  std_logic;
      ccrm_wdata : out std_logic_vector(35 downto 0);
      ccrm_addr  : out std_logic_vector(4 downto 0);
      ccrm_wr    : out std_logic;

      hw_full : in  std_logic;
      hw_wr   : out std_logic;
      hw_din  : out std_logic_vector(31 downto 0);

      dbuf_almost_full : in  std_logic;
      dbuf_wr          : out std_logic;
      dbuf_din         : out std_logic_vector(31 downto 0);
      dbuf_rst         : out std_logic;

      sbuf_full  : in  std_logic;
      sbuf_empty : in  std_logic;
      sbuf_rst   : out std_logic;

      dec_rst    : out std_logic;
      dec_status : in  std_logic
      );
  end component;

  signal clk   : std_logic := '0';
  signal reset : std_logic := '1';

  signal key_empty  : std_logic                    := '1';
  signal key_rd     : std_logic;
  signal key_rd_ack : std_logic                    := '0';
  signal key_data   : std_logic_vector(7 downto 0) := (others => '0');

  signal fio_busi  : std_logic_vector(7 downto 0);
  signal fio_busiv : std_logic;
  signal fio_ctrl  : std_logic;
  signal fio_busy  : std_logic                     := '0';
  signal fio_buso  : std_logic_vector(31 downto 0) := (others => '0');
  signal fio_busov : std_logic                     := '0';

  signal ccrm_wdata : std_logic_vector(35 downto 0);
  signal ccrm_addr  : std_logic_vector(4 downto 0);
  signal ccrm_wr    : std_logic;
  signal lcdc_busy  : std_logic := '0';
  signal lcdc_cmd   : std_logic_vector(1 downto 0);
  signal chrm_addr  : std_logic_vector(7 downto 0);
  signal chrm_wdata : std_logic_vector(7 downto 0);
  signal chrm_wr    : std_logic;

  signal hw_din  : std_logic_vector(31 downto 0);
  signal hw_wr   : std_logic;
  signal hw_full : std_logic := '0';

  signal dbuf_almost_full : std_logic := '0';
  signal dbuf_din         : std_logic_vector(31 downto 0);
  signal dbuf_wr          : std_logic;
  signal dbuf_rst         : std_logic;

  signal sbuf_rst   : std_logic;
  signal sbuf_empty : std_logic := '1';
  signal sbuf_full  : std_logic := '0';

  signal dec_rst    : std_logic;
  signal dec_status : std_logic := '0';

  type test_state_type is (
    idle,
    send_next_key,
    send_prev_key,
    wait_next_cmd,
    wait_prev_cmd,
    return_file_info,
    wait_lcd_refresh,

    send_play_key,
    wait_open_cmd,
    wait_data_size,
    wait_read_cmd,
    return_file_data
    );
  signal test_state : test_state_type := idle;


  type     vector_array32 is array (natural range <>) of std_logic_vector(31 downto 0);
  type     vector_array32xn is array (natural range <>) of vector_array32(7 downto 0);
  constant current_file_size       : std_logic_vector(31 downto 0) := x"00002000";
  constant current_file_size_dword : std_logic_vector(31 downto 0) := "00"&current_file_size(31 downto 2);
  constant file_info : vector_array32xn(2 downto 0) := (
    0                                                            => (0 => x"54534554", 1 => x"20202031", 2 => x"2033504d", 3 => x"7db93500",
                                                               4 => x"32643264", 5 => x"88110000", 6 => x"2eee323b", 7 => current_file_size),
    1                                                            => (0 => x"54534554", 1 => x"20202032", 2 => x"2033504d", 3 => x"7dba2c18",
                                                               4 => x"32643264", 5 => x"66490000", 6 => x"3a0a323c", 7 => current_file_size),
    2                                                            => (0 => x"54534554", 1 => x"20202033", 2 => x"2033504d", 3 => x"00011000",
                                                               4 => x"32643264", 5 => x"88110000", 6 => x"2eee323b", 7 => current_file_size)
    );


-- the current listed file index
  signal file_cnt           : integer range 0 to 2          := 0;
  signal file_data_cnt      : std_logic_vector(31 downto 0) := x"00000000";
  signal dbuf_all_data_cnt  : std_logic_vector(31 downto 0) := x"00000000";
  signal dbuf_curr_data_cnt : std_logic_vector(31 downto 0) := x"00000000";
  signal req_data_size      : std_logic_vector(7 downto 0);

  signal dbuf_reset_status : std_logic := '0';
  signal sbuf_reset_status : std_logic := '0';
  signal dec_reset_status  : std_logic := '0';

  signal curr_key : std_logic_vector(7 downto 0) := x"00";

  signal first_list : std_logic := '1';

  --constants for list_state procedure
  constant listnext : integer := 0;
  constant listprev : integer := 1;

  constant fio_open_cmd     : std_logic_vector(7 downto 0) := x"03";
  constant fio_read_cmd     : std_logic_vector(7 downto 0) := x"02";
  constant fio_next_cmd     : std_logic_vector(7 downto 0) := x"00";
  constant fio_prev_cmd     : std_logic_vector(7 downto 0) := x"01";
  constant lcdc_refresh_cmd : std_logic_vector(1 downto 0) := "10";
  constant key_next         : std_logic_vector(7 downto 0) := x"72";
  constant key_prev         : std_logic_vector(7 downto 0) := x"75";
  constant key_play         : std_logic_vector(7 downto 0) := x"76";

  constant dbuf_size : integer := 512;

  constant failure_level : severity_level := failure;
  constant clk_polarity  : std_logic      := '1';

  constant tclock : time := (1000 ns / 32);  --the clock frequency is 32 mhz in this simulation
  constant pw     : time := tclock / 2;


begin

  clk   <= not clk after pw;
  reset <= '0'     after 19*pw;

  uut : playcontrol
    port map (
      clk   => clk,
      reset => reset,

      key_empty  => key_empty,
      key_rd     => key_rd,
      key_rd_ack => key_rd_ack,
      key_data   => key_data,

      ctrl  => fio_ctrl,
      busi  => fio_busi,
      busiv => fio_busiv,
      busy  => fio_busy,
      buso  => fio_buso,
      busov => fio_busov,

      ccrm_wdata => ccrm_wdata,
      ccrm_wr    => ccrm_wr,
      ccrm_addr  => ccrm_addr,
      lcdc_cmd   => lcdc_cmd,
      lcdc_busy  => lcdc_busy,
      chrm_wdata => chrm_wdata,
      chrm_addr  => chrm_addr,
      chrm_wr    => chrm_wr,

      hw_din  => hw_din,
      hw_wr   => hw_wr,
      hw_full => hw_full,

      dbuf_almost_full => dbuf_almost_full,
      dbuf_wr          => dbuf_wr,
      dbuf_din         => dbuf_din,
      dbuf_rst         => dbuf_rst,

      sbuf_full  => sbuf_full,
      sbuf_empty => sbuf_empty,
      sbuf_rst   => sbuf_rst,

      dec_rst    => dec_rst,
      dec_status => dec_status
      );

  state_gen : process
    procedure list_state_gen(constant nptype : integer) is
    begin
      --check the default state
      assert test_state = idle
        severity failure_level;

      if first_list = '1' then
        wait until clk'event and clk = clk_polarity and fio_busiv = '1' and fio_ctrl = '1' for 1000*tclock;
        if fio_busi = fio_next_cmd and fio_busiv = '1' and fio_ctrl = '1' then
          if file_cnt < 2 then
            file_cnt <= file_cnt +1;
          end if;
          test_state <= return_file_info;
        elsif fio_busi = fio_prev_cmd and fio_busiv = '1' and fio_ctrl = '1' then
          if file_cnt > 0 then
            file_cnt <= file_cnt -1;
          end if;
          test_state <= return_file_info;
        end if;

        wait until clk'event and clk = clk_polarity;
      end if;


      if test_state = idle then

        -- sends list keys
        wait until clk'event and clk = clk_polarity;
        if nptype = listnext then
          test_state <= send_next_key;
        else
          test_state <= send_prev_key;
        end if;

        -- there is at least one clock period between reading from the key fifo
        -- and sending the list command.
        wait until clk'event and clk = clk_polarity;
        if nptype = listnext then
          test_state <= wait_next_cmd;
        else
          test_state <= wait_prev_cmd;
        end if;

        wait until clk'event and clk = clk_polarity and fio_busiv = '1' and fio_ctrl = '1';
        if nptype = listnext then
          if file_cnt < 2 then
            file_cnt <= file_cnt +1;
          end if;
        else
          if file_cnt > 0 then
            file_cnt <= file_cnt -1;
          end if;
        end if;
        test_state <= return_file_info;
      end if;


      -- return requested file information
      wait for 10 * tclock;
      for i in 0 to 3 loop
        wait until clk'event and clk = clk_polarity;
        fio_busov <= '1';
        fio_buso  <= file_info(file_cnt)(i);
      end loop;
      wait until clk'event and clk = clk_polarity;
      fio_busov <= '0';
      -- generate an interval between returned file information
      wait for 10 * tclock;
      for i in 4 to 7 loop
        wait until clk'event and clk = clk_polarity;
        fio_busov <= '1';
        fio_buso  <= file_info(file_cnt)(i);
      end loop;
      wait until clk'event and clk = clk_polarity;
      fio_busov  <= '0';
      test_state <= wait_lcd_refresh;

      wait until clk'event and clk = clk_polarity and lcdc_cmd = lcdc_refresh_cmd;
      test_state <= idle;


    end procedure;

    procedure play_state_gen is
    begin
      assert test_state = idle
        severity failure_level;

      file_data_cnt <= (others => '0');

      wait until clk'event and clk = clk_polarity;
      test_state <= send_play_key;

      wait until clk'event and clk = clk_polarity;
      test_state <= wait_open_cmd;

      wait until clk'event and clk = clk_polarity and fio_busiv = '1' and fio_ctrl = '1' and fio_busi = fio_open_cmd;

      while file_data_cnt < current_file_size_dword loop
        test_state <= wait_data_size;

        wait until clk'event and clk = clk_polarity and fio_busiv = '1' and fio_ctrl = '0';
        req_data_size <= fio_busi;
        test_state    <= wait_read_cmd;

        wait until clk'event and clk = clk_polarity and fio_busiv = '1' and fio_ctrl = '1' and fio_busi = fio_read_cmd;
        --return file data
        test_state <= return_file_data;
        for i in 0 to conv_integer(req_data_size) loop
          wait until clk'event and clk = clk_polarity;
          fio_busov     <= '1';
          fio_buso      <= file_data_cnt;
          file_data_cnt <= file_data_cnt+1;
          wait until clk'event and clk = clk_polarity;
          fio_busov     <= '0';
        end loop;
      end loop;

      test_state <= idle;
    end procedure;
  begin
    wait for 12 *tclock;
    list_state_gen(listnext);
    first_list <= '0';
    wait for 100 *tclock;
    list_state_gen(listnext);
    wait for 100 *tclock;
    list_state_gen(listprev);
    wait for 100 *tclock;
    list_state_gen(listprev);
    wait for 100 *tclock;
    play_state_gen;
    wait for 100 *tclock;
    play_state_gen;

    assert false
      report "The simulation is finished successfully. This is not a failure!!!"
      severity failure_level;
    wait;
  end process;

  return_keys : process
  begin
    wait until clk'event and clk = clk_polarity;
    if test_state = send_next_key then
      key_empty <= '0';
      curr_key  <= key_next;
    elsif test_state = send_prev_key then
      key_empty <= '0';
      curr_key  <= key_prev;
    elsif test_state = send_play_key then
      key_empty <= '0';
      curr_key  <= key_play;
    end if;

    if key_rd = '1' then
      key_data   <= curr_key;
      key_rd_ack <= '1';
      key_empty  <= '1';
    end if;

    if key_rd_ack = '1' then
      key_rd_ack <= '0';
    end if;



  end process;

  check_dbuf_data : process
  begin
    wait until clk'event and clk = clk_polarity;

    if fio_busiv = '1' and fio_busy = '0' and fio_ctrl = '1' and fio_busi = fio_open_cmd then
      dbuf_all_data_cnt  <= (others => '0');
      dbuf_curr_data_cnt <= (others => '0');
    end if;

    assert dbuf_all_data_cnt <= current_file_size_dword
                                report "Too many DWORDs are written to dbuf!"
                                severity failure_level;

    if dbuf_wr = '1' then
      assert dec_status = '0'
        report "The decoder is busy. Can not write to dbuf!"
        severity failure_level;

      dbuf_all_data_cnt  <= dbuf_all_data_cnt+1;
      dbuf_curr_data_cnt <= dbuf_curr_data_cnt+1;

      if dbuf_curr_data_cnt = dbuf_size then
        dbuf_curr_data_cnt <= (others => '0');
      end if;

      assert dbuf_din = dbuf_all_data_cnt  --data is same as the index, see the play_state process.
        report "data to dbuf are incorrect!"
        severity failure_level;

    end if;
    
  end process;

  dbuf_almost_full_gen : process
  begin
    wait until clk'event and clk = clk_polarity;
    if dbuf_curr_data_cnt = dbuf_size-1 and dbuf_wr = '1' then
      dbuf_almost_full <= '1';
      wait for 1500*tclock;
      dbuf_almost_full <= '0';
    end if;
  end process;



  fio_busy <= '1' when test_state = return_file_info else
              '1' when test_state = return_file_data else
	      '1' when fio_busiv='1' and clk'event and clk=clk_polarity else --generate at least one period fio_busy='1' after receiving a parameter or command
              '0' after 10*tclock+3ns;

  lcdc_busy <= '1' when (lcdc_cmd = "01" or lcdc_cmd = "10") and clk'event and clk = clk_polarity else
               '0' after 500*tclock+3ns;

  check_resets : process
  begin
    wait until clk'event and clk = clk_polarity;
    assert not (dbuf_rst = '1' and dbuf_rst'stable(100*tclock))
      report "dbuf_rst should not always be '1'!"
      --severity failure_level;
      severity warning;

    assert not (sbuf_rst = '1' and sbuf_rst'stable(100*tclock))
      report "sbuf_rst should not always be '1'!"
      --severity failure_level;
      severity warning;

    assert not (dec_rst = '1' and dec_rst'stable(100*tclock))
      report "dec_rst should not always be '1'!"
      --severity failure_level;
      severity warning;

    if dbuf_rst = '1' then
      dbuf_reset_status <= '1';
    end if;
    if sbuf_rst = '1' then
      sbuf_reset_status <= '1';
    end if;
    if dec_rst = '1' then
      dec_reset_status <= '1';
    end if;

    if test_state = wait_read_cmd then
      assert dbuf_reset_status = '1'
        report "DBUF is not reset before sending read command to fio!"
        severity warning;

      assert sbuf_reset_status = '1'
        report "SBUF is not reset before sending read command to fio!"
        severity warning;

      assert dec_reset_status = '1'
        report "Decoder is not reset before sending read command to fio!"
        severity warning;
    end if;

    if dbuf_all_data_cnt = current_file_size_dword then
      dbuf_reset_status <= '0';
      sbuf_reset_status <= '0';
      dec_reset_status  <= '0';
    end if;
  end process;

  process
  begin
    wait until clk'event and clk = clk_polarity;
    assert not (key_empty = '0' and key_empty'stable(500*tclock))
      report "No key code is read in the past 500 clock periods!"
      severity failure_level;
    
    assert not(lcdc_busy = '1' and lcdc_cmd /= "00")
      report "LCD command should not be sent when lcdc is busy!"
      severity failure_level;

    assert not(fio_busy = '1' and fio_busiv = '1')
      report "FIO command/parameter should not be sent when fio is busy!"
      severity failure_level;

    if test_state = wait_next_cmd then
      assert not test_state'stable(500*tclock)
        report "List next command is not sent in the past 500 clock periods!"
        severity failure_level;

      if fio_busiv = '1' then
        assert fio_ctrl = '1' and fio_busi = fio_next_cmd
          report "List next command is expected!"
          severity failure_level;
      end if;
    end if;

    if test_state = wait_prev_cmd then
      assert not test_state'stable(500*tclock)
        report "List prev command is not sent in the past 500 clock periods!"
        severity failure_level;

      if fio_busiv = '1' then
        assert fio_ctrl = '1' and fio_busi = fio_prev_cmd
          report "List prev command is expected!"
          severity failure_level;
      end if;
    end if;

    if test_state = wait_lcd_refresh then
      assert not test_state'stable(500*tclock)
        report "LCD refresh command is not sent in the past 500 clock periods!"
        severity failure_level;
    end if;


    if test_state = wait_open_cmd then
      assert not test_state'stable(500*tclock)
        report "Open command is not sent in the past 500 clock periods!"
        severity failure_level;

      if fio_busiv = '1' then
        assert fio_ctrl = '1' and fio_busi = fio_open_cmd
          report "Open command is expected!"
          severity failure_level;
      end if;
    end if;

    if test_state = wait_data_size then
      assert not (dbuf_almost_full = '0' and dbuf_almost_full'stable(500*tclock) and test_state'stable(500*tclock))
        report "Data size is not sent in the past 500 clock periods!"
        severity failure_level;

      assert not (dbuf_almost_full = '1' and fio_busiv = '1' and fio_ctrl = '1' and fio_busi = fio_read_cmd)
        report "No read command should be sent when dbuf is almost full!"
        severity failure_level;

      if fio_busiv = '1' then
        assert fio_ctrl = '0'
          report "Data size is expected!"
          severity failure_level;
      end if;
    end if;

    if test_state = wait_read_cmd then
      assert not test_state'stable(500*tclock)
        report "Read command is not sent in the past 500 clock periods!"
        severity failure_level;

      if fio_busiv = '1' then
        assert fio_ctrl = '1' and fio_busi = fio_read_cmd
          report "Read command is expected!"
          severity failure_level;
      end if;
    end if;

  end process;

  

end architecture;
