library ieee;
use ieee.std_logic_1164.all;

entity FA is
    port (
        A : in  std_logic;-- first number
        B : in  std_logic;-- Second number
        Cin : in  std_logic;-- Carry in
        Cout : out  std_logic;-- Carry out
        S : out std_logic -- Sum

    );
end entity;

architecture behavior of FA is
    component HA is
        port (
               A : in std_logic;
               B : in std_logic;
               Cout : out std_logic;
               S :  out std_logic
        );
    end component;
    signal s_1, s_2, cout_1, cout_2: std_logic;
begin
    ha_1: HA port map ( A => A,
                        B => B,
                        S => s_1,
                        Cout => cout_1 );
    ha_2: HA port map ( A => s_1,
                        B => Cin,
                        Cout => cout_2,
                        S => S );
    Cout <= cout_1 or cout_2;
end architecture;
