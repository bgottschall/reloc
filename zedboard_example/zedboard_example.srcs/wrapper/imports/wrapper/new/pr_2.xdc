create_pblock pr_2
add_cells_to_pblock [get_pblocks pr_2] [get_cells -quiet [list pr_2]]
resize_pblock [get_pblocks pr_2] -add {SLICE_X90Y0:SLICE_X113Y49}
resize_pblock [get_pblocks pr_2] -add {DSP48_X3Y0:DSP48_X4Y19}
resize_pblock [get_pblocks pr_2] -add {PMVBRAM_X4Y0:PMVBRAM_X5Y0}
resize_pblock [get_pblocks pr_2] -add {RAMB18_X4Y0:RAMB18_X5Y19}
resize_pblock [get_pblocks pr_2] -add {RAMB36_X4Y0:RAMB36_X5Y9}
set_property SNAPPING_MODE ON [get_pblocks pr_2]











