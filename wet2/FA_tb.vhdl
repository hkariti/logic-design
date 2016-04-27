library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FA_tb is
end entity;

architecture behavior of FA_tb is
    component FA is
        port (
               A : in std_logic;
               B : in std_logic;
               Cin : in std_logic;
               Cout : out std_logic;
               S :  out std_logic
        );
    end component;
    signal s, cout : std_logic;
    signal in_vec : std_logic_vector(0 to 2);
begin
    fa_1: FA port map (
                        A => in_vec(0),
                        B => in_vec(1),
                        Cin => in_vec(2),
                        S => s,
                        Cout => Cout
                    );
    process begin
        for i in 0 to 7 loop
            in_vec <= std_logic_vector(to_unsigned(i, in_vec'length));
            wait for 2 ns;
        end loop;
    end process;
end architecture;
