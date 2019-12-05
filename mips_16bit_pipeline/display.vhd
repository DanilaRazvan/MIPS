library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity display is
    
    Port(
        clk : in std_logic;
        digit0 : in std_logic_vector (3 downto 0);
        digit1 : in std_logic_vector (3 downto 0);
        digit2 : in std_logic_vector (3 downto 0);
        digit3 : in std_logic_vector (3 downto 0);
        an : out std_logic_vector (3 downto 0);
        cat : out std_logic_vector (6 downto 0)
        );
    
end display;

architecture Behavioral of display is

signal count : std_logic_vector (15 downto 0) := (others => '0');
signal HEX : std_logic_vector (3 downto 0);

begin

-- 16-bit COUNTER
process (clk)
begin
   if clk='1' and clk'event then
      count <= count + 1;
   end if;
end process;

-- MUX 1
process (count(15 downto 14), digit0, digit1, digit2, digit3)
begin
   case count(15 downto 14) is
      when "00" => HEX <= digit0;
      when "01" => HEX <= digit1;
      when "10" => HEX <= digit2;
      when "11" => HEX <= digit3;
      when others => HEX <= "0000";
   end case;
end process;

-- MUX 2
process (count(15 downto 14))
begin
   case count(15 downto 14) is
      when "00" => an <= "1110";
      when "01" => an <= "1101";
      when "10" => an <= "1011";
      when "11" => an <= "0111";
      when others => an <= "1111";
   end case;
end process;

-- HEX TO 7 SEG DCD
with HEX select
   cat <= "1111001" when "0001",   --1
          "0100100" when "0010",   --2
          "0110000" when "0011",   --3
          "0011001" when "0100",   --4
          "0010010" when "0101",   --5
          "0000010" when "0110",   --6
          "1111000" when "0111",   --7
          "0000000" when "1000",   --8
          "0010000" when "1001",   --9
          "0001000" when "1010",   --A
          "0000011" when "1011",   --b
          "1000110" when "1100",   --C
          "0100001" when "1101",   --d
          "0000110" when "1110",   --E
          "0001110" when "1111",   --F
          "1000000" when others;   --0

end Behavioral;
