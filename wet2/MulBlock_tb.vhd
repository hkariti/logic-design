library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MulBlock_tb is
end entity;

architecture behavior of MulBlock_tb is
    component MulBlock is
        port (
            A, Si: in std_logic_vector(3 downto 0);
            B : in std_logic;
            CLK : in std_logic;
            RSTn : in std_logic;
            So : out std_logic_vector(4 downto 0)
        );
    end component;
    signal clk : std_logic;
    signal rstn : std_logic := '1';
    signal a_vec, si_vec : std_logic_vector(3 downto 0) := (others => '0');
    signal so_vec : std_logic_vector(4 downto 0) := (others =>'0');
    signal b : std_logic := '0';
    signal i : integer := 0;
begin
    pipedmul_1: MulBlock port map (
            A => a_vec,
            B => B,
            Si => si_vec,
            So => So_vec,
            clk => clk,
            rstn => rstn
        );
    process begin
        wait for 1 ns;
        clk <= '0';
        wait for 1 ns;
        clk <= '1';
    end process;

    process (clk) begin
        if (clk'event and clk = '1') then
            i <= i+1;
            si_vec <= std_logic_vector(to_unsigned(i/32, 4));
            a_vec <= std_logic_vector(to_unsigned((i mod 32)/2, 4));
            if i mod 2 = 0 then
                b <= '0';
            else
                b <= '1';
            end if;
        end if;
    end process;
end architecture;


