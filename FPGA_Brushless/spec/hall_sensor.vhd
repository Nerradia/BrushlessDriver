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
    reset_n     : in  std_logic;

    spi_clk     : out std_logic;
    spi_miso    : in  std_logic;
    spi_mosi    : out std_logic;
    spi_hall_cs : out std_logic;

    hall_position : out std_logic_vector(13 downto 0)
  );
end entity hall_sensor;


architecture rtl of hall_sensor is
  constant spi_freq         : integer := 5_000_000; -- 5 MHz
  constant clk_div_top      : integer := clk_freq / spi_freq - 1;
  constant fetch_period     : integer := 50; -- Number of spi clock ticks between fetches of position

  signal clk_div_cpt        : integer range 0 to clk_div_top;
  signal spi_clk_fall       : std_logic;

  signal hall_position_sr   : std_logic_vector(15 downto 0);

  signal spi_clk_int        : std_logic;
  signal spi_clk_en         : std_logic;

  signal state : integer range 0 to fetch_period-1;

begin

spi_clk <= spi_clk_en and spi_clk_int;

CLK_DIV:
  process(clk, reset_n) is
  begin
    if reset_n = '0' then
      clk_div_cpt <= 0;
      spi_clk_fall  <= '0';
      spi_clk_int   <= '0';

    elsif rising_edge(clk) then
      if clk_div_cpt < clk_div_top then
        clk_div_cpt   <= clk_div_cpt + 1;
        spi_clk_fall  <= '0';

      else
        clk_div_cpt   <= 0;
        spi_clk_fall  <= '1';
      
      end if;

      -- Clk out
      if clk_div_cpt = clk_div_top/2 then
        spi_clk_int   <= '1';

      elsif clk_div_cpt = 0 then
        spi_clk_int   <= '0';

      end if;
    end if;
  end process;

STATE_MCHNE:
  process(clk, reset_n) is
  begin
    if reset_n = '0' then
      state            <= 0;
      spi_hall_cs      <= '1';
      hall_position_sr <= (others => '0');
      hall_position    <= (others => '0');
      spi_clk_en       <= '0';

    elsif rising_edge(clk) then

      if spi_clk_fall = '1' then 
        if state = fetch_period-1 then
          state <= 0;

        else 
          state <= state + 1;

        end if;

        case state is

          when 0 to 2 =>
            spi_hall_cs <= '0'; -- Enable Hall sensor's SPI then wait 4 cycles

          when 3 =>
            spi_hall_cs <= '0';
            spi_clk_en  <= '1';

          when 4 to 19 =>
            spi_clk_en  <= '1';
            spi_hall_cs <= '0'; -- Hall sensor's SPI enabled
            hall_position_sr <= hall_position_sr(14 downto 0) & spi_miso; -- shifting data to register

          when 20 =>
            spi_clk_en  <= '0';
            spi_hall_cs <= '0'; -- Hall sensor's SPI enabled
            hall_position <= hall_position_sr(13 downto 0);

          when others => 
            spi_hall_cs <= '1'; -- Hall sensor's SPI disabled

        end case;
      end if;

    end if;
  end process;

spi_mosi <= '1';

end architecture;