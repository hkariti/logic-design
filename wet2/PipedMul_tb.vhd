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
    signal clk : std_logic := '0';
    signal s: std_logic_vector(5 downto 0);
    signal rstn : std_logic := '1';
    signal i : integer := 0;
    signal a_vec : std_logic_vector(3 downto 0) := (others => '0');
    signal b_vec : std_logic_vector(1 downto 0) := (others => '0');
begin
    pipedmul_1: PipedMul port map (
            A => a_vec,
            B => b_vec,
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
        rstn <= '0';
        wait for 1 ns;
        rstn <= '1';
        wait;
    end process;
    process (clk) begin
        if (clk'event and clk = '1') then
            i <= i + 1;
            a_vec <= std_logic_vector(to_unsigned(i/4, 4));
            b_vec <= std_logic_vector(to_unsigned(i mod 4, 2));
        end if;
    end process;
end architecture;
