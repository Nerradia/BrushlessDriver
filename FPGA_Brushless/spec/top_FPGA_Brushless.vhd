Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity top_FPGA_brushless is /*
  generic (
        
    );*/
  port (
    clk_input : in  std_logic;

  -- LED
    led_0       : out std_logic;
    led_1       : out std_logic;
    led_2       : out std_logic;
    led_3       : out std_logic;
    led_4       : out std_logic;
    led_5       : out std_logic;
    led_6       : out std_logic;
    led_7       : out std_logic;

    -- Mosfets
    H_A         : out std_logic;
    L_A         : out std_logic;
    H_B         : out std_logic;
    L_B         : out std_logic;
    H_C         : out std_logic;
    L_C         : out std_logic;

    -- Hall sensor
    spi_clk     : out std_logic;
    spi_miso    : in std_logic;
    spi_mosi    : out std_logic;
    spi_hall_cs : out std_logic
  );

end entity top_FPGA_brushless;

architecture rtl of top_FPGA_brushless is 

  component hall_sensor is
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
  end component;

  component pll_altera IS
    PORT
    (
      inclk0    : IN STD_LOGIC  := '0';
      c0        : OUT STD_LOGIC ;
      locked    : OUT STD_LOGIC 
    );
  end component;


  component pwm is /*
    generic (
          
      );*/
    port (
      clk     : in  std_logic;
      clk_en  : in  std_logic;
      reset_n : in  std_logic;

      value   : in  std_logic_vector(12 downto 0);

      pwm_out : out std_logic
  );
  end component;


  component clk_div is
  port (
    clk        : in  std_logic;
    reset_n    : in  std_logic;

    clk_en_1hz : out std_logic
  );
  end component;

  component output_sequencer is /*
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
  end component;

  constant clk_freq : integer := 100_000_000;

  --signal clk_en : std_logic;
  signal pwm_out      : std_logic;
  signal clk          : std_logic;
  signal reset_n      : std_logic;
  signal clk_en_1hz   : std_logic;
  signal step         : std_logic_vector (2 downto 0);

  signal H_A_int  : std_logic;
  signal L_A_int  : std_logic;
  signal H_B_int  : std_logic;
  signal L_B_int  : std_logic;
  signal H_C_int  : std_logic;
  signal L_C_int  : std_logic;

  signal hall_position : std_logic_vector(13 downto 0);
begin

pll_altera_inst : pll_altera PORT MAP (
    inclk0    => clk_input,
    c0        => clk,
    locked    => reset_n
  );

inst_pwm : pwm 
  port map (
    clk     => clk,
    clk_en  => '1',
    reset_n => reset_n,

    value   => std_logic_vector(to_unsigned(2000, 13)),

    pwm_out => pwm_out);

inst_clk_div : clk_div
  port map (
    clk     => clk,
    reset_n => reset_n,

    clk_en_1hz => clk_en_1hz
    );

inst_output_sequencer : output_sequencer
  port map (
    clk     => clk,
    reset_n => reset_n, 

    inc     => clk_en_1hz,
    
    step    => step,
    
    H_A     => H_A_int,
    L_A     => L_A_int,
    H_B     => H_B_int,
    L_B     => L_B_int,
    H_C     => H_C_int,
    L_C     => L_C_int
  );

inst_hall_sensor : hall_sensor
  generic map (
    clk_freq => clk_freq
  )
  port map (
    clk           => clk,
    reset_n       => reset_n,

    spi_clk       => spi_clk,
    spi_miso      => spi_miso,
    spi_mosi      => spi_mosi,
    spi_hall_cs   => spi_hall_cs,

    hall_position => hall_position
  );


  H_A <= H_A_int and pwm_out;
  L_A <= L_A_int and pwm_out;
  H_B <= H_B_int and pwm_out;
  L_B <= L_B_int and pwm_out;
  H_C <= H_C_int and pwm_out;
  L_C <= L_C_int and pwm_out;

  --(led_5, led_4, led_3) <= step;

 -- led_0 <= H_A;
 -- led_1 <= L_A;
 -- led_2 <= H_B;
 -- led_3 <= L_B;
 -- led_4 <= H_C;
 -- led_5 <= L_C;

  led_7 <= hall_position(13);
  led_6 <= hall_position(12);
  led_5 <= hall_position(11);
  led_4 <= hall_position(10);
  led_3 <= hall_position(9);
  led_2 <= hall_position(8);
  led_1 <= hall_position(7);
  led_0 <= hall_position(6);


end architecture;