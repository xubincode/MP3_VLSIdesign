-- Purpose: This package defines supplemental constants and the basic address mapping


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

package system_constants_pkg is

  constant USECHIPSCOPE : boolean := true;
  constant reset_state  : std_logic := '1';
  constant clk_polarity : std_logic := '1';


  constant HW_BASE_ADDR : std_logic_vector(31 downto 0) := x"40000000";

  constant SYS_STATUS_ADDR_OFFSET : std_logic_vector(31 downto 0) := x"00000000";

  constant SBUF_STATUS_ADDR_OFFSET : std_logic_vector(31 downto 0) := x"00008000";
  constant SBUF_DATA_WRITE_OFFSET  : std_logic_vector(31 downto 0) := x"00008004";
  --the mask should have the same bit number the SBUF_SIZE_DWORDS
  constant SBUF_DCOUNT_MASK        : std_logic_vector(31 downto 0) := x"00003FFF";
  constant SBUF_SIZE_DWORDS        : std_logic_vector(31 downto 0) := x"00002000";

  constant DBUF_STATUS_ADDR_OFFSET : std_logic_vector(31 downto 0) := x"00009000";
  constant DBUF_DATA_READ_OFFSET   : std_logic_vector(31 downto 0) := x"00009004";
  --the mask should have the same bit number the DBUF_SIZE_DWORDS
  constant DBUF_DCOUNT_MASK        : std_logic_vector(31 downto 0) := x"00000FFF";
  constant DBUF_SIZE_DWORDS        : std_logic_vector(31 downto 0) := x"00000800";

  constant SYS_RESET_MASK : std_logic_vector(31 downto 0) := x"80000000";

  constant SAMPLERATE_ADDR_OFFSET : std_logic_vector(31 downto 0) := x"0000a000";
  constant SAMPLEFMT_ADDR_OFFSET  : std_logic_vector(31 downto 0) := x"0000a004";


  --for LCDC
  constant oe_act : std_logic := '0';

  --for fio commands
  constant FIO_BASE_ADDR            : std_logic_vector(31 downto 0) := x"40000000";
  constant FIO_STATUS_ADDR_OFFSET   : std_logic_vector(31 downto 0) := x"0000b000";
  constant FIO_CMD_STATUS_MASK      : std_logic_vector(31 downto 0) := x"80000000";
  constant FIO_CMD_FILENEXT_MASK    : std_logic_vector(31 downto 0) := x"40000000";
  constant FIO_CMD_FILEPREV_MASK    : std_logic_vector(31 downto 0) := x"20000000";
  constant FIO_CMD_READ_MASK        : std_logic_vector(31 downto 0) := x"10000000";
  constant FIO_CMD_OPEN_MASK        : std_logic_vector(31 downto 0) := x"08000000";
  constant FIO_CMD_DATASIZE_MASK    : std_logic_vector(31 downto 0) := x"04000000";
  constant FIO_DATA_SIZE_MASK       : std_logic_vector(31 downto 0) := x"000000FF";
  constant FIO_FILENAME_ADDR_OFFSET : std_logic_vector(31 downto 0) := x"0000c000";
  constant FIO_DATA_ADDR_OFFSET     : std_logic_vector(31 downto 0) := x"0000d000";

  constant AUDIO_CMD_READ_OFFSET : std_logic_vector(31 downto 0) := x"0000e000";
  constant AUDIO_CMD_WRITE_OFFSET : std_logic_vector(31 downto 0) := x"0000e010";
  constant AUDIO_CTRL_REG_OFFSET : std_logic_vector(31 downto 0) := x"0000e004";
  constant SBUF_DATA_READ_OFFSET : std_logic_vector(31 downto 0) := x"0000f000";


  constant LCD_STATUS_ADDR_OFFSET : std_logic_vector(31 downto 0) := x"00080000";
  constant CCRM_BASE_ADDR_OFFSET : std_logic_vector(31 downto 0) := x"00090000";
  constant CHRM_BASE_ADDR_OFFSET : std_logic_vector(31 downto 0) := x"000a0000";
  constant LCD_CFG_ADDR_OFFSET : std_logic_vector(31 downto 0) := x"000b0000";

end system_constants_pkg;
