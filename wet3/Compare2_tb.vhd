library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Compare2_tb is
end entity;

architecture behavior of Compare2_tb is
    component Compare2 is
      generic (N : integer := 4);
        port (
            A : in  std_logic_vector (N-1 downto 0);-- first number
            B : in  std_logic_vector (N-1 downto 0);-- Second number
            Max : out std_logic_vector (N-1 downto 0);-- Larger number
            Min : out std_logic_vector (N-1 downto 0)-- Smaller number
        );
    end component;
    signal N : integer := 4;
    signal A, B, Max, Min : std_logic_vector (N-1 downto 0);
    signal i : integer := 0;
begin
    cmp: Compare2 port map (
        A => A,
        B => B,
        Max => Max,
        Min => Min
    );

    process begin
        A <= std_logic_vector(to_unsigned(i/N, N));
        B <= std_logic_vector(to_unsigned(i mod N, N));
        i <= i + 1;
        wait for 1 ns;
    end process;
end architecture;
