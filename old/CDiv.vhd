LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY CDiv IS
	PORT (
		Cin : IN STD_LOGIC;
		Cout : OUT STD_LOGIC);
END CDiv;

ARCHITECTURE Behavior OF CDiv IS
	CONSTANT TC : INTEGER := 100; --Time Constant. 15 for ~1khz
	--	constant TC: integer := 40; --Time Constant. 15 for ~1khz
	SIGNAL c0, c1, c2, c3 : INTEGER RANGE 0 TO 1000;
	SIGNAL D : STD_LOGIC := '0';
BEGIN
	PROCESS (Cin)
	BEGIN
		IF (Cin'event AND Cin = '1') THEN
			c0 <= c0 + 1;
			IF c0 = TC THEN
				c0 <= 0;
				c1 <= c1 + 1;
			ELSIF c1 = TC THEN
				c1 <= 0;
				c2 <= c2 + 1;
			ELSIF c2 = TC THEN
				c2 <= 0;
				c3 <= c3 + 1;
			ELSIF c3 = TC THEN
				c3 <= 0;
				D <= NOT D;
			END IF;
		END IF;
		Cout <= D;
	END PROCESS;
END Behavior;
