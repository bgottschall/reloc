--Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2016.4 (lin64) Build 1733598 Wed Dec 14 22:35:42 MST 2016
--Date        : Sat Aug  5 18:37:52 2017
--Host        : knuff running 64-bit Debian GNU/Linux 9.0 (stretch)
--Command     : generate_target BD_PR_3_wrapper.bd
--Design      : BD_PR_3_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity BD_PR_3_wrapper is
  port (
    AXIS_CLK : out STD_LOGIC;
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
    m_axis_data_0_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_data_0_tkeep : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axis_data_0_tlast : out STD_LOGIC;
    m_axis_data_0_tready : in STD_LOGIC;
    m_axis_data_0_tvalid : out STD_LOGIC;
    m_axis_data_1_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_data_1_tkeep : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axis_data_1_tlast : out STD_LOGIC;
    m_axis_data_1_tready : in STD_LOGIC;
    m_axis_data_1_tvalid : out STD_LOGIC;
    m_axis_data_2_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_data_2_tkeep : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axis_data_2_tlast : out STD_LOGIC;
    m_axis_data_2_tready : in STD_LOGIC;
    m_axis_data_2_tvalid : out STD_LOGIC;
    s_axis_data_0_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_data_0_tkeep : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axis_data_0_tlast : in STD_LOGIC;
    s_axis_data_0_tready : out STD_LOGIC;
    s_axis_data_0_tvalid : in STD_LOGIC;
    s_axis_data_1_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_data_1_tkeep : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axis_data_1_tlast : in STD_LOGIC;
    s_axis_data_1_tready : out STD_LOGIC;
    s_axis_data_1_tvalid : in STD_LOGIC;
    s_axis_data_2_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_data_2_tkeep : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axis_data_2_tlast : in STD_LOGIC;
    s_axis_data_2_tready : out STD_LOGIC;
    s_axis_data_2_tvalid : in STD_LOGIC
  );
end BD_PR_3_wrapper;

architecture STRUCTURE of BD_PR_3_wrapper is
  component BD_PR_3 is
  port (
    m_axis_data_0_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_data_0_tkeep : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axis_data_0_tlast : out STD_LOGIC;
    m_axis_data_0_tready : in STD_LOGIC;
    m_axis_data_0_tvalid : out STD_LOGIC;
    m_axis_data_1_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_data_1_tkeep : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axis_data_1_tlast : out STD_LOGIC;
    m_axis_data_1_tready : in STD_LOGIC;
    m_axis_data_1_tvalid : out STD_LOGIC;
    m_axis_data_2_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_data_2_tkeep : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axis_data_2_tlast : out STD_LOGIC;
    m_axis_data_2_tready : in STD_LOGIC;
    m_axis_data_2_tvalid : out STD_LOGIC;
    s_axis_data_0_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_data_0_tkeep : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axis_data_0_tlast : in STD_LOGIC;
    s_axis_data_0_tready : out STD_LOGIC;
    s_axis_data_0_tvalid : in STD_LOGIC;
    s_axis_data_1_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_data_1_tkeep : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axis_data_1_tlast : in STD_LOGIC;
    s_axis_data_1_tready : out STD_LOGIC;
    s_axis_data_1_tvalid : in STD_LOGIC;
    s_axis_data_2_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_data_2_tkeep : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axis_data_2_tlast : in STD_LOGIC;
    s_axis_data_2_tready : out STD_LOGIC;
    s_axis_data_2_tvalid : in STD_LOGIC;
    AXIS_CLK : out STD_LOGIC;
    DDR_cas_n : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC
  );
  end component BD_PR_3;
begin
BD_PR_3_i: component BD_PR_3
     port map (
      AXIS_CLK => AXIS_CLK,
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
      m_axis_data_0_tdata(31 downto 0) => m_axis_data_0_tdata(31 downto 0),
      m_axis_data_0_tkeep(3 downto 0) => m_axis_data_0_tkeep(3 downto 0),
      m_axis_data_0_tlast => m_axis_data_0_tlast,
      m_axis_data_0_tready => m_axis_data_0_tready,
      m_axis_data_0_tvalid => m_axis_data_0_tvalid,
      m_axis_data_1_tdata(31 downto 0) => m_axis_data_1_tdata(31 downto 0),
      m_axis_data_1_tkeep(3 downto 0) => m_axis_data_1_tkeep(3 downto 0),
      m_axis_data_1_tlast => m_axis_data_1_tlast,
      m_axis_data_1_tready => m_axis_data_1_tready,
      m_axis_data_1_tvalid => m_axis_data_1_tvalid,
      m_axis_data_2_tdata(31 downto 0) => m_axis_data_2_tdata(31 downto 0),
      m_axis_data_2_tkeep(3 downto 0) => m_axis_data_2_tkeep(3 downto 0),
      m_axis_data_2_tlast => m_axis_data_2_tlast,
      m_axis_data_2_tready => m_axis_data_2_tready,
      m_axis_data_2_tvalid => m_axis_data_2_tvalid,
      s_axis_data_0_tdata(31 downto 0) => s_axis_data_0_tdata(31 downto 0),
      s_axis_data_0_tkeep(3 downto 0) => s_axis_data_0_tkeep(3 downto 0),
      s_axis_data_0_tlast => s_axis_data_0_tlast,
      s_axis_data_0_tready => s_axis_data_0_tready,
      s_axis_data_0_tvalid => s_axis_data_0_tvalid,
      s_axis_data_1_tdata(31 downto 0) => s_axis_data_1_tdata(31 downto 0),
      s_axis_data_1_tkeep(3 downto 0) => s_axis_data_1_tkeep(3 downto 0),
      s_axis_data_1_tlast => s_axis_data_1_tlast,
      s_axis_data_1_tready => s_axis_data_1_tready,
      s_axis_data_1_tvalid => s_axis_data_1_tvalid,
      s_axis_data_2_tdata(31 downto 0) => s_axis_data_2_tdata(31 downto 0),
      s_axis_data_2_tkeep(3 downto 0) => s_axis_data_2_tkeep(3 downto 0),
      s_axis_data_2_tlast => s_axis_data_2_tlast,
      s_axis_data_2_tready => s_axis_data_2_tready,
      s_axis_data_2_tvalid => s_axis_data_2_tvalid
    );
end STRUCTURE;
