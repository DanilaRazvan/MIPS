library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity debouncer is
    Port (  btn : in std_logic_vector (4 downto 0);
            clk : in std_logic;
            enable : out std_logic_vector (4 downto 0));
end debouncer;

architecture Behavioral of debouncer is

signal count : std_logic_vector (15 downto 0) := (others => '0');
signal enabler1 : std_logic;
signal q1 : std_logic_vector (4 downto 0);
signal q2 : std_logic_vector (4 downto 0);
signal q3 : std_logic_vector (4 downto 0);

begin

-- COUNTER
process (clk)
begin
   if clk='1' and clk'event then
      count <= count + 1;
   end if;
end process;

-- REG 1
process (clk)
begin
    if clk'event and clk='1' then
        if enabler1 = '1' then
            q1 <= btn;
        end if;
    end if;
end process;

-- REG 2
process (clk)
begin
   if clk'event and clk='1' then
      q2 <= q1;
   end if;
end process;

-- REG 3
process (clk)
begin
   if clk'event and clk='1' then
      q3 <= q2;
   end if;
end process;

enable <= q2 and (not q3);

with count select
    enabler1 <= '1' when "1111111111111111",
                '0' when others;

end Behavioral;