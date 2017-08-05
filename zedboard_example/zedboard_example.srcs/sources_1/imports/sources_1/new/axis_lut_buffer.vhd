library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity axis_lut_buffer is
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
end axis_lut_buffer;

architecture rtl of axis_lut_buffer is
    component LUT1
        generic (
            INIT: bit_vector(1 downto 0) := "10"
        );
        port (
            O : out std_logic;
            I0 : in std_logic
        );
    end component;
begin

    LUTBUF_TDATA: 
        for I in 0 to DATAWIDTH-1 generate
            LUTX: 
                LUT1 
                generic map ( INIT => "10" )
                port map (
                    O => m_axis_data_tdata(I), 
                    I0 => s_axis_data_tdata(I)
                );
        end generate LUTBUF_TDATA;
        
    LUTBUF_TKEEP: 
        for I in 0 to (DATAWIDTH/8)-1 generate
            LUTX: 
                LUT1 
                generic map ( INIT => "10" )
                port map (
                    O => m_axis_data_tkeep(I), 
                    I0 => s_axis_data_tkeep(I)
                );
        end generate LUTBUF_TKEEP;
        
    LUTBUF_TVALID: 
        LUT1 
            generic map ( INIT => "10" )
            port map (
                O => m_axis_data_tvalid,
                I0 => s_axis_data_tvalid
            );        
        
    LUTBUF_TLAST: 
        LUT1 
        generic map ( INIT => "10" )
        port map (
            O => m_axis_data_tlast,
            I0 => s_axis_data_tlast
        );
        
    LUTBUF_TREADY: 
        LUT1 
        generic map ( INIT => "10" )
        port map (
            O => s_axis_data_tready,
            I0 => m_axis_data_tready
        );

end rtl;