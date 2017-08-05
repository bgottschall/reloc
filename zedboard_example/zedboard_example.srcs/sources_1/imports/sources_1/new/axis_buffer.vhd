library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity axis_buffer is
    generic (
		DATAWIDTH	: integer	:= 64;
		BUFFER_SIZE : positive  := 1
	);
	port (
		s_axis_data_tdata : in std_logic_vector(DATAWIDTH-1 downto 0);
        s_axis_data_tkeep : in std_logic_vector(DATAWIDTH/8 - 1 downto 0);
		s_axis_data_tready : out std_logic;
		s_axis_data_tlast : in std_logic;
		s_axis_data_tvalid : in std_logic;

        m_axis_data_tdata : out std_logic_vector(DATAWIDTH-1 downto 0);
        m_axis_data_tkeep : out std_logic_vector(DATAWIDTH/8 - 1 downto 0);
        m_axis_data_tready : in std_logic;
        m_axis_data_tlast : out std_logic;
        m_axis_data_tvalid : out std_logic;

		-- Global Clock Signal
		clk	: in std_logic
    );
end axis_buffer;

architecture rtl of axis_buffer is
    signal reg_tdata : STD_LOGIC_VECTOR (((BUFFER_SIZE + 1) * DATAWIDTH) - 1 downto 0) := ( others => '0' );
    signal reg_tkeep : STD_LOGIC_VECTOR (((BUFFER_SIZE + 1) * DATAWIDTH/8) - 1 downto 0) := ( others => '1' );
    signal reg_tlast : STD_LOGIC_VECTOR (BUFFER_SIZE downto 0) := ( others => '0' );
    signal reg_tvalid : STD_LOGIC_VECTOR (BUFFER_SIZE downto 0) := ( others => '0' );
    signal tready : STD_LOGIC := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            
            if (tready = '1') then
                reg_tdata(((BUFFER_SIZE + 1) * DATAWIDTH) - 1 downto BUFFER_SIZE * DATAWIDTH) <= s_axis_data_tdata;
                reg_tkeep(((BUFFER_SIZE + 1) * DATAWIDTH/8) - 1 downto BUFFER_SIZE * DATAWIDTH/8) <= s_axis_data_tkeep;
                reg_tlast(BUFFER_SIZE) <= s_axis_data_tlast;
                reg_tvalid(BUFFER_SIZE) <= s_axis_data_tvalid;                
            end if;
            
            if (m_axis_data_tready = '1') then
                tready <= '1';
                reg_tdata((BUFFER_SIZE * DATAWIDTH) - 1 downto 0) <= reg_tdata(((BUFFER_SIZE + 1) * DATAWIDTH) - 1 downto DATAWIDTH);
                reg_tkeep((BUFFER_SIZE * DATAWIDTH/8) - 1 downto 0) <= reg_tkeep(((BUFFER_SIZE + 1) * DATAWIDTH/8) - 1 downto DATAWIDTH/8);
                reg_tlast(BUFFER_SIZE - 1 downto 0) <= reg_tlast(BUFFER_SIZE downto 1);
                reg_tvalid(BUFFER_SIZE - 1 downto 0) <= reg_tvalid(BUFFER_SIZE downto 1);
            else 
                tready <= '0'; 
            end if;
            
        end if;
    end process;
    
    m_axis_data_tdata <= reg_tdata(DATAWIDTH - 1 downto 0);
    m_axis_data_tkeep <= reg_tkeep(DATAWIDTH/8 - 1 downto 0);
    m_axis_data_tlast <= reg_tlast(0);
    m_axis_data_tvalid <= reg_tvalid(0);
    s_axis_data_tready <= tready;
end architecture;