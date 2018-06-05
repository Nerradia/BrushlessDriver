Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity output_sequencer is /*
  generic (
        
    );*/
  port (
    clk     : in  std_logic;
    reset_n : in  std_logic;

    inc     : in  std_logic;
  
    step    : out std_logic_vector (2 downto 0);
  
    H_A     : out std_logic;
    L_A     : out std_logic;
    H_B     : out std_logic;
    L_B     : out std_logic;
    H_C     : out std_logic;
    L_C     : out std_logic
  );
end entity output_sequencer;


architecture rtl of output_sequencer is
begin

  process(clk, reset_n) is
  begin
    if reset_n = '0' then
      step <= 3x"0";
    elsif rising_edge(clk) and clk = '1' then
      if inc = '1' then

        -- Increment step
        if step = 6 then
          step <= 3x"1";
        else 
          step <= step + 1;
        end if;

      end if;
    end if;
  end process;

  H_A <= '1' when step = x"1" or step = x"6" else '0';
  L_A <= '1' when step = x"3" or step = x"4" else '0';

  H_B <= '1' when step = x"2" or step = x"3" else '0';
  L_B <= '1' when step = x"5" or step = x"6" else '0';

  H_C <= '1' when step = x"4" or step = x"5" else '0';
  L_C <= '1' when step = x"1" or step = x"2" else '0';

end architecture;