library ieee;
use ieee.std_logic_1164.all;

entity PipedMul is
    port (
        A    : in  std_logic_vector (3 downto 0); --First number
        B    : in  std_logic_vector (1 downto 0); --Second number
        CLK  : in  std_logic; -- Clock (Active high)
        RSTn : in  std_logic; -- Reset (Active low)
        S    : out std_logic_vector (5 downto 0) -- Result
    );
end entity;

architecture behavior of PipedMul is
    component Reg is
        generic ( R_DATA_WIDTH : integer := 8);
        port (
             D: in std_logic_vector(R_DATA_WIDTH-1 downto 0);
             Q: out std_logic_vector(R_DATA_WIDTH-1 downto 0);
             CLK: in std_logic;
             RSTn: in std_logic
         );
    end component;
    component MulBlock is
        port (
            A, Si: in std_logic_vector(3 downto 0);
            B : in std_logic;
            CLK : in std_logic;
            RSTn : in std_logic;
            So : out std_logic_vector(4 downto 0)
    );
    end component;
    signal line1_in0, line1_in1 : std_logic_vector(4 downto 0);
    signal s1_out0, s1_out1, c_corner : std_logic;
    signal s4_out : std_logic_vector(3 downto 0);
    signal s3_out : std_logic_vector(2 downto 0);
    signal s2_out : std_logic_vector(1 downto 0);
    signal s_line0, s_line1 : std_logic_vector(4 downto 0);
begin
   reg0: Reg generic map (5)
        port map (
        D(3 downto 0) => A,
        D(4) => B(1),
        Q => line1_in0,
        CLK => CLK,
        RSTn => RSTn
    );
   reg1: Reg generic map (5)
        port map (
        D => line1_in0,
        Q => line1_in1,
        CLK => CLK,
        RSTn => RSTn
    );
   reg_c_corner: Reg generic map (1)
        port map (
        D => s_line0(4 downto 4),
        Q(0) => c_corner,
        CLK => CLK,
        RSTn => RSTn
    );
   line0: MulBlock port map (
        A => A,
        B => B(0),
        Si => (others=>'0'),
        So => s_line0,
        CLK => CLK,
        RSTn => RSTn
    );
   line1: MulBlock port map (
        A => line1_in1(3 downto 0),
        B => line1_in1(4),
        Si(2 downto 0) => s_line0(3 downto 1),
        Si(3) => c_corner,
        So => s_line1,
        CLK => CLK,
        RSTn => RSTn
    );
   out_reg_4: Reg generic map (4)
    port map(
        D(3 downto 1) => s_line1(2 downto 0),
        D(0) => s_line0(0),
        Q => s4_out,
        CLK => CLK,
        RSTn => RSTn
    );
   out_reg_3: Reg generic map (3)
    port map(
        D => s4_out(2 downto 0),
        Q => s3_out,
        CLK => CLK,
        RSTn => RSTn
    );
   out_reg_2: Reg generic map (2)
    port map(
        D => s3_out(1 downto 0),
        Q => s2_out,
        CLK => CLK,
        RSTn => RSTn
    );
   out_reg_1a: Reg generic map (1)
    port map(
        D => s2_out(0 downto 0),
        Q(0) => s1_out0,
        CLK => CLK,
        RSTn => RSTn
    );
   out_reg_1b: Reg generic map (1)
    port map(
        D(0) => s1_out0,
        Q(0) => s1_out1,
        CLK => CLK,
        RSTn => RSTn
    );
    S(5) <= s_line1(4);
    s(4) <= s_line1(3);
    s(3) <= s4_out(3);
    s(2) <= s3_out(2);
    s(1) <= s2_out(1);
    s(0) <= s1_out1;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity Reg is
    generic (R_DATA_WIDTH : integer := 6);
    port (
        D: in std_logic_vector(R_DATA_WIDTH-1 downto 0);
        Q: out std_logic_vector(R_DATA_WIDTH-1 downto 0);
        CLK: in std_logic;
        RSTn: in std_logic
         );
end entity;

library ieee;
use ieee.std_logic_1164.all;

entity MulBlock is
    port (
        A, Si: in std_logic_vector(3 downto 0);
        B : in std_logic;
        CLK : in std_logic;
        RSTn : in std_logic;
        So : out std_logic_vector(4 downto 0)
    );
end entity;

library ieee;
use ieee.std_logic_1164.all;

entity MulWithReg is
    port (
        A   : in std_logic;
        B   : in std_logic;
        Ci  : in std_logic;
        Si  : in std_logic;
        CLK : in std_logic;
        RSTn: in std_logic;
        Co  : out std_logic_vector(0 downto 0);
        So  : out std_logic_vector(0 downto 0)
    );
end entity;

architecture behavior of Reg is
begin
    process(RSTn, clk) begin
        if RSTn = '0' then
            Q <= ( others => '0' );
        elsif (clk'event and clk = '1') then
            Q <= D;
        end if;
    end process;
end architecture;

architecture behavior of MulWithReg is
    component Mul is
        port (
            A   : in std_logic;
            B   : in std_logic;
            Ci  : in std_logic;
            Si  : in std_logic;
            Co  : out std_logic;
            So  : out std_logic
        );
    end component;
    component Reg is
        generic ( R_DATA_WIDTH : integer := 1 );
        port (
            D: in std_logic_vector(R_DATA_WIDTH-1 downto 0);
            Q: out std_logic_vector(R_DATA_WIDTH-1 downto 0);
            CLK: in std_logic;
            RSTn: in std_logic
        );
    end component;
    signal s_val, c_val : std_logic_vector(0 downto 0);
begin
    mul_1: Mul port map (
        A => A,
        B => B,
        Ci => Ci,
        Si => Si,
        Co => c_val(0),
        So => s_val(0)
    );
    reg_c: Reg port map (
        D => c_val,
        Q => Co,
        CLK => CLK,
        RSTn => RSTn
    );
    reg_s: Reg port map (
        D => s_val,
        Q => So,
        CLK => CLK,
        RSTn => RSTn
    );
end architecture;

architecture behavior of MulBlock is
    component MulWithReg 
        port (
                 A   : in std_logic;
                 B   : in std_logic;
                 Ci  : in std_logic;
                 Si  : in std_logic;
                 CLK : in std_logic;
                 RSTn: in std_logic;
                 Co  : out std_logic_vector(0 downto 0);
                 So  : out std_logic_vector(0 downto 0)
         );
    end component;
    component Reg
        generic ( R_DATA_WIDTH : integer := 2 );
        port (
            D: in std_logic_vector(R_DATA_WIDTH-1 downto 0);
            Q: out std_logic_vector(R_DATA_WIDTH-1 downto 0);
            CLK: in std_logic;
            RSTn: in std_logic
        );
    end component;
    signal in0 : std_logic_vector(5 downto 0);
    signal in1 : std_logic_vector(3 downto 0);
    signal in2 : std_logic_vector(1 downto 0);
    signal carries : std_logic_vector(2 downto 0);
begin
    reg0: Reg generic map (6)
        port map (
        D(0) => A(1),
        D(1) => B,
        D(2) => A(2),
        D(3) => B,
        D(4) => A(3),
        D(5) => B,
        Q => in0,
        CLK => CLK,
        RSTn => RSTn
    );
    reg1: Reg generic map (4)
        port map (
            D => in0(5 downto 2),
            Q => in1,
            CLK => CLK,
            RSTn => RSTn
    );
    reg3: Reg port map (
        D => in1(3 downto 2),
        Q => in2,
        CLK => CLK,
        RSTn => RSTn
    );
    mul0: MulWithReg port map (
        A => A(0),
        B => B,
        Ci => '0',
        Si => Si(0),
        CLK => CLK,
        RSTn => RSTn,
        So(0) => So(0),
        Co(0) => carries(0)
    );
    mul1: MulWithReg port map (
        A => in0(0),
        B => in0(1),
        Ci => carries(0),
        Si => Si(1),
        CLK => CLK,
        RSTn => RSTn,
        So(0) => So(1),
        Co(0) => carries(1)
    );
    mul2: MulWithReg port map (
        A => in1(0),
        B => in1(1),
        Ci => carries(1),
        Si => Si(2),
        CLK => CLK,
        RSTn => RSTn,
        So(0) => So(2),
        Co(0) => carries(2)
    );
    mul3: MulWithReg port map (
        A => in2(0),
        B => in2(1),
        Ci => carries(2),
        Si => Si(3),
        CLK => CLK,
        RSTn => RSTn,
        So(0) => So(3),
        Co(0) => So(4)
    );
end architecture;
