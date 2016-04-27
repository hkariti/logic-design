library ieee;
use ieee.std_logic_1164.all;

entity HA is
    port (
        A : in  std_logic;-- first number
        B : in  std_logic;-- Second number
        Cout : out  std_logic;-- Carry out
        S : out std_logic -- Sum

    );
end entity;

architecture behavior of HA is

begin

    S <= A xor B;
    Cout <= A and B;

end architecture;
