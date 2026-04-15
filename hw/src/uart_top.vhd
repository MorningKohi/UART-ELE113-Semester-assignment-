library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_top is
    port(
        CLOCK_50 : in std_logic;
        SW : in std_logic_vector(17 downto 0);
        KEY : in std_logic_vector(3 downto 0);
        --GPIO : inout std_logic_vector(35 downto 0);
        EX_IO : inout std_logic_vector(6 downto 0);
        LEDR : out std_logic_vector(17 downto 0);
        LEDG :out std_logic_vector(7 downto 0);
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,HEX6,HEX7 : out std_logic_vector(6 downto 0)
    );
end entity uart_top;

architecture Struct of uart_top is
component tx_top is
    port(
        CLOCK_50 : in std_logic;
        SW : in std_logic_vector(17 downto 0);
        KEY : in std_logic_vector(3 downto 0);
        --GPIO : inout std_logic_vector(35 downto 0);
        EX_IO : inout std_logic_vector(6 downto 0);        
        LEDR : out std_logic_vector(17 downto 0)
        --HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out std_logic_vector(6 downto 0)
    );
end component tx_top;

component rx_top
    port(
        CLOCK_50                                       : in    std_logic;
        SW                                             : in    std_logic_vector(17 downto 0);
        KEY                                            : in    std_logic_vector(3 downto 0);
        --GPIO                                           : inout std_logic_vector(35 downto 0);
        EX_IO : inout std_logic_vector(6 downto 0);
        LEDR                                           : out   std_logic_vector(17 downto 0);
        LEDG                                           : out   std_logic_vector(7 downto 0);
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7 : out   std_logic_vector(6 downto 0)
    );
end component rx_top;

begin

    tx_top_inst : component tx_top
        port map(
            CLOCK_50 => CLOCK_50,
            SW       => SW,
            KEY      => KEY,
            EX_IO     => EX_IO,
            LEDR     => LEDR
        );
    
    rx_top_inst : component rx_top
        port map(
            CLOCK_50 => CLOCK_50,
            SW       => SW,
            KEY      => KEY,
            EX_IO     => EX_IO,
            LEDR     => open,
            LEDG     => LEDG,
            HEX0     => HEX0,
            HEX1     => HEX1,
            HEX2     => HEX2,
            HEX3     => HEX3,
            HEX4     => HEX4,
            HEX5     => HEX5,
            HEX6     => HEX6,
            HEX7     => HEX7
        );
    
end architecture Struct;
