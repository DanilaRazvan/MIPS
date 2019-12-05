library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity RAM is
port (
    clk : in std_logic;
    ra : in std_logic_vector (3 downto 0);
    wd : in std_logic_vector (15 downto 0);
    RamWr : in std_logic;
    rd : out std_logic_vector (15 downto 0)
);
end RAM;

architecture Behavioral of RAM is

type ram_array is array (0 to 15) of std_logic_vector(15 downto 0);
signal ram : ram_array := (
X"0001",
X"0010",
X"0100",
X"1000",
others => X"0000");

begin

process(clk)
begin
if rising_edge(clk) then
    if RamWr = '1' then
        ram(conv_integer(ra)) <= wd;
    end if;
end if;
end process;

rd <= ram(conv_integer(ra));

end Behavioral; 