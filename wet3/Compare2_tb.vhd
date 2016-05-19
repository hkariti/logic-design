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
    signal vector_i : std_logic_vector(2*N-1 downto 0);
begin
    cmp: Compare2 generic map (N => N) port map (
        A => A,
        B => B,
        Max => Max,
        Min => Min
    );

    A <= vector_i(2*N-1 downto N);
    B <= vector_i(N-1 downto 0);
    process begin
        vector_i <= std_logic_vector(to_unsigned(i, 2*N));
        i <= i + 1;
        wait for 1 ns;
    end process;
end architecture;
