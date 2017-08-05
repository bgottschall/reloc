library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity wrapper is
  generic (
    DATAWIDTH	: integer	:= 32
  );
  port (
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC
  );
end wrapper;

architecture rtl of wrapper is
    component BD_PR_3 is 
    port (
        DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
        DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
        DDR_cas_n : inout STD_LOGIC;
        DDR_ck_n : inout STD_LOGIC;
        DDR_ck_p : inout STD_LOGIC;
        DDR_cke : inout STD_LOGIC;
        DDR_cs_n : inout STD_LOGIC;
        DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
        DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_odt : inout STD_LOGIC;
        DDR_ras_n : inout STD_LOGIC;
        DDR_reset_n : inout STD_LOGIC;
        DDR_we_n : inout STD_LOGIC;
        FIXED_IO_ddr_vrn : inout STD_LOGIC;
        FIXED_IO_ddr_vrp : inout STD_LOGIC;
        FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
        FIXED_IO_ps_clk : inout STD_LOGIC;
        FIXED_IO_ps_porb : inout STD_LOGIC;
        FIXED_IO_ps_srstb : inout STD_LOGIC;
        
        m_axis_data_0_tdata : inout STD_LOGIC_VECTOR ( DATAWIDTH - 1 downto 0 );
        m_axis_data_0_tkeep : inout STD_LOGIC_VECTOR ( DATAWIDTH/8 - 1 downto 0 );
        m_axis_data_0_tlast : inout STD_LOGIC;
        m_axis_data_0_tready : inout STD_LOGIC;
        m_axis_data_0_tvalid : inout STD_LOGIC;
        s_axis_data_0_tdata : inout STD_LOGIC_VECTOR ( DATAWIDTH - 1 downto 0 );
        s_axis_data_0_tkeep : inout STD_LOGIC_VECTOR ( DATAWIDTH/8 - 1 downto 0 );
        s_axis_data_0_tlast : inout STD_LOGIC;
        s_axis_data_0_tready : inout STD_LOGIC;
        s_axis_data_0_tvalid : inout STD_LOGIC;
        
        m_axis_data_1_tdata : inout STD_LOGIC_VECTOR ( DATAWIDTH - 1 downto 0 );
        m_axis_data_1_tkeep : inout STD_LOGIC_VECTOR ( DATAWIDTH/8 - 1 downto 0 );
        m_axis_data_1_tlast : inout STD_LOGIC;
        m_axis_data_1_tready : inout STD_LOGIC;
        m_axis_data_1_tvalid : inout STD_LOGIC;
        s_axis_data_1_tdata : inout STD_LOGIC_VECTOR ( DATAWIDTH - 1 downto 0 );
        s_axis_data_1_tkeep : inout STD_LOGIC_VECTOR ( DATAWIDTH/8 - 1 downto 0 );
        s_axis_data_1_tlast : inout STD_LOGIC;
        s_axis_data_1_tready : inout STD_LOGIC;
        s_axis_data_1_tvalid : inout STD_LOGIC;
        
        m_axis_data_2_tdata : inout STD_LOGIC_VECTOR ( DATAWIDTH - 1 downto 0 );
        m_axis_data_2_tkeep : inout STD_LOGIC_VECTOR ( DATAWIDTH/8 - 1 downto 0 );
        m_axis_data_2_tlast : inout STD_LOGIC;
        m_axis_data_2_tready : inout STD_LOGIC;
        m_axis_data_2_tvalid : inout STD_LOGIC;
        s_axis_data_2_tdata : inout STD_LOGIC_VECTOR ( DATAWIDTH - 1 downto 0 );
        s_axis_data_2_tkeep : inout STD_LOGIC_VECTOR ( DATAWIDTH/8 - 1 downto 0 );
        s_axis_data_2_tlast : inout STD_LOGIC;
        s_axis_data_2_tready : inout STD_LOGIC;
        s_axis_data_2_tvalid : inout STD_LOGIC;
        
        AXIS_CLK : buffer STD_LOGIC
      );
    end component;
    
    component pr_axis_buffer is
        generic (
            DATAWIDTH    : integer    := DATAWIDTH
        );
        port (
           static_m_axis_data_tdata : in std_logic_vector(DATAWIDTH-1 downto 0);
                static_m_axis_data_tkeep : in std_logic_vector(DATAWIDTH/8 - 1 downto 0);
                static_m_axis_data_tready : out std_logic;
                static_m_axis_data_tlast : in std_logic;
                static_m_axis_data_tvalid : in std_logic;
                pr_m_axis_data_tdata : in std_logic_vector(DATAWIDTH-1 downto 0);
                pr_m_axis_data_tkeep : in std_logic_vector(DATAWIDTH/8 - 1 downto 0);
                pr_m_axis_data_tready : out std_logic;
                pr_m_axis_data_tlast : in std_logic;
                pr_m_axis_data_tvalid : in std_logic;
        
        
                static_s_axis_data_tdata : out std_logic_vector(DATAWIDTH-1 downto 0);
                static_s_axis_data_tkeep : out std_logic_vector(DATAWIDTH/8 - 1 downto 0);
                static_s_axis_data_tready : in std_logic;
                static_s_axis_data_tlast : out std_logic;
                static_s_axis_data_tvalid : out std_logic; 
                pr_s_axis_data_tdata : out std_logic_vector(DATAWIDTH-1 downto 0);
                pr_s_axis_data_tkeep : out std_logic_vector(DATAWIDTH/8 - 1 downto 0);
                pr_s_axis_data_tready : in std_logic;
                pr_s_axis_data_tlast : out std_logic;
                pr_s_axis_data_tvalid : out std_logic;
        
                -- Global Clock Signal
                clk    : in std_logic
        );
    end component;
 
 
    component pr_axis is
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

       
    signal static_m_axis_data_0_tdata : STD_LOGIC_VECTOR ( DATAWIDTH - 1 downto 0 );
    signal static_m_axis_data_0_tkeep : STD_LOGIC_VECTOR ( DATAWIDTH/8 - 1 downto 0 );
    signal static_m_axis_data_0_tlast : STD_LOGIC;
    signal static_m_axis_data_0_tready : STD_LOGIC;
    signal static_m_axis_data_0_tvalid : STD_LOGIC;
    signal static_s_axis_data_0_tdata : STD_LOGIC_VECTOR ( DATAWIDTH - 1 downto 0 );
    signal static_s_axis_data_0_tkeep : STD_LOGIC_VECTOR ( DATAWIDTH/8 - 1 downto 0 );
    signal static_s_axis_data_0_tlast : STD_LOGIC;
    signal static_s_axis_data_0_tready : STD_LOGIC;
    signal static_s_axis_data_0_tvalid : STD_LOGIC;
    
    signal pr_m_axis_data_0_tdata : STD_LOGIC_VECTOR ( DATAWIDTH - 1 downto 0 );
    signal pr_m_axis_data_0_tkeep : STD_LOGIC_VECTOR ( DATAWIDTH/8 - 1 downto 0 );
    signal pr_m_axis_data_0_tlast : STD_LOGIC;
    signal pr_m_axis_data_0_tready : STD_LOGIC;
    signal pr_m_axis_data_0_tvalid : STD_LOGIC;
    signal pr_s_axis_data_0_tdata : STD_LOGIC_VECTOR ( DATAWIDTH - 1 downto 0 );
    signal pr_s_axis_data_0_tkeep : STD_LOGIC_VECTOR ( DATAWIDTH/8 - 1 downto 0 );
    signal pr_s_axis_data_0_tlast : STD_LOGIC;
    signal pr_s_axis_data_0_tready : STD_LOGIC;
    signal pr_s_axis_data_0_tvalid : STD_LOGIC;
    
    signal static_m_axis_data_1_tdata : STD_LOGIC_VECTOR ( DATAWIDTH - 1 downto 0 );
    signal static_m_axis_data_1_tkeep : STD_LOGIC_VECTOR ( DATAWIDTH/8 - 1 downto 0 );
    signal static_m_axis_data_1_tlast : STD_LOGIC;
    signal static_m_axis_data_1_tready : STD_LOGIC;
    signal static_m_axis_data_1_tvalid : STD_LOGIC;
    signal static_s_axis_data_1_tdata : STD_LOGIC_VECTOR ( DATAWIDTH - 1 downto 0 );
    signal static_s_axis_data_1_tkeep : STD_LOGIC_VECTOR ( DATAWIDTH/8 - 1 downto 0 );
    signal static_s_axis_data_1_tlast : STD_LOGIC;
    signal static_s_axis_data_1_tready : STD_LOGIC;
    signal static_s_axis_data_1_tvalid : STD_LOGIC;
    
    signal pr_m_axis_data_1_tdata : STD_LOGIC_VECTOR ( DATAWIDTH - 1 downto 0 );
    signal pr_m_axis_data_1_tkeep : STD_LOGIC_VECTOR ( DATAWIDTH/8 - 1 downto 0 );
    signal pr_m_axis_data_1_tlast : STD_LOGIC;
    signal pr_m_axis_data_1_tready : STD_LOGIC;
    signal pr_m_axis_data_1_tvalid : STD_LOGIC;
    signal pr_s_axis_data_1_tdata : STD_LOGIC_VECTOR ( DATAWIDTH - 1 downto 0 );
    signal pr_s_axis_data_1_tkeep : STD_LOGIC_VECTOR ( DATAWIDTH/8 - 1 downto 0 );
    signal pr_s_axis_data_1_tlast : STD_LOGIC;
    signal pr_s_axis_data_1_tready : STD_LOGIC;
    signal pr_s_axis_data_1_tvalid : STD_LOGIC;
    
    signal static_m_axis_data_2_tdata : STD_LOGIC_VECTOR ( DATAWIDTH - 1 downto 0 );
    signal static_m_axis_data_2_tkeep : STD_LOGIC_VECTOR ( DATAWIDTH/8 - 1 downto 0 );
    signal static_m_axis_data_2_tlast : STD_LOGIC;
    signal static_m_axis_data_2_tready : STD_LOGIC;
    signal static_m_axis_data_2_tvalid : STD_LOGIC;
    signal static_s_axis_data_2_tdata : STD_LOGIC_VECTOR ( DATAWIDTH - 1 downto 0 );
    signal static_s_axis_data_2_tkeep : STD_LOGIC_VECTOR ( DATAWIDTH/8 - 1 downto 0 );
    signal static_s_axis_data_2_tlast : STD_LOGIC;
    signal static_s_axis_data_2_tready : STD_LOGIC;
    signal static_s_axis_data_2_tvalid : STD_LOGIC;
    
    signal pr_m_axis_data_2_tdata : STD_LOGIC_VECTOR ( DATAWIDTH - 1 downto 0 );
    signal pr_m_axis_data_2_tkeep : STD_LOGIC_VECTOR ( DATAWIDTH/8 - 1 downto 0 );
    signal pr_m_axis_data_2_tlast : STD_LOGIC;
    signal pr_m_axis_data_2_tready : STD_LOGIC;
    signal pr_m_axis_data_2_tvalid : STD_LOGIC;
    signal pr_s_axis_data_2_tdata : STD_LOGIC_VECTOR ( DATAWIDTH - 1 downto 0 );
    signal pr_s_axis_data_2_tkeep : STD_LOGIC_VECTOR ( DATAWIDTH/8 - 1 downto 0 );
    signal pr_s_axis_data_2_tlast : STD_LOGIC;
    signal pr_s_axis_data_2_tready : STD_LOGIC;
    signal pr_s_axis_data_2_tvalid : STD_LOGIC;
  
    signal clk : STD_LOGIC;
begin
       

    block_design: component BD_PR_3
    port map(
        DDR_addr(14 downto 0) => DDR_addr(14 downto 0),
        DDR_ba(2 downto 0) => DDR_ba(2 downto 0),
        DDR_cas_n => DDR_cas_n,
        DDR_ck_n => DDR_ck_n,
        DDR_ck_p => DDR_ck_p,
        DDR_cke => DDR_cke,
        DDR_cs_n => DDR_cs_n,
        DDR_dm(3 downto 0) => DDR_dm(3 downto 0),
        DDR_dq(31 downto 0) => DDR_dq(31 downto 0),
        DDR_dqs_n(3 downto 0) => DDR_dqs_n(3 downto 0),
        DDR_dqs_p(3 downto 0) => DDR_dqs_p(3 downto 0),
        DDR_odt => DDR_odt,
        DDR_ras_n => DDR_ras_n,
        DDR_reset_n => DDR_reset_n,
        DDR_we_n => DDR_we_n,
        FIXED_IO_ddr_vrn => FIXED_IO_ddr_vrn,
        FIXED_IO_ddr_vrp => FIXED_IO_ddr_vrp,
        FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
        FIXED_IO_ps_clk => FIXED_IO_ps_clk,
        FIXED_IO_ps_porb => FIXED_IO_ps_porb,
        FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
        
        m_axis_data_0_tdata => static_m_axis_data_0_tdata,
        m_axis_data_0_tkeep => static_m_axis_data_0_tkeep,
        m_axis_data_0_tlast => static_m_axis_data_0_tlast,
        m_axis_data_0_tready => static_m_axis_data_0_tready,
        m_axis_data_0_tvalid => static_m_axis_data_0_tvalid,
        s_axis_data_0_tdata => static_s_axis_data_0_tdata,
        
        s_axis_data_0_tkeep => static_s_axis_data_0_tkeep,
        s_axis_data_0_tlast => static_s_axis_data_0_tlast,
        s_axis_data_0_tready => static_s_axis_data_0_tready,
        s_axis_data_0_tvalid => static_s_axis_data_0_tvalid,
        
        m_axis_data_1_tdata => static_m_axis_data_1_tdata,
        m_axis_data_1_tkeep => static_m_axis_data_1_tkeep,
        m_axis_data_1_tlast => static_m_axis_data_1_tlast,
        m_axis_data_1_tready => static_m_axis_data_1_tready,
        m_axis_data_1_tvalid => static_m_axis_data_1_tvalid,
        s_axis_data_1_tdata => static_s_axis_data_1_tdata,
        
        s_axis_data_1_tkeep => static_s_axis_data_1_tkeep,
        s_axis_data_1_tlast => static_s_axis_data_1_tlast,
        s_axis_data_1_tready => static_s_axis_data_1_tready,
        s_axis_data_1_tvalid => static_s_axis_data_1_tvalid,
        
        m_axis_data_2_tdata => static_m_axis_data_2_tdata,
        m_axis_data_2_tkeep => static_m_axis_data_2_tkeep,
        m_axis_data_2_tlast => static_m_axis_data_2_tlast,
        m_axis_data_2_tready => static_m_axis_data_2_tready,
        m_axis_data_2_tvalid => static_m_axis_data_2_tvalid,
        s_axis_data_2_tdata => static_s_axis_data_2_tdata,
        
        s_axis_data_2_tkeep => static_s_axis_data_2_tkeep,
        s_axis_data_2_tlast => static_s_axis_data_2_tlast,
        s_axis_data_2_tready => static_s_axis_data_2_tready,
        s_axis_data_2_tvalid => static_s_axis_data_2_tvalid,

        AXIS_CLK => clk
    );
    
    
    pr_0_buffer: component pr_axis_buffer 
    port map (
        static_m_axis_data_tdata => static_m_axis_data_0_tdata,
        static_m_axis_data_tkeep => static_m_axis_data_0_tkeep,
        static_m_axis_data_tready => static_m_axis_data_0_tready,
        static_m_axis_data_tlast => static_m_axis_data_0_tlast,
        static_m_axis_data_tvalid => static_m_axis_data_0_tvalid,
        
        pr_m_axis_data_tdata => pr_m_axis_data_0_tdata,
        pr_m_axis_data_tkeep => pr_m_axis_data_0_tkeep,
        pr_m_axis_data_tready => pr_m_axis_data_0_tready,
        pr_m_axis_data_tlast => pr_m_axis_data_0_tlast,
        pr_m_axis_data_tvalid => pr_m_axis_data_0_tvalid,


        static_s_axis_data_tdata => static_s_axis_data_0_tdata,
        static_s_axis_data_tkeep => static_s_axis_data_0_tkeep,
        static_s_axis_data_tready => static_s_axis_data_0_tready,
        static_s_axis_data_tlast => static_s_axis_data_0_tlast,
        static_s_axis_data_tvalid  => static_s_axis_data_0_tvalid,
        pr_s_axis_data_tdata => pr_s_axis_data_0_tdata,
        pr_s_axis_data_tkeep => pr_s_axis_data_0_tkeep,
        pr_s_axis_data_tready => pr_s_axis_data_0_tready,
        pr_s_axis_data_tlast => pr_s_axis_data_0_tlast,
        pr_s_axis_data_tvalid => pr_s_axis_data_0_tvalid,
        
        clk => clk
   );
   
    pr_1_buffer: component pr_axis_buffer 
    port map (
       static_m_axis_data_tdata => static_m_axis_data_1_tdata,
       static_m_axis_data_tkeep => static_m_axis_data_1_tkeep,
       static_m_axis_data_tready => static_m_axis_data_1_tready,
       static_m_axis_data_tlast => static_m_axis_data_1_tlast,
       static_m_axis_data_tvalid => static_m_axis_data_1_tvalid,
       
       pr_m_axis_data_tdata => pr_m_axis_data_1_tdata,
       pr_m_axis_data_tkeep => pr_m_axis_data_1_tkeep,
       pr_m_axis_data_tready => pr_m_axis_data_1_tready,
       pr_m_axis_data_tlast => pr_m_axis_data_1_tlast,
       pr_m_axis_data_tvalid => pr_m_axis_data_1_tvalid,
    
    
       static_s_axis_data_tdata => static_s_axis_data_1_tdata,
       static_s_axis_data_tkeep => static_s_axis_data_1_tkeep,
       static_s_axis_data_tready => static_s_axis_data_1_tready,
       static_s_axis_data_tlast => static_s_axis_data_1_tlast,
       static_s_axis_data_tvalid  => static_s_axis_data_1_tvalid,
       pr_s_axis_data_tdata => pr_s_axis_data_1_tdata,
       pr_s_axis_data_tkeep => pr_s_axis_data_1_tkeep,
       pr_s_axis_data_tready => pr_s_axis_data_1_tready,
       pr_s_axis_data_tlast => pr_s_axis_data_1_tlast,
       pr_s_axis_data_tvalid => pr_s_axis_data_1_tvalid,
       
       clk => clk
    );
    
    
    pr_2_buffer: component pr_axis_buffer 
    port map (
        static_m_axis_data_tdata => static_m_axis_data_2_tdata,
        static_m_axis_data_tkeep => static_m_axis_data_2_tkeep,
        static_m_axis_data_tready => static_m_axis_data_2_tready,
        static_m_axis_data_tlast => static_m_axis_data_2_tlast,
        static_m_axis_data_tvalid => static_m_axis_data_2_tvalid,
        
        pr_m_axis_data_tdata => pr_m_axis_data_2_tdata,
        pr_m_axis_data_tkeep => pr_m_axis_data_2_tkeep,
        pr_m_axis_data_tready => pr_m_axis_data_2_tready,
        pr_m_axis_data_tlast => pr_m_axis_data_2_tlast,
        pr_m_axis_data_tvalid => pr_m_axis_data_2_tvalid,


        static_s_axis_data_tdata => static_s_axis_data_2_tdata,
        static_s_axis_data_tkeep => static_s_axis_data_2_tkeep,
        static_s_axis_data_tready => static_s_axis_data_2_tready,
        static_s_axis_data_tlast => static_s_axis_data_2_tlast,
        static_s_axis_data_tvalid  => static_s_axis_data_2_tvalid,
        pr_s_axis_data_tdata => pr_s_axis_data_2_tdata,
        pr_s_axis_data_tkeep => pr_s_axis_data_2_tkeep,
        pr_s_axis_data_tready => pr_s_axis_data_2_tready,
        pr_s_axis_data_tlast => pr_s_axis_data_2_tlast,
        pr_s_axis_data_tvalid => pr_s_axis_data_2_tvalid,
        
        clk => clk
    );
   
     
    pr_0 : component pr_axis
    port map (
        s_axis_data_tdata => pr_s_axis_data_0_tdata,
        s_axis_data_tkeep => pr_s_axis_data_0_tkeep,
        s_axis_data_tready => pr_s_axis_data_0_tready,
        s_axis_data_tlast => pr_s_axis_data_0_tlast,
        s_axis_data_tvalid => pr_s_axis_data_0_tvalid,
        
        m_axis_data_tdata => pr_m_axis_data_0_tdata,
        m_axis_data_tkeep => pr_m_axis_data_0_tkeep,
        m_axis_data_tready => pr_m_axis_data_0_tready,
        m_axis_data_tlast => pr_m_axis_data_0_tlast,
        m_axis_data_tvalid => pr_m_axis_data_0_tvalid,
        
        clk => clk
    );
        
    pr_1 : component pr_axis
    port map (
        s_axis_data_tdata => pr_s_axis_data_1_tdata,
        s_axis_data_tkeep => pr_s_axis_data_1_tkeep,
        s_axis_data_tready => pr_s_axis_data_1_tready,
        s_axis_data_tlast => pr_s_axis_data_1_tlast,
        s_axis_data_tvalid => pr_s_axis_data_1_tvalid,
        
        m_axis_data_tdata => pr_m_axis_data_1_tdata,
        m_axis_data_tkeep => pr_m_axis_data_1_tkeep,
        m_axis_data_tready => pr_m_axis_data_1_tready,
        m_axis_data_tlast => pr_m_axis_data_1_tlast,
        m_axis_data_tvalid => pr_m_axis_data_1_tvalid,
        
        clk => clk
    );
            
    pr_2 : component pr_axis
    port map (
        s_axis_data_tdata => pr_s_axis_data_2_tdata,
        s_axis_data_tkeep => pr_s_axis_data_2_tkeep,
        s_axis_data_tready => pr_s_axis_data_2_tready,
        s_axis_data_tlast => pr_s_axis_data_2_tlast,
        s_axis_data_tvalid => pr_s_axis_data_2_tvalid,
        
        m_axis_data_tdata => pr_m_axis_data_2_tdata,
        m_axis_data_tkeep => pr_m_axis_data_2_tkeep,
        m_axis_data_tready => pr_m_axis_data_2_tready,
        m_axis_data_tlast => pr_m_axis_data_2_tlast,
        m_axis_data_tvalid => pr_m_axis_data_2_tvalid,
        
        clk => clk
    );

end architecture rtl;