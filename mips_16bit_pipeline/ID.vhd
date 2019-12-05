library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ID is
    Port (
        clk: in std_logic;
        Instr: in std_logic_vector(15 downto 0);
        WA: in std_logic_vector(2 downto 0);
        WD: in std_logic_vector(15 downto 0);
        RegWrite: in std_logic;
        ExtOp: in std_logic;
        RD1: out std_logic_vector(15 downto 0);
        RD2: out std_logic_vector(15 downto 0);
        ExtImm: out std_logic_vector(15 downto 0);
        func: out std_logic_vector(2 downto 0);
        sa: out std_logic
        );
end ID;

architecture Behavioral of ID is

component reg_file is
port (
    clk : in std_logic;
    ra1 : in std_logic_vector (2 downto 0);
    ra2 : in std_logic_vector (2 downto 0);
    wa : in std_logic_vector (2 downto 0);
    wd : in std_logic_vector (15 downto 0);
    RegWr : in std_logic;
    rd1 : out std_logic_vector (15 downto 0);
    rd2 : out std_logic_vector (15 downto 0)
);
end component;

signal ExtImmOut: std_logic_vector(15 downto 0);
signal ReadAddress1: std_logic_vector(2 downto 0);
signal ReadAddress2: std_logic_vector(2 downto 0);
signal WriteAddress: std_logic_vector(2 downto 0);

begin

RF: reg_file port map ( clk => clk,
                        ra1 => ReadAddress1,
                        ra2 => ReadAddress2,
                        wa => WA,
                        wd => WD,
                        RegWr => RegWrite,
                        rd1 => rd1,
                        rd2 => rd2
                        );


-- EXT UNIT
process(ExtOp, Instr)
begin
case(ExtOp) is
    when '0' => ExtImmOut <= "000000000" & Instr(6 downto 0);
    when others => 
        case (Instr(6)) is
            when '0' => ExtImmOut <= "000000000" & Instr(6 downto 0);
            when '1' => ExtImmOut <= "111111111" & Instr(6 downto 0);
            when others => ExtImmOut <= ExtImmOut;
        end case;
end case;
end process;

func <= instr(2 downto 0);
sa <= instr(3);
ExtImm <= ExtImmOut;
ReadAddress1 <= Instr(12 downto 10);
ReadAddress2 <= Instr(9 downto 7);

end Behavioral;
