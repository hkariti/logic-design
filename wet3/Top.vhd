library ieee;
use ieee.std_logic_1164.all;

entity Top is
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
end entity;

architecture behavior of Top is

component Compare2 is
  generic (N : integer := 4);
    port (
        A : in  std_logic_vector (N-1 downto 0);-- first number
        B : in  std_logic_vector (N-1 downto 0);-- Second number
        Max : out std_logic_vector (N-1 downto 0);-- Larger number
        Min : out std_logic_vector (N-1 downto 0) -- Smaller number
    );
end component;

component ContComp is
port (CLK : in std_logic; --Clock, active high
      RSTn : in std_logic --Async. Reset, active low
  );
end component;

signal Ato2,Bto2,MinFrom2,MaxFrom2 : std_logic_vector (N-1 downto 0);

begin

U0 : Compare2 generic map (N=>N)
      port map (A=>Ato2,B=>Bto2,Max=>MaxFrom2,Min=>MinFrom2);

U1 : ContComp
      port map (CLK=>CLK,RSTn=>RSTn);

end architecture;

