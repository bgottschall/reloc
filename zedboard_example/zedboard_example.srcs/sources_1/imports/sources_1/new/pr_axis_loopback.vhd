library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity pr_axis_loopback is
    generic (
		DATAWIDTH	: integer	:= 64
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
end pr_axis_loopback;

architecture rtl of pr_axis_loopback is

    component axis_buffer is
        generic (
           DATAWIDTH    : integer    := DATAWIDTH;
           BUFFER_SIZE  : integer    := 1
        );
        port (
           s_axis_data_tdata : in std_logic_vector(DATAWIDTH - 1 downto 0);
           s_axis_data_tkeep : in std_logic_vector(DATAWIDTH/8 - 1 downto 0);
           s_axis_data_tready : out std_logic;
           s_axis_data_tlast : in std_logic;
           s_axis_data_tvalid : in std_logic;
           
           m_axis_data_tdata : out std_logic_vector(DATAWIDTH - 1 downto 0);
           m_axis_data_tkeep : out std_logic_vector(DATAWIDTH/8 - 1 downto 0);
           m_axis_data_tready : in std_logic;
           m_axis_data_tlast : out std_logic;
           m_axis_data_tvalid : out std_logic;
           
           -- Global Clock Signal
           clk    : in std_logic
        );
    end component;
begin

    loopback: component axis_buffer
        port map (
            s_axis_data_tdata => s_axis_data_tdata,
            s_axis_data_tkeep => s_axis_data_tkeep,
            s_axis_data_tready => s_axis_data_tready,
            s_axis_data_tlast => s_axis_data_tlast,
            s_axis_data_tvalid => s_axis_data_tvalid,
            
            m_axis_data_tdata => m_axis_data_tdata,
            m_axis_data_tkeep => m_axis_data_tkeep,
            m_axis_data_tready => m_axis_data_tready,
            m_axis_data_tlast => m_axis_data_tlast,
            m_axis_data_tvalid => m_axis_data_tvalid,
            
            clk => clk
        );  
end architecture;