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

    component FA is
    port (A : in  std_logic;-- first number
        B : in  std_logic;-- Second number
        Cin : in  std_logic;-- Carry in
        Cout : out  std_logic;-- Carry out
        S : out std_logic -- Sum
    );
    end component;
    signal c1 : std_logic;
    
begin
    fa_1 : FA port map ( A => A,
    B=> B,
    Cin => '0',
    Cout => c1
    );
    
    fa_2 : FA port map ( A => c1,
    B => Si,
    Cin => Ci,
    S => So,
    Cout => Co);

-- add your code here

end architecture;
