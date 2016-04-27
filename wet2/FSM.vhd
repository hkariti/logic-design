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
    component Reg
        generic ( R_DATA_WIDTH : integer := 3);
        port (
             D: in std_logic_vector(R_DATA_WIDTH-1 downto 0);
             Q: out std_logic_vector(R_DATA_WIDTH-1 downto 0);
             CLK: in std_logic;
             RSTn: in std_logic
         );
    end component;
    signal ps, ns : std_logic_vector(2 downto 0);
begin
    state: Reg port map (
        D => ns,
        Q => ps,
        CLK => CLK,
        RSTn => RSTn
    );

    ns(0) <= (((not ps(0)) and (not ps(1)) and (not ps(2))) and ((not CoinIn(1)) and CoinIn(0)))
             or
             ((ps(0) and (not ps(1)) and (not ps(2)) and (CoinIn(1) or (not CoinIn(0)))))
             or
             ((not ps(0)) and ps(1) and (not ps(2)) and (CoinIn(0) xor CoinIn(1)))
             or
             (ps(2) and (not ps(1)) and ps(0))
             or
             ((not ps(2)) and ps(1) and ps(0))
             or
             (ps(2) and (not ps(1)) and (not ps(0)));

    ns(1) <= ((not (ps(2)) and ps(1) and (not ps(0))))
             or
             (((not ps(2)) and (not ps(1)) and ps(0)) and (CoinIn(0) xor CoinIn(1)))
             or 
             ( (not ps(2)) and ( not ps(1) ) and (not ps(0)) and CoinIn(1) and (not CoinIn(0)) )
             or
             (ps(2) and (not ps(1)) and (not ps(0)))
             or
             ((not ps(2)) and ps(1) and ps(0))
             or
             (ps(2) and (not ps(1)) and ps(0));
    ns(2) <= ( (not ps(2)) and (not ps(1)) and (not ps(0)) and CoinIn(0) and CoinIn(1) )
             or
             ( (not ps(2)) and (not ps(1)) and ps(0) and CoinIn(1) )
             or
             ( (not ps(2)) and ps(1) and (not ps(0)) and CoinIn(0) )
             or
             ((not ps(2)) and ps(1) and ps(0))
             or
             (ps(2) and (not ps(1)) and (not ps(0)))
             or
             (ps(2) and ps(1) and (not ps(0)));

    soda <=  (ps(2) and ps(1) and ps(0));   
    CoinOut(0) <= ((not ps(2)) and ps(1) and ps(0));
    CoinOut(1) <=  (ps(2) and ( not ps(1)) and (not ps(0)))
                   or
                   (ps(2) and (not ps(1)) and ps(0))
                   or
                   (ps(2) and ps(1) and (not ps(0)));
end behavior;
