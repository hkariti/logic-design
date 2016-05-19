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
	Z : out  std_logic_vector(M_DATA_WIDTH-1 downto 0) := (others=>'0')-- Mux Out
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

signal mux3_1_out : std_logic_vector(M_DATA_WIDTH-1 downto 0);
signal not_out : std_logic := '0';
signal s_mux_3_2 : std_logic_vector(1 downto 0);
component mux3
    generic ( M_DATA_WIDTH : integer := M_DATA_WIDTH );
	port (A, B, C: in std_logic_vector(M_DATA_WIDTH-1 downto 0);
        s : in std_logic_vector(1 downto 0);
		z: out std_logic_vector(M_DATA_WIDTH-1 downto 0));
end component;

begin
not_out <= not s(1);
s_mux_3_2 <= ( 0 => s(0), 1=> not_out);

mux3_1: mux3
port map ( s  => s, A => A, B => B, C => A, Z => mux3_1_out );

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

type mux_outs is array(5 downto 0) of std_logic_vector(N-1 downto 0);
type mux_selectors is array (5 downto 0) of std_logic_vector(1 downto 0);
type reg_outs is array(3 downto 0) of std_logic_vector(N-1 downto 0);
type inputs is array (3 downto 0) of std_logic_vector(N-1 downto 0);
signal Ato2,Bto2,MinFrom2,MaxFrom2 : std_logic_vector (N-1 downto 0);
signal mux_s : mux_selectors;
signal reg_en: std_logic_vector(3 downto 0); 
signal m_out : mux_outs;
signal r_out : reg_outs;
signal num_inputs : inputs := (D,C,B,A);

begin

U0 : Compare2 generic map (N=>N)
      port map (A=>Ato2,B=>Bto2,Max=>MaxFrom2,Min=>MinFrom2);

U1 : ContComp
      port map (CLK=>CLK,RSTn=>RSTn, WeA=>reg_en(0), WeB=>reg_en(1), WeC=>reg_en(2), WeD=>reg_en(3), s0=>mux_s(0), s1=>mux_s(1), s2=>mux_s(2), s3=>mux_s(3), s4=>mux_s(4), s5=>mux_s(5));

gen_reg: for i in 0 to 3 generate
    r: Reg
        port map (CLK=>CLK, RSTn=>RSTn, d=>m_out(i), Q=>r_out(i), en=>reg_en(i));
end generate;

mux3_gen: for i in 0 to 3 generate
    m3: Mux3 
        port map (A => num_inputs(i), B => MinFrom2, C => MaxFrom2, Z => m_out(i), s=>mux_s(i));
end generate;

m4_0: Mux4
    port map(A => r_out(0), B => r_out(1), C => r_out(2), D => r_out(3), Z => Ato2, s=>mux_s(4));

m4_1: Mux4
    port map(A => r_out(0), B => r_out(1), C => r_out(2), D => r_out(3), Z => Bto2, s=>mux_s(5));

    first <= r_out(0);
    second <= r_out(1);
    third <= r_out(2);
    fourth <= r_out(3);
end architecture;
