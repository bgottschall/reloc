create_pblock static
add_cells_to_pblock [get_pblocks static] [get_cells -quiet [list block_design]]
resize_pblock [get_pblocks static] -add {SLICE_X0Y0:SLICE_X81Y149}
resize_pblock [get_pblocks static] -add {BSCAN_X0Y0:BSCAN_X0Y3}
resize_pblock [get_pblocks static] -add {BUFGCTRL_X0Y0:BUFGCTRL_X0Y31}
resize_pblock [get_pblocks static] -add {BUFHCE_X0Y0:BUFHCE_X1Y35}
resize_pblock [get_pblocks static] -add {BUFMRCE_X0Y0:BUFMRCE_X0Y1}
resize_pblock [get_pblocks static] -add {CAPTURE_X0Y0:CAPTURE_X0Y0}
resize_pblock [get_pblocks static] -add {CFG_IO_ACCESS_X0Y0:CFG_IO_ACCESS_X0Y0}
resize_pblock [get_pblocks static] -add {DCIRESET_X0Y0:DCIRESET_X0Y0}
resize_pblock [get_pblocks static] -add {DNA_PORT_X0Y0:DNA_PORT_X0Y0}
resize_pblock [get_pblocks static] -add {DSP48_X0Y0:DSP48_X2Y59}
resize_pblock [get_pblocks static] -add {EFUSE_USR_X0Y0:EFUSE_USR_X0Y0}
resize_pblock [get_pblocks static] -add {FRAME_ECC_X0Y0:FRAME_ECC_X0Y0}
resize_pblock [get_pblocks static] -add {ICAP_X0Y0:ICAP_X0Y1}
resize_pblock [get_pblocks static] -add {IN_FIFO_X0Y0:IN_FIFO_X0Y3}
resize_pblock [get_pblocks static] -add {IOPAD_X1Y1:IOPAD_X1Y134}
resize_pblock [get_pblocks static] -add {IPAD_X0Y0:IPAD_X0Y1}
resize_pblock [get_pblocks static] -add {MMCME2_ADV_X0Y0:MMCME2_ADV_X0Y0}
resize_pblock [get_pblocks static] -add {OUT_FIFO_X0Y0:OUT_FIFO_X0Y3}
resize_pblock [get_pblocks static] -add {PHASER_IN_PHY_X0Y0:PHASER_IN_PHY_X0Y3}
resize_pblock [get_pblocks static] -add {PHASER_OUT_PHY_X0Y0:PHASER_OUT_PHY_X0Y3}
resize_pblock [get_pblocks static] -add {PHASER_REF_X0Y0:PHASER_REF_X0Y0}
resize_pblock [get_pblocks static] -add {PHY_CONTROL_X0Y0:PHY_CONTROL_X0Y0}
resize_pblock [get_pblocks static] -add {PLLE2_ADV_X0Y0:PLLE2_ADV_X0Y0}
resize_pblock [get_pblocks static] -add {PMV_X0Y0:PMV_X0Y2}
resize_pblock [get_pblocks static] -add {PMVBRAM_X0Y0:PMVBRAM_X3Y2}
resize_pblock [get_pblocks static] -add {PMVIOB_X0Y0:PMVIOB_X1Y1}
resize_pblock [get_pblocks static] -add {PS7_X0Y0:PS7_X0Y0}
resize_pblock [get_pblocks static] -add {RAMB18_X0Y0:RAMB18_X3Y59}
resize_pblock [get_pblocks static] -add {RAMB36_X0Y0:RAMB36_X3Y29}
resize_pblock [get_pblocks static] -add {STARTUP_X0Y0:STARTUP_X0Y0}
resize_pblock [get_pblocks static] -add {USR_ACCESS_X0Y0:USR_ACCESS_X0Y0}
resize_pblock [get_pblocks static] -add {XADC_X0Y0:XADC_X0Y0}

create_pblock pr_0_buffer
add_cells_to_pblock [get_pblocks pr_0_buffer] [get_cells -quiet [list pr_0_buffer]]
resize_pblock [get_pblocks pr_0_buffer] -add {SLICE_X84Y100:SLICE_X87Y149}

create_pblock pr_1_buffer
add_cells_to_pblock [get_pblocks pr_1_buffer] [get_cells -quiet [list pr_1_buffer]]
resize_pblock [get_pblocks pr_1_buffer] -add {SLICE_X84Y50:SLICE_X87Y99}

create_pblock pr_2_buffer
add_cells_to_pblock [get_pblocks pr_2_buffer] [get_cells -quiet [list pr_2_buffer]]
resize_pblock [get_pblocks pr_2_buffer] -add {SLICE_X84Y0:SLICE_X87Y49}

set_property HD.ISOLATED true [get_cells pr_0]
set_property HD.ISOLATED true [get_cells pr_1]
set_property HD.ISOLATED true [get_cells pr_2]
set_property HD.ISOLATED true [get_cells pr_0_buffer]
set_property HD.ISOLATED true [get_cells pr_1_buffer]
set_property HD.ISOLATED true [get_cells pr_2_buffer]

set_property HD.ISOLATED true [get_cells block_design]
set_property HD.ISOLATED_EXEMPT true [get_cells -hierarchical -filter {PRIMITIVE_TYPE =~ CLK.gclk.*}]










