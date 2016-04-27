library ieee;
use ieee.std_logic_1164.all;

entity Mul is
    port (
             A : in  std_logic;
             B : in  std_logic;
             Si : in  std_logic;
             Ci : in  std_logic; -- Carry in
             Co : out  std_logic;-- Carry out
             So : out std_logic
	     );
end entity;

architecture behavior of Mul is
begin

-- add your code here

end architecture;
