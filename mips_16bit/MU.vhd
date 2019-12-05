library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity MU is
    Port (
        clk: in std_logic;
        MemWrite: in std_logic;
        ALUResIn: in std_logic_vector(15 downto 0);
        WriteData: in std_logic_vector(15 downto 0);
        MemData: out std_logic_vector(15 downto 0);
        ALUResOut: out std_logic_vector(15 downto 0)
     );
end MU;

architecture Behavioral of MU is

type ram_type is array (0 to 127) of std_logic_vector(15 downto 0);

signal RAM:ram_type := (
		X"0001",
		X"0002",
		X"0003",
		X"0004",
		X"0005",
		X"0006",
		X"0007",
		X"0008",
		
		others =>X"0000"
		);

begin

ALUResOut <= ALUResIn;

-- RAM
process(clk)
begin
    if rising_edge(clk) then
        if MemWrite = '1' then
            RAM(conv_integer(ALUResIn(6 downto 0))) <= WriteData;
        end if;
    end if;
    MemData <= RAM(conv_integer(ALUResIn(6 downto 0)));
end process;
    
end Behavioral;
