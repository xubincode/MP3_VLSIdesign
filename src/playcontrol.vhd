library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.system_constants_pkg.all;

entity playcontrol is
  port (
    clk         : in std_logic;               --clock signal
    reset       : in std_logic;               --asynchronous reset

    key_empty   : in  std_logic;
    key_rd      : out std_logic;                 -------------------------------------------------------
    key_rd_ack  : in  std_logic;
    key_data    : in  std_logic_vector(7 downto 0);

    ctrl    : out std_logic;                -------------------------------------------------------
    busi    : out std_logic_vector(7 downto 0);                -------------------------------------------------------
    busiv   : out std_logic;                -------------------------------------------------------
    busy    : in  std_logic;
    busov   : in  std_logic;
    buso    : in  std_logic_vector(31 downto 0);

    chrm_wdata  : out std_logic_vector(7 downto 0);                -------------------------------------------------------
    chrm_wr     : out std_logic;                -------------------------------------------------------
    chrm_addr   : out std_logic_vector(7 downto 0);                -------------------------------------------------------
    lcdc_cmd    : out std_logic_vector(1 downto 0);                -------------------------------------------------------
    lcdc_busy   : in  std_logic;
    ccrm_wdata  : out std_logic_vector(35 downto 0);                -------------------------------------------------------
    ccrm_addr   : out std_logic_vector(4 downto 0);                -------------------------------------------------------
    ccrm_wr     : out std_logic;                -------------------------------------------------------

    hw_full     : in  std_logic;
    hw_wr       : out std_logic;                -------------------------------------------------------
    hw_din      : out std_logic_vector(31 downto 0);                -------------------------------------------------------

    dbuf_almost_full : in  std_logic;
    dbuf_wr          : out std_logic;                -------------------------------------------------------
    dbuf_din         : out std_logic_vector(31 downto 0);                -------------------------------------------------------
    dbuf_rst         : out std_logic;                -------------------------------------------------------

    sbuf_full   : in  std_logic;
    sbuf_empty  : in  std_logic;
    sbuf_rst    : out std_logic;                -------------------------------------------------------

    dec_rst     : out std_logic;                -------------------------------------------------------
    dec_status  : in  std_logic
    );
	 
end playcontrol;

architecture playcontrol_arch of playcontrol is

signal listnext : std_LOGIC := '0';
signal listprev : std_LOGIC:= '0';
signal play_sig : std_logic := '0';
signal stop_sig : std_logic := '0';
signal pause_sig : std_logic := '0';
signal pause_sig2 : std_logic := '0';
signal mute_sig : std_logic := '0';
signal mute_sig2 : std_logic := '0';
signal incvol_sig : std_logic := '0';
signal incvol_sig2 : std_logic := '0';
signal decvol_sig : std_logic := '0';
signal decvol_sig2 : std_logic := '0';
signal forward_sig : std_logic := '0';
signal forward_sig2 : std_logic := '0';
signal backward_sig : std_logic := '0';
signal backward_sig2 : std_logic := '0';
signal playing_sig : std_logic := '0';

signal percent_val : STD_LOGIC_VECTOR(31 downto 0);

signal preview_sig : std_logic := '0';


------- LCD features ------------
signal pause_lcd : std_logic := '0';
signal mute_lcd : std_logic := '0';
signal forw_lcd : std_logic := '0';
signal backw_lcd : std_logic := '0';

signal vol_key : std_logic := '0';

signal vol_num : unsigned(4 downto 0) := "00000";

signal req : std_LOGIC_VECTOR (2 downto 0);
signal gnt : std_LOGIC_VECTOR (2 downto 0) := "000";
signal busiv_listout: std_logic := '0';
signal ctrl_listout: std_logic := '0';
signal busi_listout: std_logic_VECTOR (7 downto 0) := "00000000";

------- PlayFSM ------------
signal busiv_playout: std_logic := '0';
signal ctrl_playout: std_logic := '0';
signal busi_playout: std_logic_VECTOR (7 downto 0) := "00000000";
signal track_end : std_logic := '0';
signal enable_mon : std_logic := '0';
signal playfile_end : std_logic := '0';
---------------------------
signal info_start : std_logic := '0';
signal info_ready : std_logic := '0';
signal arbitermux_in : std_logic_vector (29 downto 0):= "000000" & x"000000";
signal arbitermux_out : std_logic_vector (9 downto 0) := "0000000000";
signal file_size : std_logic_vector (31 downto 0) := x"00000000";

------- MonitorFSM ------------
signal busiv_monout: std_logic := '0';
signal ctrl_monout: std_logic := '0';
signal busi_monout: std_logic_VECTOR (7 downto 0) := "00000000";
-----------------------------------------------------

component keycodecomp is
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
end component;

component listctrl is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           listnext : in  STD_LOGIC;
           listprev : in  STD_LOGIC;
           req : out  STD_LOGIC;
           gnt : in  STD_LOGIC;
           busi : out  STD_LOGIC_VECTOR (7 downto 0);
           busiv : out  STD_LOGIC;
           ctrl : out  STD_LOGIC;
           busy : in  STD_LOGIC ;
           info_start : out  STD_LOGIC;
           info_ready : in  STD_LOGIC);
end component;

component arbitermultiplexer is
		port (
			clk : in std_logic ;
			reset : in std_logic ;
			input : in std_logic_vector (29 downto 0);
			output : out std_logic_vector (9 downto 0);
			req : in std_logic_vector (2 downto 0);
			gnt : out std_logic_vector (2 downto 0)
			);
end component;

component fileprocessing is
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
end component;

component playfsm is
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
end component;

component monitorfsm is
    Port ( clk : in  STD_LOGIC;
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
			  backward : in std_logic;
			  forward_lcd : out std_logic;
			  backward_lcd : out std_logic;
			  percent_num : out STD_LOGIC_VECTOR(31 downto 0);
           req : out  STD_LOGIC;
           busiv : out  STD_LOGIC;
           busi : out  STD_LOGIC_VECTOR (7 downto 0);
           ctrl : out  STD_LOGIC;
			  dbuf_wr : out STD_LOGIC;
			  playfile_end : out STD_LOGIC
			  );
end component;

component hwctrl is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  mute : in STD_LOGIC;
			  pause : in STD_LOGIC;
			  incvol : in STD_LOGIC;
			  decvol : in STD_LOGIC;
			  dec_status: in std_logic;
			  hw_full : in  std_logic;
			  pause_lcd : out std_logic;
			  mute_lcd : out std_logic;
			  vol_key : out std_logic;
			  vol_num : out unsigned (4 downto 0);
			  hw_wr : out std_logic;              
			  hw_din : out std_logic_vector(31 downto 0)
           );
end component;

begin
--write your code here  
ccrm_wdata <= x"000000000";
ccrm_addr <= "00000";
ccrm_wr <= '0';
--hw_wr <= '0';
--hw_din <= x"00000000";
--dbuf_wr <= '0';
--dbuf_din <= x"00000000";
--dbuf_rst <= '0';
--sbuf_rst <= '0';
--dec_rst <= '0';
--chrm_addr(7 downto 4) <= "0000"; 


arbitermux_in <= ctrl_listout & busi_listout & busiv_listout & ctrl_playout & busi_playout & busiv_playout & ctrl_monout & busi_monout & busiv_monout;
ctrl <= arbitermux_out(9);
busi <= arbitermux_out(8 downto 1);
busiv <= arbitermux_out(0);
dbuf_din <= buso;

keyread : keycodecomp port map (   rd => key_rd,
											  rd_ack => key_rd_ack,
											  data => key_data,
											  empty => key_empty,
											  listnext => listnext,
											  listprev => listprev,
											  play => play_sig,
											  stop => stop_sig,
											  pause => pause_sig,
											  mute => mute_sig,
											  incvol => incvol_sig,
											  decvol => decvol_sig,
											  forward => forward_sig,
											  backward => backward_sig,
											  preview => preview_sig
												);
											  
listcontrol : listctrl port map (  clk => clk,
											  reset => reset,
											  listnext => listnext,
											  listprev => listprev,
											  req => req(2),
											  gnt => gnt(2),
											  busi => busi_listout,
											  busiv => busiv_listout,
											  ctrl => ctrl_listout,
											  busy => busy,
											  info_start => info_start,
											  info_ready => info_ready
											  );
											  
arbitermux : arbitermultiplexer port map ( clk => clk,
														 reset => reset,
														 input => arbitermux_in,
													  	 output => arbitermux_out,
														 req => req,
														 gnt => gnt);
														 
fileingoproc: fileprocessing port map (  clk => clk,
													  reset => reset,
													  busov => busov,
													  buso => buso,
													  info_start => info_start,
													  lcdc_busy => lcdc_busy,
													  pause => pause_lcd,
													  mute => mute_lcd,
													  vol_key => vol_key,
													  vol_num => vol_num,
													  forward => forw_lcd,
													  backward => backw_lcd,
													  playing => playing_sig,
													  percent => percent_val,
													  file_size => file_size,
													  chrm_wdata => chrm_wdata,
													  chrm_addr => chrm_addr,
													  chrm_wr => chrm_wr,
													  lcdc_cmd => lcdc_cmd,
													  info_ready => info_ready);
													  
playFSMcontrol:  playfsm port map (   clk => clk,
												  reset => reset,
												  gnt => gnt(1),
												  busy => busy,
												  play => play_sig,
												  stop => stop_sig,
												  pause => pause_sig,
												  mute => mute_sig,
												  incvol => incvol_sig,
												  decvol => decvol_sig,
												  forward => forward_sig,
												  backward => backward_sig,
												  playfile_end => playfile_end,
												  listnext => listnext,
												  listprev => listprev,
												  playing => playing_sig,
												  req => req(1),
												  ctrl => ctrl_playout,
												  busiv => busiv_playout,
												  busi => busi_playout,
												  track_end => track_end,
												  enable_mon => enable_mon,
												  pause_out => pause_sig2,
												  mute_out => mute_sig2,
												  incvol_out => incvol_sig2,
												  decvol_out => decvol_sig2,
												  forward_out => forward_sig2,
												  backward_out => backward_sig2,
												  dec_rst => dec_rst,
												  dbuf_rst => dbuf_rst,
												  sbuf_rst => sbuf_rst
												  );									  
					
monitorFSMcontrol : monitorfsm port map ( clk => clk,
												  reset => reset,
												  enable_mon => enable_mon,
												  file_size => file_size,
												  busy => busy,
												  dbuf_almost_full => dbuf_almost_full,
												  busov => busov,
												  gnt => gnt(0),
												  dec_status => dec_status,
												  sbuf_full => sbuf_full,
												  forward => forward_sig2,
												  backward => backward_sig2,
												  forward_lcd => forw_lcd,
												  backward_lcd => backw_lcd,
												  percent_num => percent_val,
												  req => req(0),
												  busiv => busiv_monout,
												  busi => busi_monout,
												  ctrl => ctrl_monout,
												  dbuf_wr => dbuf_wr,
												  playfile_end => playfile_end
											);	
												
HWcontrol : hwctrl port map ( clk => clk,
										reset => reset,
										mute => mute_sig2,
										pause => pause_sig2,
										incvol => incvol_sig2,
										decvol => decvol_sig2,
										dec_status => dec_status,
										hw_full => hw_full,
										pause_lcd => pause_lcd,
										mute_lcd => mute_lcd,
										vol_key => vol_key,
										vol_num => vol_num,
										hw_wr => hw_wr,              
									   hw_din => hw_din
										);
											  
end architecture playcontrol_arch;
