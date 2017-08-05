# Copyright (c) 2017 Björn Gottschall <github.mail@bgottschall.de>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


#Do this manually once
#source procs.tcl

if { [info exists STEP] eq 0 } {
    set STEP 0
}

set pr_base pr_0
set pr_cells { pr_1 pr_2 }
#left, right
set interface_location left
#top, bottom, center, nosplit_top, nosplit_bottom
set interface_strategy top

set target_constraints "reloc"
set synth "synth_1"
set impl "impl_1"
#Autorun will source pr_script.tcl automatically after every step, vivado will be more stable
set autorun 1
#How many slices at top and bottom will not be used for interface placement
set interface_strategy_trim 4


set script [file normalize [info script]]
set dir [file dirname [file normalize [info script]]]


set script [file normalize [info script]]
if { [info exists called_from_autorun] eq 0 } {
    set called_from_autorun 0
}

if { $called_from_autorun eq 0 && $autorun eq 1 } {
    puts "Start Autorun"
    set STEP 0
}

if { $STEP eq 0 } {

    if {[synthesize $synth] eq 0} {
        return "ERROR: Synthesize"
    }

    open_run $synth

    if { [verify_relocateable_pblocks [get_pblocks [get_cells [concat $pr_base $pr_cells]]]] ne 1 } {
        return "ERROR: Cells $pr_base and $pr_cells are not in relocateable pblocks"
    }

    save_constraints_force $target_constraints isol.xdc


    set pr_base [get_cells $pr_base]
    set boundary_nets [get_boundary_nets $pr_base]
    set intf_start [get_nets_start_cells $boundary_nets]
    set intf_end [get_nets_end_cells $boundary_nets]

    set pr_input_cells [lsort [get_cells $intf_end -filter [list NAME=~$pr_base/*]]]
    set pr_output_cells [lsort [get_cells $intf_start -filter [list NAME =~$pr_base/*]]]
    set buffer_output_cells [get_cells $intf_end -filter [list NAME!~$pr_base/*]]
    set buffer_input_cells [get_cells $intf_start -filter [list NAME!~$pr_base/*]]

    if { [match_lists $pr_input_cells buffer_input_cells] eq 0 } {
        return "ERROR: Interface Cells of $pr_base and connecting cell don't match!"
    }
    if { [match_lists $pr_output_cells buffer_output_cells] eq 0 } {
        return "ERROR: Interface Cells of $pr_base and connecting cell don't match!"
    }


    set buf_cell [get_cells [lsort -unique [get_cells_root [concat $buffer_output_cells $buffer_input_cells]]]]
    if { [llength $buf_cell] ne 1 } {
        return "ERROR: Only one cell should be connected to PR $pr_base: $buf_cell"
    }

    set buf_pblock [get_pblocks [get_property PBLOCK $buf_cell]]
    set pr_pblock [get_pblocks [get_property PBLOCK $pr_base]]

    if { [string length $pr_pblock] eq 0 } {
        return "ERROR: No pblock found for PR cell $pr_base"
    }

    if { [string length $buf_pblock] eq 0 } {
        return "ERROR: No pblock found for connecting cell $buf_cell"
    }

    set pr_slices [get_list_from_range [get_range_from_pblock $pr_pblock SLICE]]
    set buf_slices [get_list_from_range [get_range_from_pblock $buf_pblock SLICE]]

    switch $interface_location {
        left {
            puts "Try to place Interface on the left of $pr_base"
            set pr_pos [lindex [get_cols $pr_slices] 0]
            set buf_pos [lindex [get_cols $buf_slices] end]
            if { $buf_pos > $pr_pos } {
                return "ERROR: PR interface at X${pr_pos} not facing connecting cell interface at X${$buf_pos}"
            }
            set pr_slices [filter_tiles $pr_slices SLICE ${pr_pos}]
            set buf_slices [filter_tiles $buf_slices SLICE ${buf_pos}]
        }
        right {
            puts "Try to place Interface on the right of $pr_base"
            set pr_pos [lindex [get_cols $pr_slices] end]
            set buf_pos [lindex [get_cols $buf_slices] 0]
            if { $pr_pos > $buf_pos } {
                return "ERROR: PR interface at X${pr_pos} not facing connecting cell interface at X${$buf_pos}"
            }
            set pr_slices [filter_tiles $pr_slices SLICE ${pr_pos}]
            set buf_slices [filter_tiles $buf_slices SLICE ${buf_pos}]
        }
        default {
            return "ERROR: unknown interface location (left, right): $interface_location"
        }
    }

    #Interface strategy trim will leave slices at top and bottom free from interface cells
    set pr_slices [lrange $pr_slices $interface_strategy_trim [expr [llength $pr_slices] - $interface_strategy_trim]]
    set buf_slices [lrange $buf_slices $interface_strategy_trim [expr [llength $buf_slices] - $interface_strategy_trim]]

    #Always sorted from bottom to top
    #interface_strategy:
    # top starts placement at top
    # bottom starts placement at bottom
    # center starts placement at center



    set slice_count [llength $pr_slices]
    set pr_input_slices [get_sites [lrange $pr_slices 0 [expr $slice_count / 2] ]]
    set pr_output_slices [get_sites [lrange $pr_slices [expr ($slice_count / 2) + 1] $slice_count]]

    set slice_count [llength $buf_slices]
    set buf_input_slices [get_sites [lrange $buf_slices 0 [expr $slice_count / 2]]]
    set buf_output_slices [get_sites [lrange $buf_slices [expr ($slice_count / 2) + 1] $slice_count]]

    switch $interface_strategy {
        bottom {
            set pr_input_slices [lsort $pr_input_slices]
            set pr_output_slices [lsort $pr_output_slices]
            set buf_input_slices [lsort $buf_input_slices]
            set buf_output_slices [lsort $buf_output_slices]
        }
        top {
            #Nothing to do
        }
        center {
            set pr_output_slices [lsort $pr_output_slices]
            set buf_output_slices [lsort $buf_output_slices]
        }
	nosplit_top -
	nosplit_bottom {
		set pr_input_slices [concat $pr_output_slices $pr_input_slices]
		set buf_input_slices [concat $buf_output_slices $buf_input_slices]
		set pr_input_cells [concat $pr_output_cells $pr_input_cells]
		set buffer_input_cells [concat $buffer_output_cells $buffer_input_cells]
		if { $interface_strategy eq "nosplit_bottom" } {
            set pr_input_slices [lsort $pr_input_slices]
            set buf_input_slices [lsort $buf_input_slices]
        }

	}
        default {
            return "ERROR: unknown interface strategy (top, bottom, center): $interface_strategy"
        }
    }

    set pr_input_bels [get_bels_lut6 $pr_input_slices]
    set pr_output_bels [get_bels_lut6 $pr_output_slices]

    set buf_input_bels [get_bels_lut6 $buf_input_slices]
    set buf_output_bels [get_bels_lut6 $buf_output_slices]



    if { [llength $buffer_input_cells] > [llength $buf_input_bels] } {
        return "ERROR: Connecting cell $buf_cell, more input cells than available bels"
    }

    if { [llength $pr_input_cells] > [llength $pr_input_bels] } {
        return "ERROR: PR cell $pr_base, more input cells than available bels"
    }

    relocate_cleanup $pr_base

    #Custom function which can place multiple cells on bels
	#opt_design will remove all luts, set them to DONT_TOUCH

    place_cells $buffer_input_cells $buf_input_bels
    place_cells $pr_input_cells $pr_input_bels
    set_property DONT_TOUCH 1 $pr_input_cells
    set_property DONT_TOUCH 1 $buffer_input_cells

    #In case nosplit isn't used we have to do the same for the other half of cells
    if { $interface_strategy ne "nosplit_bottom" && $interface_strategy ne "nosplit_top" } {

        if { [llength $buffer_output_cells] > [llength $buf_output_bels] } {
            return "ERROR: Connecting cell $buf_cell, more output cells than available bels"
        }

        if { [llength $pr_output_cells] > [llength $pr_output_bels] } {
            return "ERROR: PR Cell $pr_base, more output pr cells than available bels"
        }

        place_cells $pr_output_cells $pr_output_bels
        place_cells $buffer_output_cells $buf_output_bels
        set_property DONT_TOUCH 1 $pr_output_cells
        set_property DONT_TOUCH 1 $buffer_output_cells
    }


    save_constraints_force $target_constraints ${pr_base}_reloc.xdc

    fix_plocs [get_pins_no_clk ${pr_base}/*]

    save_constraints_force $target_constraints ${pr_base}_plocs.xdc

    set_isolated $pr_base
    set_isolated $pr_cells

    save_constraints_force $target_constraints isol.xdc

    close_design

    if { $autorun eq 1 } {
        incr STEP
        set called_from_autorun 1
        source -notrace $script
        set called_from_autorun 0
        return ""
    }
}

if { $STEP eq 1 } {
    if { [implement $impl] eq 0} {
        return "ERROR: Implementation"
    }

    open_run $impl

    set pr_base [get_cells $pr_base]

    set boundary_nets [get_nets_no_clk [get_boundary_nets ${pr_base}]]

    fix_lut_pins $boundary_nets
    fix_routes $boundary_nets

    save_constraints_force $target_constraints ${pr_base}_reloc.xdc

    if { $autorun eq 1 } {
            incr STEP
            set called_from_autorun 1
            source -notrace $script
            set called_from_autorun 0
            return ""
    }
}

if { $STEP eq 2 } {

    if { [synthesize $synth] eq 0} {
        return "ERROR: Synthesize"
    }
    open_run $synth

    set pr_base [get_cells $pr_base]

    foreach cell $pr_cells {
        #Does copy boundary nets and their cells to other things:
        relocate_cells $pr_base $cell
        save_constraints_force $target_constraints ${cell}_reloc.xdc
        fix_plocs [get_pins_no_clk ${cell}/*]
        save_constraints_force $target_constraints ${cell}_plocs.xdc
    }

    #With isolated cells this will mostly fail, the router/placer has problems with placing routes/pins INSIDE the pr (I wonder why)
    set_reconfigurable $pr_base
    set_reconfigurable $pr_cells
    save_constraints_force $target_constraints isol.xdc

    if { [implement $impl] eq 0} {
        return "ERROR: Implementation"
    }

    open_run $impl

    if { $autorun eq 1 } {
        incr STEP
        set called_from_autorun 1
        source -notrace $script
        set called_from_autorun 0
        return ""
    }
}

if { $STEP > 2 } {
    puts "This is the End!"
}
