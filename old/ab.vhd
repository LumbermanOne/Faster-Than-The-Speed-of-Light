LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY LFSR5 IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        leds : BUFFER STD_LOGIC_VECTOR(15 DOWNTO 0);
        sw : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        AN : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        CAT : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        btn : IN STD_LOGIC
    );
END LFSR5;

ARCHITECTURE Behavioral OF LFSR5 IS

    COMPONENT CDiv IS
        PORT (
            Cin : IN STD_LOGIC;
            Cout : OUT STD_LOGIC);
    END COMPONENT;

    SIGNAL feedback : STD_LOGIC;
    SIGNAL out_reg : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00010";
    SIGNAL pulse : STD_LOGIC;
    SIGNAL score : STD_LOGIC_VECTOR(7 DOWNTO 0) := X"00";

    SIGNAL LED_cntl : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00"; --bit to control 2 digit display mux
    SIGNAL LED_out : STD_LOGIC_VECTOR(3 DOWNTO 0) := X"0"; --vector to transfer data to the LED_BCD
    SIGNAL refresh : STD_LOGIC_VECTOR(19 DOWNTO 0) := X"00000"; --vector to control timing for 2 digit display
    SIGNAL start, end_game : STD_LOGIC := '0';
    SIGNAL up, down : STD_LOGIC_VECTOR(1 DOWNTO 0) := "01";
    SIGNAL sw_old : STD_LOGIC_VECTOR(15 DOWNTO 0);

    -- FUNCTION updateScore(sw : STD_LOGIC; sw_old : STD_LOGIC; score : STD_LOGIC_VECTOR(7 DOWNTO 0); leds : STD_LOGIC_VECTOR(15 DOWNTO 0); ledcheck : STD_LOGIC_VECTOR(15 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
    --     VARIABLE newScore : STD_LOGIC_VECTOR(7 DOWNTO 0);
    -- BEGIN
    --     IF (sw_old = '0' AND sw = '1') THEN
    --         IF (leds = ledcheck) THEN
    --             newScore := score + 1;
    --         ELSE
    --             IF (score /= X"00") THEN
    --                 newScore := score - 1;
    --             ELSE
    --                 newScore := score;
    --             END IF;
    --         END IF;
    --     ELSIF (sw_old = '1' AND sw = '0') THEN
    --         IF (leds = ledcheck) THEN
    --             newScore := score + 1;
    --         ELSE
    --             IF (score /= X"00") THEN
    --                 newScore := score - 1;
    --             ELSE
    --                 newScore := score;
    --             END IF;
    --         END IF;
    --     END IF;
    --     RETURN newScore;
    -- END updateScore;

BEGIN
    inst_CDiv : CDiv PORT MAP(Cin => clk, Cout => pulse);

    -- PROCESS
    -- BEGIN
    --     IF (start = '0') THEN
    --         WAIT UNTIL btn = '1';
    --         start <= '1';
    --     END IF;
    -- END PROCESS;

    -- PROCESS
    -- BEGIN
    --     IF (end_game = '1') THEN
    --         WAIT;
    --     END IF;
    -- END PROCESS;

    update : PROCESS (clk, refresh)
    BEGIN
        IF (rising_edge(clk)) THEN
            refresh <= refresh + 1;
        END IF;
    END PROCESS;

    LED_cntl <= refresh(19 DOWNTO 18);

    feedback <= (out_reg(4) XOR out_reg(1));
    PROCESS (pulse, rst)
    BEGIN
        IF (rst = '1') THEN
            out_reg <= "00010";
        ELSIF (rising_edge(pulse)) THEN
            out_reg <= out_reg(3 DOWNTO 0) & feedback;
        END IF;
    END PROCESS;

    display : PROCESS (LED_out)
    BEGIN
        CASE LED_out IS
            WHEN "0000" => CAT <= "0000001"; -- "0"     
            WHEN "0001" => CAT <= "1001111"; -- "1" 
            WHEN "0010" => CAT <= "0010010"; -- "2" 
            WHEN "0011" => CAT <= "0000110"; -- "3" 
            WHEN "0100" => CAT <= "1001100"; -- "4" 
            WHEN "0101" => CAT <= "0100100"; -- "5" 
            WHEN "0110" => CAT <= "0100000"; -- "6" 
            WHEN "0111" => CAT <= "0001111"; -- "7" 
            WHEN "1000" => CAT <= "0000000"; -- "8"     
            WHEN "1001" => CAT <= "0000100"; -- "9" 
            WHEN "1010" => CAT <= "0000010"; -- a
            WHEN "1011" => CAT <= "1100000"; -- b
            WHEN "1100" => CAT <= "0110001"; -- C
            WHEN "1101" => CAT <= "1000010"; -- d
            WHEN "1110" => CAT <= "0110000"; -- E
            WHEN "1111" => CAT <= "0111000"; -- F       
        END CASE;
    END PROCESS;
    score_display : PROCESS (LED_cntl, score)
    BEGIN
        CASE LED_cntl IS
            WHEN "00" => AN <= "1110";
                LED_out <= score(3 DOWNTO 0);
            WHEN "01" => AN <= "1101";
                LED_out <= score(7 DOWNTO 4);
            WHEN OTHERS => AN <= "1111";
                LED_out <= X"0";
        END CASE;
    END PROCESS;

    led_update : PROCESS (pulse, out_reg)
    BEGIN
        IF (rising_edge(pulse)) THEN
            --go from binary 15 to binary 0 and shift leds right one bit
            CASE out_reg IS
                WHEN "01111" => leds <= X"8000";
                WHEN "01110" => leds <= X"4000";
                WHEN "01101" => leds <= X"2000";
                WHEN "01100" => leds <= X"1000";
                WHEN "01011" => leds <= X"0800";
                WHEN "01010" => leds <= X"0400";
                WHEN "01001" => leds <= X"0200";
                WHEN "01000" => leds <= X"0100";
                WHEN "00111" => leds <= X"0080";
                WHEN "00110" => leds <= X"0040";
                WHEN "00101" => leds <= X"0020";
                WHEN "00100" => leds <= X"0010";
                WHEN "00011" => leds <= X"0008";
                WHEN "00010" => leds <= X"0004";
                WHEN "00001" => leds <= X"0002";
                WHEN "10000" => leds <= X"0001";
                WHEN "11111" => leds <= X"8000";
                WHEN "11110" => leds <= X"4000";
                WHEN "11101" => leds <= X"2000";
                WHEN "11100" => leds <= X"1000";
                WHEN "11011" => leds <= X"0800";
                WHEN "11010" => leds <= X"0400";
                WHEN "11001" => leds <= X"0200";
                WHEN "11000" => leds <= X"0100";
                WHEN "10111" => leds <= X"0080";
                WHEN "10110" => leds <= X"0040";
                WHEN "10101" => leds <= X"0020";
                WHEN "10100" => leds <= X"0010";
                WHEN "10011" => leds <= X"0008";
                WHEN "10010" => leds <= X"0004";
                WHEN "10001" => leds <= X"0002";
                WHEN OTHERS => NULL;

            END CASE;

        END IF;
    END PROCESS;

    sw_old <= sw WHEN rising_edge(clk);
    PROCESS (sw, sw_old, clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            --     score <= updateScore(sw(15), sw_old(15), score, leds, X"8000");
            --     score <= updateScore(sw(14), sw_old(14), score, leds, X"4000");
            --     score <= updateScore(sw(13), sw_old(13), score, leds, X"2000");
            --     score <= updateScore(sw(12), sw_old(12), score, leds, X"1000");
            --     score <= updateScore(sw(11), sw_old(11), score, leds, X"0800");
            --     score <= updateScore(sw(10), sw_old(10), score, leds, X"0400");
            --     score <= updateScore(sw(9), sw_old(9), score, leds, X"0200");
            --     score <= updateScore(sw(8), sw_old(8), score, leds, X"0100");
            --     score <= updateScore(sw(7), sw_old(7), score, leds, X"0080");
            --     score <= updateScore(sw(6), sw_old(6), score, leds, X"0040");
            --     score <= updateScore(sw(5), sw_old(5), score, leds, X"0020");
            --     score <= updateScore(sw(4), sw_old(4), score, leds, X"0010");
            --     score <= updateScore(sw(3), sw_old(3), score, leds, X"0008");
            --     score <= updateScore(sw(2), sw_old(2), score, leds, X"0004");
            --     score <= updateScore(sw(1), sw_old(1), score, leds, X"0002");
            --     score <= updateScore(sw(0), sw_old(0), score, leds, X"0001");
            -- END IF;

            IF (sw_old(15) = '0' AND sw(15) = '1') THEN
                IF (leds = X"8000") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;
            ELSIF (sw_old(15) = '1' AND sw(15) = '0') THEN
                IF (leds = X"8000") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;
            END IF;

            IF (sw_old(14) = '0' AND sw(14) = '1') THEN
                IF (leds = X"4000") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;
            ELSIF (sw_old(14) = '1' AND sw(14) = '0') THEN
                IF (leds = X"4000") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;
            END IF;
            IF (sw_old(13) = '0' AND sw(13) = '1') THEN
                IF (leds = X"2000") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;
            ELSIF (sw_old(13) = '1' AND sw(13) = '0') THEN
                IF (leds = X"2000") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;
            END IF;

            IF (sw_old(12) = '0' AND sw(12) = '1') THEN
                IF (leds = X"1000") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;
            ELSIF (sw_old(12) = '1' AND sw(12) = '0') THEN
                IF (leds = X"1000") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;
            END IF;

            IF (sw_old(11) = '0' AND sw(11) = '1') THEN
                IF (leds = X"0800") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;

            ELSIF (sw_old(11) = '1' AND sw(11) = '0') THEN
                IF (leds = X"0800") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;
            END IF;

            IF (sw_old(10) = '0' AND sw(10) = '1') THEN
                IF (leds = X"0400") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;

            ELSIF (sw_old(10) = '1' AND sw(10) = '0') THEN
                IF (leds = X"0400") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;
            END IF;

            IF (sw_old(9) = '0' AND sw(9) = '1') THEN
                IF (leds = X"0200") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;

            ELSIF (sw_old(9) = '1' AND sw(9) = '0') THEN
                IF (leds = X"0200") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;
            END IF;

            IF (sw_old(8) = '0' AND sw(8) = '1') THEN
                IF (leds = X"0100") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;

            ELSIF (sw_old(8) = '1' AND sw(8) = '0') THEN
                IF (leds = X"0100") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;
            END IF;

            IF (sw_old(7) = '0' AND sw(7) = '1') THEN
                IF (leds = X"0080") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;

            ELSIF (sw_old(7) = '1' AND sw(7) = '0') THEN
                IF (leds = X"0080") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;
            END IF;

            IF (sw_old(6) = '0' AND sw(6) = '1') THEN
                IF (leds = X"0040") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;

            ELSIF (sw_old(6) = '1' AND sw(6) = '0') THEN
                IF (leds = X"0040") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;
            END IF;

            IF (sw_old(5) = '0' AND sw(5) = '1') THEN
                IF (leds = X"0020") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;

            ELSIF (sw_old(5) = '1' AND sw(5) = '0') THEN
                IF (leds = X"0020") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;
            END IF;

            IF (sw_old(4) = '0' AND sw(4) = '1') THEN
                IF (leds = X"0010") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;

            ELSIF (sw_old(4) = '1' AND sw(4) = '0') THEN
                IF (leds = X"0010") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;
            END IF;

            IF (sw_old(3) = '0' AND sw(3) = '1') THEN
                IF (leds = X"0008") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;

            ELSIF (sw_old(3) = '1' AND sw(3) = '0') THEN
                IF (leds = X"0008") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;
            END IF;

            IF (sw_old(2) = '0' AND sw(2) = '1') THEN
                IF (leds = X"0004") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;

            ELSIF (sw_old(2) = '1' AND sw(2) = '0') THEN
                IF (leds = X"0004") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;
            END IF;

            IF (sw_old(1) = '0' AND sw(1) = '1') THEN
                IF (leds = X"0002") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;

            ELSIF (sw_old(1) = '1' AND sw(1) = '0') THEN
                IF (leds = X"0002") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;
            END IF;

            IF (sw_old(0) = '0' AND sw(0) = '1') THEN
                IF (leds = X"0001") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;

            ELSIF (sw_old(0) = '1' AND sw(0) = '0') THEN
                IF (leds = X"0001") THEN
                    score <= score + 1;
                ELSE
                    IF (score /= X"00") THEN
                        score <= score - 1;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;
END behavioral;
