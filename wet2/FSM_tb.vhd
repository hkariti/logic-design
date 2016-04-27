library ieee;
use IEEE.std_logic_1164.all;

entity FSM_tb is

end entity;

architecture behavior of FSM_tb is
    component FSM
        port (CLK : in std_logic; --Clock, active high
              RSTn : in std_logic; --Async. Reset, active low
              CoinIn : in std_logic_vector (1 downto 0); --Which coin was inserted
              Soda : out std_logic; --Is Soda dispensed ?
              CoinOut : out std_logic_vector (1 downto 0) --Which coin is dispensed?
        );
    end component;
    signal clk, soda : std_logic := '0';
    signal rstn : std_logic := '1';
    signal CoinIn : std_logic_vector (1 downto 0) := (others => '0');
    signal CoinOut : std_logic_vector(1 downto 0);
    signal i : integer := 0;
begin
    fsm_1: FSM port map (
        CoinIn => CoinIn,
        Soda => soda,
        CoinOut => CoinOut,
        CLK => clk,
        RSTn => rstn
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
            CoinIn <= std_logic_vector(to_unsigned(i, 2));
        end if;
    end process;

