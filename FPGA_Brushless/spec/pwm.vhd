Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity pwm is /*
  generic (
        
    );*/
  port (
    clk     : in  std_logic;
    clk_en  : in  std_logic;
    reset_n : in  std_logic;

    value   : in  std_logic_vector(12 downto 0);

    pwm_out : out std_logic
  );

end entity;

architecture rtl of pwm is
  signal cpt  : std_logic_vector(12 downto 0); -- 8192 values
begin

  process(clk, reset_n) is
  begin
    if reset_n = '0' then
      cpt <= 13x"0000";
    elsif rising_edge(clk) and clk = '1' then
      if clk_en = '1' then
        cpt <= cpt + 1;

      end if;
    end if;
  end process;

  pwm_out <= '1' when cpt < value else '0';

end architecture;