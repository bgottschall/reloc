create_pblock pr_0
add_cells_to_pblock [get_pblocks pr_0] [get_cells -quiet [list pr_0]]
resize_pblock [get_pblocks pr_0] -add {SLICE_X90Y100:SLICE_X113Y149}
resize_pblock [get_pblocks pr_0] -add {DSP48_X3Y40:DSP48_X4Y59}
resize_pblock [get_pblocks pr_0] -add {PMVBRAM_X4Y2:PMVBRAM_X5Y2}
resize_pblock [get_pblocks pr_0] -add {RAMB18_X4Y40:RAMB18_X5Y59}
resize_pblock [get_pblocks pr_0] -add {RAMB36_X4Y20:RAMB36_X5Y29}
set_property SNAPPING_MODE ON [get_pblocks pr_0]











