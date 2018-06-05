Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity hall_sensor is
  generic (
      clk_freq : integer := 300_000_000
    );
  port (
    clk         : in  std_logic;
    reset_n     : in  std_logic

    spi_clk     : out std_logic;
    spi_miso    : in std_logic;
    spi_mosi    : out std_logic;
    spi_hall_cs : out std_logic;

    hall_position : out std_logic_vector(13 downto 0)
  );
end entity hall_sensor;


architecture rtl of hall_sensor is
  constant spi_freq     : integer := 5_000_000; -- 5 MHz
  constant clk_div_top  : integer := clk_freq / spi_freq - 1;

  signal clk_div_cpt    : integer range 0 to clk_div_top;
  signal spi_clk_en     : std_logic;

begin

CLK_DIV:
  process(clk, reset_n) is
  begin
    if reset_n = '0' then
      clk_div_cpt <= 0;
      spi_clk_en  <= '0';

    elsif rising_edge(clk) then
      if clk_div_cpt < clk_div_top then
        clk_div_cpt <= clk_div_cpt + 1;
        spi_clk_en  <= '0';

      else
        clk_div_cpt <= 0;
        spi_clk_en  <= '1';
      
      end if;
    end if;
  end process;




end architecture;