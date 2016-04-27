library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PipedMul_tb is
end entity;

architecture behavior of PipedMul_tb is
    component PipedMul is
        port (
               A : in std_logic_vector(3 downto 0);
               B : in std_logic_vector(1 downto 0);
               S : out std_logic_vector(5 downto 0);
               CLK : in std_logic;
                RstN : std_logic
        );
    end component;
    signal clk : std_logic;
    signal s: std_logic_vector(5 downto 0);
    signal rstn : std_logic := '1';
    signal in_vec : std_logic_vector(5 downto 0);
begin
    pipedmul_1: PipedMul port map (
            A => in_vec(5 downto 2),
            B => in_vec(1 downto 0),
            S => s,
            clk => clk,
            rstn => rstn
        );
    process begin
        wait for 1 ns;
        clk <= '0';
        wait for 1 ns;
        clk <= '1';
    end process;

    process begin
        for i in 0 to 63 loop
            in_vec <= std_logic_vector(to_unsigned(i, in_vec'length));
            wait for 2 ns;
        end loop;
    end process;
end architecture;
