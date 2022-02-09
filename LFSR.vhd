library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LFSR is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           outp : out STD_LOGIC_VECTOR (3 downto 0);
           ld1 : out STD_LOGIC;
           ld2 : out STD_LOGIC;
           ld3 : out STD_LOGIC;
           ld4 : out STD_LOGIC;
           ld5 : out STD_LOGIC;
           ld6 : out STD_LOGIC;
           ld7 : out STD_LOGIC;
           ld8 : out STD_LOGIC;
           ld9 : out STD_LOGIC;
           ld10 : out STD_LOGIC;
           ld11 : out STD_LOGIC;
           ld12 : out STD_LOGIC;
           ld13 : out STD_LOGIC;
           ld14 : out STD_LOGIC;
           ld15 : out STD_LOGIC;
           ld16 : out STD_LOGIC);

           
end LFSR;

architecture Behavioral of LFSR is

component CDiv IS
	PORT ( Cin	: IN 	STD_LOGIC ;
	  Cout : OUT STD_LOGIC ) ;
END component ;

signal feedback : std_logic;
signal out_reg : std_logic_vector(3 downto 0):="0000";
signal pulse : std_logic;
begin

inst_CDiv: CDiv port map(Cin =>clk, Cout => pulse);

feedback <= not (out_reg(3) xor out_reg(2));
process (pulse,rst)
begin
    if (rst='1') then
        out_reg <= "0000";
    elsif (rising_edge(pulse)) then
        out_reg <= out_reg(2 downto 0) & feedback;
    end if;
end process;
outp <= out_reg;

process(pulse)
begin
if(rising_edge(pulse)) then
        if(out_reg = "0000") then
            ld1 <= '1';
        else
            ld1 <= '0';
        end if;
         if(out_reg = "0001") then
            ld2 <= '1';
        else
            ld2 <= '0';
        end if;
         if(out_reg = "0010") then
            ld3 <= '1';
        else
            ld3 <= '0';
        end if;
         if(out_reg = "0011") then
            ld4 <= '1';
        else
            ld4 <= '0';
        end if;
         if(out_reg = "0100") then
            ld5 <= '1';
        else
            ld5 <= '0';
        end if;
         if(out_reg = "0101") then
            ld6 <= '1';
        else
            ld6 <= '0';
        end if;
         if(out_reg = "0110") then
            ld7 <= '1';
        else
            ld7 <= '0';
        end if;
         if(out_reg = "0111") then
            ld8 <= '1';
        else
            ld8 <= '0';
        end if;
        if(out_reg = "1000") then
            ld9 <= '1';
        else
            ld9 <= '0';
        end if;
        if(out_reg = "1001") then
            ld10 <= '1';
        else
            ld10 <= '0';
        end if;
        if(out_reg = "1010") then
            ld11 <= '1';
        else
            ld11 <= '0';
        end if;
        if(out_reg = "1011") then
            ld12 <= '1';
        else
            ld12 <= '0';
        end if;
         if(out_reg = "1100") then
            ld13 <= '1';
        else
            ld13 <= '0';
        end if;
         if(out_reg = "1101") then
            ld14 <= '1';
        else
            ld14 <= '0';
        end if;
         if(out_reg = "1110") then
            ld15 <= '1';
        else
            ld15 <= '0';
         end if;   
         if(out_reg = "1111") then
            ld16 <= '1';
        else
            ld16 <= '0';
        end if;
    end if;
end process;

end Behavioral;