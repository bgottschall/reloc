library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity pr_axis is
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
end pr_axis;

architecture rtl of pr_axis is

    component axis_lut_buffer is
        generic (
           DATAWIDTH    : integer    := DATAWIDTH
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
    
    component pr_axis_loopback is
        generic (
           DATAWIDTH    : integer    := DATAWIDTH
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
           clk    : in std_logic
        );
    end component;
    
   signal pr_m_axis_data_tdata : STD_LOGIC_VECTOR ( DATAWIDTH - 1 downto 0 );
   signal pr_m_axis_data_tkeep : STD_LOGIC_VECTOR ( DATAWIDTH/8 - 1 downto 0 );
   signal pr_m_axis_data_tlast : STD_LOGIC;
   signal pr_m_axis_data_tready : STD_LOGIC;
   signal pr_m_axis_data_tvalid : STD_LOGIC;
   signal pr_s_axis_data_tdata : STD_LOGIC_VECTOR ( DATAWIDTH - 1 downto 0 );
   signal pr_s_axis_data_tkeep : STD_LOGIC_VECTOR ( DATAWIDTH/8 - 1 downto 0 );
   signal pr_s_axis_data_tlast : STD_LOGIC;
   signal pr_s_axis_data_tready : STD_LOGIC;
   signal pr_s_axis_data_tvalid : STD_LOGIC;
   
begin

    input_lut_buffer: component axis_lut_buffer
        port map (
            s_axis_data_tdata => s_axis_data_tdata,
            s_axis_data_tkeep => s_axis_data_tkeep,
            s_axis_data_tready => s_axis_data_tready,
            s_axis_data_tlast => s_axis_data_tlast,
            s_axis_data_tvalid => s_axis_data_tvalid,
            
            m_axis_data_tdata => pr_s_axis_data_tdata,
            m_axis_data_tkeep => pr_s_axis_data_tkeep,
            m_axis_data_tready => pr_s_axis_data_tready,
            m_axis_data_tlast => pr_s_axis_data_tlast,
            m_axis_data_tvalid => pr_s_axis_data_tvalid,
            
            clk => clk
        );
        
    output_lut_buffer: component axis_lut_buffer
        port map (
            s_axis_data_tdata => pr_m_axis_data_tdata,
            s_axis_data_tkeep => pr_m_axis_data_tkeep,
            s_axis_data_tready => pr_m_axis_data_tready,
            s_axis_data_tlast => pr_m_axis_data_tlast,
            s_axis_data_tvalid => pr_m_axis_data_tvalid,
            
            m_axis_data_tdata => m_axis_data_tdata,
            m_axis_data_tkeep => m_axis_data_tkeep,
            m_axis_data_tready => m_axis_data_tready,
            m_axis_data_tlast => m_axis_data_tlast,
            m_axis_data_tvalid => m_axis_data_tvalid,
            
            clk => clk
        );

    pr: component pr_axis_loopback
       port map (
           s_axis_data_tdata => pr_s_axis_data_tdata,
           s_axis_data_tkeep => pr_s_axis_data_tkeep,
           s_axis_data_tready => pr_s_axis_data_tready,
           s_axis_data_tlast => pr_s_axis_data_tlast,
           s_axis_data_tvalid => pr_s_axis_data_tvalid,
    
           m_axis_data_tdata => pr_m_axis_data_tdata,
           m_axis_data_tkeep => pr_m_axis_data_tkeep,
           m_axis_data_tready => pr_m_axis_data_tready,
           m_axis_data_tlast => pr_m_axis_data_tlast,
           m_axis_data_tvalid => pr_m_axis_data_tvalid,
    
           clk => clk
    );
   
end architecture;