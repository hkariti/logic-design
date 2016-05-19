library ieee;
use ieee.std_logic_1164.all;

entity Top_tb is
end entity;

architecture behavior of Top_tb is
    component Top is
        generic (N : integer := 4);
        port (CLK : in std_logic; --Clock, active high
              RSTn : in std_logic; --Async. Reset, active low
              A : in  std_logic_vector (N-1 downto 0);-- first number
              B : in  std_logic_vector (N-1 downto 0);-- Second number
              C : in  std_logic_vector (N-1 downto 0);-- third number
              D : in  std_logic_vector (N-1 downto 0);-- fourth number
              First : out std_logic_vector (N-1 downto 0);-- smallest number
              Second : out std_logic_vector (N-1 downto 0);-- mid1 number
              Third : out std_logic_vector (N-1 downto 0);-- mid2 number
              Fourth : out std_logic_vector (N-1 downto 0) -- largest number
          );
    end component;
    signal rstn, clk : std_logic;
    signal first, second, third, fourth : std_logic_vector(3 downto 0);
begin
    top_a: Top port map (A=>"0001", B=>"0011", C=>"0010", D=>"0100", first=>first, second=>second, third=>third, fourth=>fourth, clk=>clk, rstn=>rstn);
    process begin
        rstn <= '0';
        wait for 2 ns;
        rstn <= '1';
        wait; 
    end process;
    process begin
        clk <= '0';
        wait for 1 ns;
        clk <= '1';
        wait for 1 ns;
    end process;
end architecture;
