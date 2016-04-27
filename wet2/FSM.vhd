library ieee;
use IEEE.std_logic_1164.all;

entity FSM is
port (CLK : in std_logic; --Clock, active high
      RSTn : in std_logic; --Async. Reset, active low
      CoinIn : in std_logic_vector (1 downto 0); --Which coin was inserted
      Soda : out std_logic; --Is Soda dispensed ?
      CoinOut : out std_logic_vector (1 downto 0) --Which coin is dispensed?
  );

end entity;

architecture behavior of FSM is

-- add your code here

end behavior;
