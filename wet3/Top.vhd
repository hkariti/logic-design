library ieee;
use ieee.std_logic_1164.all;

entity Reg is
    generic (R_DATA_WIDTH : integer := 32);
    port (
        D: in std_logic_vector(R_DATA_WIDTH-1 downto 0);
        Q: out std_logic_vector(R_DATA_WIDTH-1 downto 0);
        CLK: in std_logic;
        RSTn: in std_logic;
        En: in std_logic
         );
end entity;

architecture behavior of Reg is
begin
    process(RSTn, clk) begin
        if RSTn = '0' then
            Q <= ( others => '0' );
        elsif (clk'event and clk = '1' and en = '1') then
            Q <= D;
        end if;
    end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity Mux3 is
generic ( M_DATA_WIDTH : integer := 32 );
port (
	A : in  std_logic_vector(M_DATA_WIDTH-1 downto 0);-- Mux first input
	B : in  std_logic_vector(M_DATA_WIDTH-1 downto 0);-- Mux Second input
	C : in  std_logic_vector(M_DATA_WIDTH-1 downto 0);-- Mux Third input
    S : in  std_logic_vector(1 downto 0);-- Select input
	Z : out  std_logic_vector(M_DATA_WIDTH-1 downto 0) := "00"-- Mux Out
);
end entity;

architecture behavior of Mux3 is

begin
process (A, B, C, S) begin
    if (s(0) = '0' and s(1) = '0') then
        z <= A;
    elsif (s(0) = '1' and s(1) = '0') then
        z <= B;
    else
        Z <= C;
    end if;
end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity Mux4 is
generic ( M_DATA_WIDTH : integer := 32 );
port (
	A : in  std_logic_vector(M_DATA_WIDTH-1 downto 0);-- Mux first input
	B : in  std_logic_vector(M_DATA_WIDTH-1 downto 0);-- Mux second input
	C : in  std_logic_vector(M_DATA_WIDTH-1 downto 0);-- Mux third input
	D : in  std_logic_vector(M_DATA_WIDTH-1 downto 0);-- Mux fourth input
	S:  in  std_logic_vector(1 downto 0);-- Select input
	Z : out  std_logic_vector(M_DATA_WIDTH-1 downto 0)-- Mux output
);
end entity;

architecture behavior of Mux4 is

signal mux3_1_out : std_logic_vector(M_DATA_WIDTH downto 0);
signal not_out : std_logic := '0';
signal s_mux_3_2 : std_logic_vector(1 downto 0);
component mux3
	port (A, B, C: in std_logic_vector(M_DATA_WIDTH downto 0);
        s : in std_logic_vector(1 downto 0);
		z: out std_logic_vector(M_DATA_WIDTH downto 0));
end component;

begin
not_out <= not s(0);
s_mux_3_2 <= ( 0 => not_out, 1=> s(1));
mux3_1: mux3 port map (
	s  => s,
	A => A,
	B => B,
	C => A,
	Z => mux3_1_out );

mux_3_2: mux3 port map (
	s => s_mux_3_2,
	A => C,
	B => D,
	C => mux3_1_out,
	Z => Z
	);
end architecture;

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
      RSTn : in std_logic; --Async. Reset, active low
      S0, S1, S2, S3, S4, S5 : out std_logic_vector(1 downto 0); -- Mux control
      WeA, WeB, WeC, WeD : out std_logic -- Register control
  );
end component;

component Mux3 is
generic ( M_DATA_WIDTH : integer := N );
port (
	A : in  std_logic_vector(M_DATA_WIDTH-1 downto 0);-- Mux first input
	B : in  std_logic_vector(M_DATA_WIDTH-1 downto 0);-- Mux Second input
	C : in  std_logic_vector(M_DATA_WIDTH-1 downto 0);-- Mux Third input
    S : in  std_logic_vector(1 downto 0);-- Select input
	Z : out  std_logic_vector(M_DATA_WIDTH-1 downto 0) := "00"-- Mux Out
);
end component;

component Mux4 is
generic ( M_DATA_WIDTH : integer := N );
port (
	A : in  std_logic_vector(M_DATA_WIDTH-1 downto 0);-- Mux first input
	B : in  std_logic_vector(M_DATA_WIDTH-1 downto 0);-- Mux Second input
	C : in  std_logic_vector(M_DATA_WIDTH-1 downto 0);-- Mux Third input
	D : in  std_logic_vector(M_DATA_WIDTH-1 downto 0);-- Mux Fourth input
    S : in  std_logic_vector(1 downto 0);-- Select input
	Z : out  std_logic_vector(M_DATA_WIDTH-1 downto 0) := "00"-- Mux Out
);
end component;

component Reg is
    generic (R_DATA_WIDTH : integer := N);
    port (
        D: in std_logic_vector(R_DATA_WIDTH-1 downto 0);
        Q: out std_logic_vector(R_DATA_WIDTH-1 downto 0);
        CLK: in std_logic;
        RSTn: in std_logic;
        En: in std_logic
     );
end component;

signal Ato2,Bto2,MinFrom2,MaxFrom2 : std_logic_vector (N-1 downto 0);
signal S0, S1, S2, S3, S4, S5 : std_logic_vector(1 downto 0); -- Mux control
signal WeA, WeB, WeC, WeD : std_logic; -- Register control
signal m0_out, m1_out, m2_out, m3_out, m4_out, m5_out: std_logic_vector(N-1 downto 0);
signal r0_out, r1_out, r2_out, r3_out : std_logic_vector(N-1 downto 0);

begin

U0 : Compare2 generic map (N=>N)
      port map (A=>Ato2,B=>Bto2,Max=>MaxFrom2,Min=>MinFrom2);

U1 : ContComp
      port map (CLK=>CLK,RSTn=>RSTn, WeA=>WeA, WeB=>WeB, WeC=>WeC, WeD=>WeD, s0=>s0, s1=>s1, s2=>s2, s3=>s3, s4=>s4, s5=>s5);

r0: Reg
      port map (CLK=>CLK, RSTn=>RSTn, D=>m0_out, Q=>r0_out, en=>WeA);

r1: Reg
      port map (CLK=>CLK, RSTn=>RSTn, D=>m1_out, Q=>r1_out, en=>WeB);

r2: Reg
      port map (CLK=>CLK, RSTn=>RSTn, D=>m2_out, Q=>r2_out, en=>WeC);

r3: Reg
      port map (CLK=>CLK, RSTn=>RSTn, D=>m3_out, Q=>r3_out, en=>WeD);

m0: mux3
    port map (A => A, B => MinFrom2, C => MaxFrom2, Z => m0_out, s=>s0);

m1: mux3
    port map (A => B, B => MinFrom2, C => MaxFrom2, Z => m1_out, s=>s1);

m2: mux3
    port map (A => C, B => MinFrom2, C => MaxFrom2, Z => m2_out, s=>s2);

m3: mux3
    port map (A => D, B => MinFrom2, C => MaxFrom2, Z => m3_out, s=>s3);

m4: mux4
    port map(A => r0_out, B => r1_out, C => r2_out, D => r3_out, Z => Ato2, s=>s4);

m5: mux4
    port map(A => r0_out, B => r1_out, C => r2_out, D => r3_out, Z => Bto2, s=>s5);

end architecture;
