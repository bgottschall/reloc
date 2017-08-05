create_pblock pr_1
add_cells_to_pblock [get_pblocks pr_1] [get_cells -quiet [list pr_1]]
resize_pblock [get_pblocks pr_1] -add {SLICE_X90Y50:SLICE_X113Y99}
resize_pblock [get_pblocks pr_1] -add {DSP48_X3Y20:DSP48_X4Y39}
resize_pblock [get_pblocks pr_1] -add {PMVBRAM_X4Y1:PMVBRAM_X5Y1}
resize_pblock [get_pblocks pr_1] -add {RAMB18_X4Y20:RAMB18_X5Y39}
resize_pblock [get_pblocks pr_1] -add {RAMB36_X4Y10:RAMB36_X5Y19}
set_property SNAPPING_MODE ON [get_pblocks pr_1]











