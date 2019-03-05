library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;


entity DNA_Module is
  generic (
    SIM_DNA_VALUE : std_logic_vector := X"0DEADBEEFC0FFEE"
  );
  port (
    SYSCLK : in std_logic;
    --PUSH_BUTTON: in std_logic;
    SYS_RESET : in std_logic;
    --DOUT_O : out std_logic; --std_logic_vector(95 downto 0);    -- 1-bit output: DNA output data
    --DIN_O : out std_logic;     -- 1-bit input: User data input pin
    --READ_O : out std_logic;   -- 1-bit input: Active-High load DNA, active-Low read input
    --SHIFT_O : out std_logic; -- 1-bit input: Active-High shift enable input
    SRL_O : out std_logic_vector(63 downto 0)  -- 1-bit input: Active-High shift enable input
  );
end DNA_Module;

architecture Behavioral of DNA_Module is

------------State Type Declaration----------------------------
type CONTROLLER_STATE is (S_RESET,S_DNA,S_DONE);

------------DNA Component Declaration-------------------

COMPONENT DNA_PORT is
  generic (
    SIM_DNA_VALUE : std_logic_vector  -- Specifies a sample 64-bit DNA value for simulation
  );
  PORT (
    DOUT : out std_logic; --std_logic_vector(64 downto 0);    -- 1-bit output: DNA output data
    CLK : in std_logic;    -- 1-bit input: Clock input
    DIN : in std_logic;     -- 1-bit input: User data input pin
    READ : in std_logic;   -- 1-bit input: Active-High load DNA, active-Low read input
    SHIFT : in std_logic -- 1-bit input: Active-High shift enable input
  );
END COMPONENT;



------------Signal Declarations----------------------------
signal CURR_STATE, NEXT_STATE : CONTROLLER_STATE;                               --- State Signals
signal O:  std_logic;                                                     --- DNA Output
signal CLK:  std_logic;                                                         --- Clock signal
signal I:  std_logic := '0'; -- tie shift in to 0                                                  --- DNA Input
signal RD: std_logic := '0';                                                     --- DNA Read
signal SFT:  std_logic := '0';                                                        --- DNA Shift
signal RESET: std_logic := '1';                                                   --- Reset Control

signal SFT_cnt : integer range 0 to 62 := 0;                                   --Shift assert count
signal COUNT : integer range 0 to 3 := 0;                                      --- FSM Count
signal DONE_DNA : std_logic := '0';


signal SLR_tmp : std_logic_vector(63 downto 0);



begin

-- DNA_PORT: Device DNA Access Port
-- 7 Series
-- Xilinx HDL Language Template, version 2018.3
DNA_PORT_inst : DNA_PORT
  generic map (
    SIM_DNA_VALUE => X"0DEADBEEFC0FFEE" -- Specifies a sample 57-bit DNA value for simulation
  )
  port map (
    DOUT => O,   -- 1-bit output: DNA output data.
    CLK => CLK,  -- 1-bit input: Clock input.
    DIN => I,    -- 1-bit input: User data input pin.
    READ => RD,  -- 1-bit input: Active high load DNA, active low read input.
    SHIFT => SFT -- 1-bit input: Active high shift enable input.
  );
-- End of DNA_PORT_inst instantiation


SYNC_PROC: process(SYSCLK)
begin
  if(Rising_edge(SYSCLK)) then
    if (RESET = '1') then
      CURR_STATE <= S_RESET;
    else
      CURR_STATE <= NEXT_STATE;
    end if;
  end if;
end process SYNC_PROC;

MAIN_PROC: process(CURR_STATE,SYS_RESET,DONE_DNA)
begin
  case CURR_STATE is
    when S_RESET =>
      if(SYS_RESET = '1') then
          NEXT_STATE <= S_DNA;
      else
          NEXT_STATE <= S_RESET;
      end if;
    when S_DNA =>
      if(DONE_DNA = '1') then
          NEXT_STATE <=  S_DONE;
      else
          NEXT_STATE <= S_DNA;
      end if;
    when S_DONE =>
      NEXT_STATE <= S_DONE;
    when others=>
  end case;--NEXT_STATE
end process MAIN_PROC;


-----Process to read DNA-----------

PROC: process(SYSCLK)
begin
  if(Rising_edge(SYSCLK)) then
    case NEXT_STATE is
      when S_RESET =>
        RD <= '0';
        SFT <= '0';
        RESET <= '0';           --de-assert reset (initially asserted)
      when S_DNA =>
        case COUNT is
          when 0 =>
            RD <= '1';      --Assert read Parallel loads output shift register
            SFT <= '1';
            COUNT <= COUNT + 1;
          when 1 =>
            RD <= '0';      -- Read should be deasserted after 1 CLK
            SFT <= '1';
            COUNT <= COUNT + 1;
          when 2 =>
            RD <= '0';
            SFT <= '1';     --Assert SHIFT, hold asserted for 64 CLKs
            IF (SFT_cnt < 62) THEN
              SFT_cnt <= SFT_cnt + 1;
              COUNT <= 2;
             ELSE
              COUNT <= COUNT + 1;
             END IF;
          when 3 =>
            RD <= '0';
            SFT <= '0';
            DONE_DNA <= '1';
            COUNT <= COUNT + 1;
          when others=>
            COUNT <= COUNT + 1;
       end case;
      when S_DONE =>
        RD <= '0';
        SFT <= '0';
      when others =>
        RESET <= '1';   --re-assert reset
      end case;
  end if;
end process PROC;

---SIPO SRL----

process (SYSCLK)
begin
  if (SYSCLK 'event and SYSCLK='1') then
    if SFT = '1' then
      SLR_tmp <= SLR_tmp (62 downto 0)& O;
    end if;
  end if;
end process;

SRL_O <= SLR_tmp;

--------Connect Signals to corresponding output---------------

CLK <= SYSCLK;
--DOUT_O <= O;
--DIN_O <= I;     -- 1-bit input: User data input pin
--READ_O <= RD;   -- 1-bit input: Active-High load DNA, active-Low read input
--SHIFT_O <= SFT;  -- 1-bit input: Active-High shift enable input

end Behavioral;

