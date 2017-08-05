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


# Checks if a design is opened, like elaborated, synthesized or implemented
# design. Outputs Error if not and can be used in if statements.
#
# @return 1 if design is open, 0 else
proc design_open {} {
    if { [llength [current_design -quiet]] eq 0 } {
        puts stderr "ERROR: \[Common 17-53\] User Exception: No open design. Please open an elaborated, synthesized or implemented design before executing this command."
        return 0
    }
    return 1
}

# Gets the primitive starting cells of a net or a list of nets
#
# @param of_nets list of nets
# @return list of start cells
proc get_nets_start_cells { of_nets } {
    if { ! [design_open] } {
        return ""
    }
    set of_nets [get_nets $of_nets]
    set cells [list]
    #need to iterate over possible list, we only take one elemnt for each call
    foreach net $of_nets {
        lappend cells [get_cells -of_objects [lindex [get_nets -segments $net] 0] -filter {IS_PRIMITIVE}]
    }
    return [get_cells $cells]
}

# Gets the primitive ending cells of a net or a list of nets
#
# @param of_nets list of nets
# @return list of end cells
proc get_nets_end_cells { of_nets } {
    if { ! [design_open] } {
        return ""
    }
    set of_nets [get_nets $of_nets]
    set cells [list]
    #need to iterate over possible list, we only take one elemnt for each call
    foreach net $of_nets {
        lappend cells [get_cells -of_objects [lindex [get_nets -segments $net] end] -filter {IS_PRIMITIVE}]
    }
    return [get_cells $cells]
}

# Get all Interconnect Tiles of Sites or Tiles like SLICE_X0Y0 or
#
# @param of_nets list of nets
# @return list of end cells
proc get_interconnects { from } {
    if { ! [design_open] } {
        return ""
    }
    set target [get_sites -quiet $from]
    if { [string length $target] eq 0 } {
        #Could be a tile, check it
        set target [get_tiles -quiet $from]
        if { [string length $target] eq 0 } {
            #unknown what ever, empty response
            puts stderr "WARNING: Not a valid object for retrieving interconnects"
            return ""
        }
    } {
        #List of Sites were given, parse all tiles from:
        set target [get_tiles -of_objects $target]
    }
    return [filter_tiles [get_tiles -of_objects $target] "INT_\[RL\]"]
}

# Unfixes and unroutes given nets, routes them and fixes them again
# Useful in relocation process for nets which fails on routing
#
# @param of_nets list of nets
# @return nothing
proc refix_routes {of_nets} {
    if { ! [design_open] } {
        return ""
    }
    set of_nets [get_nets $of_nets]
    fix_lut_pins $of_nets 0
    fix_routes $of_nets 0
    route_design -unroute -nets $of_nets
    route_design -nets $of_nets
    fix_lut_pins $of_nets 1
    fix_routes $of_nets 1
}

# (Un)fixes the routes of the given nets. Does basically the same as the GUI
# but for any number of nets. Aliases will be transformed to real nets.
#
# @param of_nets list of nets
# @param state 1 for fix (default), 0 for unfix
# @return nothing
proc fix_routes {of_nets {state 1}} {
    if { ! [design_open] } {
        return ""
    }
    set index 0
    set of_nets [get_nets $of_nets]
    if { $state eq 1 } {
        puts "Fix #[llength $of_nets] routes..."
    } {
        puts "Unfix #[llength $of_nets] routes..."
        set state 0
    }

    foreach net $of_nets {
        set parent [get_property PARENT $net]
        if { $parent ne $net } {
            puts "Net #$index: Parent $parent found!"
            set net [get_nets $parent]
        }
        set start [get_nets_start_cells $net]
        set end [get_nets_end_cells $net]
        puts "Net #$index: $net starts at $start and goes to $end"

        startgroup
        set_property is_route_fixed $state $net
        set_property is_bel_fixed $state [get_cells $start]
        set_property is_loc_fixed $state [get_cells $start]
        set_property is_bel_fixed $state [get_cells $end]
        set_property is_loc_fixed $state [get_cells $end]
        endgroup
        incr index
    }
}

# (Un)sets the LOCK_PINS constraint of a placed and routed LUT Cell. This
# constraint is a fixed definition which Input Pins and Output Pin of the LUT
# Cell is used from the routes. Fixing a Route without this constraint is not
# possible! Basically an improved version from Xilinx which does ignore non
# LUT Cells.
#
# @param of_nets list of nets
# @param state 1 for fix (default), 0 for unfix
# @return nothing
proc fix_lut_pins {of_nets {state 1}} {
    if { ! [design_open] } {
        return ""
    }
    set of_nets [get_nets $of_nets]
    foreach net $of_nets {
        puts "Processing net $net"
            set loadpins [get_pins -leaf -of [get_nets $net] -filter direction=~in]

            foreach loadpin $loadpins {

                set pin [lindex [split $loadpin /] end]
                set belpin [lindex [split [get_bel_pins -of [get_pins $loadpin]] /] end]
                set index [expr [string last "/" $loadpin] - 1]
                set lut [string range $loadpin 0 $index]
                set beltype [get_bel_pins -of [get_pins $loadpin]]

                set type [get_property PRIMITIVE_GROUP [get_cells $lut]]
                if { $type eq "LUT" } {
                    # Create hash table of LUT names and pin assignments, appending when needed
                    if {[regexp (LUT) $beltype]} {
                        if { [info exists lut_array($lut)] } {
                            set lut_array($lut) "$lut_array($lut) $pin:$belpin"
                        } else {
                            set lut_array($lut) "$pin:$belpin"
                        }
                    }
                } else {
                    puts "Primitive Cell is $type and not LUT! Skipping..."
                }
            }

    }

    foreach lut_name [array names lut_array] {
        if { $state eq 1 } {
            puts "Creating LOCK_PINS constraint $lut_array($lut_name) for LUT $lut_name."
            set_property LOCK_PINS "$lut_array($lut_name)" [get_cells $lut_name]
        } else {
            puts "Reset LOCK_PINS constraint for LUT $lut_name."
            reset_property LOCK_PINS [get_cells $lut_name]
        }


    }
}

# Sets the HD.PARTPIN_LOCS constraint for the given pins to the nearest.
# interconnect. A Pin has a direction (IN or OUT) and a related net. Depending
# on the direction the interconnect tile from the start or end cells is used.
#
# @param of_pins list of pins
# @param state 1 for fix (default), 0 for unfix
# @return nothing
proc fix_plocs { of_pins {state 1}} {
    if { ! [design_open] } {
        return ""
    }
    set of_pins [get_pins $of_pins]
    foreach pin $of_pins {
        if { $state eq 0 } {
            reset_property -quiet HD.PARTPIN_LOCS $pin
            puts "$pin resetted"
        } {
            set dir [get_property DIRECTION $pin]
            set net [get_nets -of_objects $pin]
            set parent [get_property PARENT $net]
            set parentNet [get_nets $parent]
            #Get only one target Cell
            if { $dir eq "OUT" } {
                set targetCell [lindex [get_nets_start_cells $parentNet] 0]
            } {
                set targetCell [lindex [get_nets_end_cells $parentNet] 0]
            }

            set loc [get_property LOC $targetCell]
            if { [string length $loc] eq 0 } {
                puts "Pin $pin is not correctly fixed! Pin ignored!"
            } {
                set intc [get_interconnects $loc]
                if { [string length $intc] eq 0 } {
                    puts "No Interconnect found for LOC $loc! Pin ignored!"
                } {
                    reset_property -quiet HD.PARTPIN_LOCS $pin
                    set_property HD.PARTPIN_LOCS $intc $pin
                    puts "$pin will be placed on $intc"
                }
            }
        }
    }
}

# Helper Procedure for saving constraints in a more comfortable way. Can save
# constraints to a new constraints set (existing one gets overwritten) and can
# also change target file while saving. The saved constraint set will be the
# target set.
#
# @param name optionally a new name of the constraint (current set is default)
# @param target_file name of the target file to save the constraints
# @return nothing
proc save_constraints_force {{name ""} {target_file ""}} {
    if { ! [design_open] } {
        return ""
    }
    set path [get_property DIRECTORY [current_project]]/[current_project].srcs
    set old_target_file [file tail [get_property TARGET_CONSTRS_FILE [current_fileset -constrset]]]
    if { [string length $name] eq 0 } {
        #NO OBJECT HERE! Deleting fileset will turn $name empty if it is an object
        set name [lindex [current_fileset -constrset] 0]
    }
    if { [string length $target_file] eq 0} {

        set target_file $old_target_file
    }

    if { [string length $target_file] ne 0 && [file extension $target_file] ne ".xdc" } {
        set target_file [file tail [file rootname $target_file]].xdc
    }


    if { [current_fileset -constrset] eq $name } {
        #Switch to another name, save_constraints doesn't support changing target file
        save_constraints_as SAVE_CONSTRAINTS_FORCE_TEMP -target_constrs_file $target_file
        set_property constrset SAVE_CONSTRAINTS_FORCE_TEMP [current_run -synthesis]
        set_property constrset SAVE_CONSTRAINTS_FORCE_TEMP [current_run -implementation]

        delete_fileset -quiet $name
        file delete -force $path/$name

        save_constraints_as $name -target_constrs_file $target_file
        set_property constrset $name [current_run -synthesis]
        set_property constrset $name [current_run -implementation]

        delete_fileset -quiet SAVE_CONSTRAINTS_FORCE_TEMP
        file delete -force $path/SAVE_CONSTRAINTS_FORCE_TEMP
    } else {
        if { [file exists $path/$name] eq 1 || [string length [get_filesets -quiet -filter {FILESET_TYPE==Constrs} $name]] ne 0 } {
            delete_fileset -quiet $name
            file delete -force $path/$name
        }
        save_constraints_as $name -target_constrs_file $target_file
        set_property constrset $name [current_run -synthesis]
        set_property constrset $name [current_run -implementation]
    }
}


# Gets the resource ranges from a pblock. Can filter a specific resource type
# out of the ranges list (SLICES, RAM ...)
#
# @param pblock pblock to get the ranges from
# @param type optional filter for a range type
# @return nothing
proc get_range_from_pblock {pblock {type ""}} {
    if { ! [design_open] } {
        return ""
    }
    set pblock [ get_pblocks $pblock ]
    if { [llength $pblock] ne 1 } {
        puts stderr "ERROR: no pblock or multiple pblocks found"
        return ""
    }
    set ranges [get_property DERIVED_RANGES [get_pblock $pblock]]
    if { [string length $type] ne 0 } {
        set gridtypes [list]
        foreach gridtype $ranges {
            if { [regexp ^${type}_X[0-9]+Y[0-9]+ $gridtype] eq 1 } {
                lappend gridtypes $gridtype
            }
        }
        return $gridtypes
    } else {
        return $ranges
    }
}

# Filters a list of tiles or sites. Useful for filtering specific tiles, rows
# or columns.
#
# @param tiles list to process
# @param regex_tile regex filter for tile (default any)
# @param regex_col regex filter for column (default any)
# @param regex_row regex filter for row (default any)
# @return filtered list
proc filter_tiles {tiles {regex_tile "[A-Z0-9_]+"} {regex_col "[0-9]+"} {regex_row "[0-9]+"}} {
    set result [list]
    foreach tile $tiles {
        if { [regexp ^${regex_tile}_X${regex_col}Y${regex_row}\$ $tile] eq 1 } {
            lappend result $tile
        }
    }
    return $result
}

# Extracts the types from a tile list.
# E.g. SLICE_X1Y1 INT_L_X0Y0 -> SLICE INT_L
#
# @param tiles list to process
# @return list of types
proc get_types { tiles } {
    set types [list]
    foreach tile $tiles {
        set matched [regexp {^([A-Z0-9_]+)_X([0-9]+)Y([0-9]+)} $tile -> tile x y]
        if { $matched ne 0 } {
            if { [lsearch $types $tile] eq -1 } {
                lappend types $tile
            }
        }
    }
    return $types
}

# Extracts the rows from a tile list.
# E.g. SLICE_X1Y1 SLICEX0Y0 -> 0 1
#
# @param tiles list to process
# @return list of rows in ascending order
proc get_rows {tiles} {
    set result [list]
    foreach tile $tiles {
        set matched [regexp {^[A-Z0-9_]+_X([0-9]+)Y([0-9]+)$} $tile -> x y]
        if {$matched eq 0} {
            puts stderr "$tile: invalid tile"
        } else {
            if { [lsearch $result $y] eq -1 } {
                lappend result $y
            }
        }
    }
    return [lsort -integer $result]
}

# Extracts the columns from a tile list.
# E.g. SLICE_X1Y0 SLICEX0Y0 -> 0 1
#
# @param tiles list to process
# @return list of cols in ascending order
proc get_cols {tiles} {
    set result [list]
    foreach tile $tiles {
        set matched [regexp {^[A-Z0-9_]+_X([0-9]+)Y([0-9]+)$} $tile -> x y]
        if {$matched eq 0} {
            puts stderr "$tile: invalid tile"
        } else {
            if { [lsearch $result $x] eq -1 } {
                lappend result $x
            }
        }
    }
    return [lsort -integer $result]
}

# Transforms a range statement to a list. Respects the changing bahviour of
# interconnect tiles (R and L).
# E.g. SLICE_X0Y0:SLICE_X2Y0 -> SLICE_X0Y0 SLICE_X1Y0 SLICEX2Y0
#
# @param ranges range list to process
# @return list of tiles (no objects)
proc get_list_from_range {ranges} {
    set result [list]
    foreach range $ranges {
        set matched [regexp {^([A-Z0-9_]+)_X([0-9]+)Y([0-9]+):([A-Z0-9_]+)_X([0-9]+)Y([0-9]+)} $range -> tile1 x1 y1 tile2 x2 y2]
        if {$matched eq 0} {
            puts stderr "$range: invalid tile range"
        }

        if { $tile1 eq "INT_L" || $tile1 eq "INT_R" } {
            set tile1 "INT"
        }

        if { $tile2 eq "INT_L" || $tile2 eq "INT_R" } {
            set tile2 "INT"
        }

        if { $tile1 ne $tile2 } {
            puts  stderr "$range: invalid tile range"
            set matched 0
        }

        if { $matched ne 0 } {
            set tile $tile1
            set startx [expr min($x1,$x2)]
            set endx [expr max($x1,$x2)]
            set starty [expr min($y1,$y2)]
            set endy [expr max($y1,$y2)]
            for {set i $startx} {$i <= $endx} {incr i} {
                if { $tile1 eq "INT" } {
                    set tile [if {[expr {$i%2}]} {list "INT_R"} {list "INT_L"}]
                }

                for {set z $starty} {$z <= $endy} {incr z} {
                    lappend result "${tile}_X${i}Y${z}"
                }
            }
        }
    }
    return $result
}

# Evenly distributes the given pins on the given interconnects with respect of
# the list orders.
#
# @param ranges range list to process
# @return list of tiles (no objects)
proc distribute_pins { pins intc } {
    if { ! [design_open] } {
        return ""
    }
    set pins [get_pins $pins]
    set intc [get_tiles $intc]
    set pinsPerIntc [expr ceil(double([llength $pins])/double([llength $intc]))]

    set pinIndex 0
    for {set i 0} {$i < [llength $intc]} {incr i} {
        for {set z 0} {$z < $pinsPerIntc && $pinIndex < [llength $pins]} {incr z; incr pinIndex} {
            put "Pin [lindex $pins $pinIndex] will be on [lindex $intc $i]"
            reset_property HD.PARTPIN_LOCS [lindex $pins $pinIndex]
            set_property HD.PARTPIN_LOCS [lindex $intc $i] [lindex $pins $pinIndex]
        }
     }
}

# Returns all nets which failed on routing. Does a simple text processing of
# report_route_status and parsing the nets to objects.
#
# @return list of nets with routing errors
proc get_failed_nets {} {
    if { ! [design_open] } {
        return ""
    }
    set nets [list]
    set status [report_route_status -return_string -show_all]
    set matched [regexp {^.*Nets with Routing Errors:(.*)$} $status -> nets_status]
    if { $matched eq 0 } {
        return $nets
    }
    while { $matched eq 1 } {
        set matched [regexp {\n  ([^\n]+)\n(.*)$} $nets_status -> net nets_status]
        if { $matched eq 1 } {
            lappend nets $net
        }

    }
    return [get_nets $nets]
}

# Helper function for sort_properties. Constraints need a fixed order in the
# files which are not always correctly saved by Vivado.
#
# @param x item to compare
# @param y item to compare
# @return 0 if no sorting is neede, -1 if y < x, 1 if y > x
proc sort_properties_compare { x y } {
    set order [list BEL LOC LOCK_PINS FIXED_ROUTE]
    foreach item $order {
        set pos1 [string first "set_property $item" $x]
        set pos2 [string first "set_property $item" $y]
        if { $pos1 > $pos2 } {
            return -1
        } elseif { $pos1 < $pos2 } {
            return 1
        }
    }
    return 0
}

# Sorts a constraint file to assure correct order of constraints. Vivado
# does sometimes strange stuff.
# BEL < LOC < LOCK_PINS < FIXED_ROUTE
#
# @param file file to sort
# @return nothing
proc sort_properties { file } {
    set file [get_files -of_objects [current_fileset -constrset] $file]
    if { [file exists $file] eq 0 } {
        puts stderr "ERROR: $file doesn't exist!"
        return ""
    }

    set f [open $file "r"]
    set sortdata [split [read $f] "\n"]
    close $f

    set sorted [lsort -command sort_properties_compare $sortdata]

    set f [open $file "w"]
    puts $f [join $sorted "\n"]
    close $f
}

# Starts and waits for the given run
#
# @param run run to start
# @return 0 on error and 1 on success
proc start_run { run } {
    launch_runs $run
    wait_on_run $run
    if { [get_property PROGRESS $run] != "100%" } {
        puts stderr "ERROR: $run failed"
        return 0
    }
    return 1
}

# Start the synthesize run
#
# @param run name of the synth run
# @param force force the run even if not necessary
# @return 0 on error and 1 on success
proc synthesize {{run "synth_1"} {force ""}} {
    set run [get_runs $run]
    set refresh [get_property NEEDS_REFRESH $run]
    set progress [get_property PROGRESS $run]
    if { $force ne "force" && $refresh eq 0 && $progress eq "100%" } {
        puts stderr "WARNING: Synthesized Design is up to date! Will not synthesize again!"
        return 1
    }
    reset_run $run
    return [start_run $run]
}

# Start the implementation run. does always start on synthesize
#
# @param run name of the impl run
# @param force force the run even if not necessary
# @return 0 on error and 1 on success
proc implement {{run "impl_1"} {force ""}} {
    set run [get_runs $run]
    set refresh [get_property NEEDS_REFRESH $run]
    set progress [get_property PROGRESS $run]
    if { $force ne "force" && $refresh eq 0 && $progress eq "100%" } {
        puts stderr "WARNING: Implemented Design is up to date! Will not synthesize again!"
        return 1
    }
    set parent [get_runs [get_property PARENT $run]]
    reset_run $run
    reset_run $parent
    return [start_run $run]
}

# Opens the synthesized design
#
# @param run optional name of the synthesize run
# @return nothing
proc open_synth { {run "synth_1"} } {
    set run [get_runs $run]
    open_run $run
}

# Opens the implemented design
#
# @param run optional name of the implementation run
# @return nothing
proc open_impl { {run "impl_1"} } {
    set run [get_runs $run]
    open_run $run
}

# Get all LUT6 resources of the given BELs
#
# @param of_objects list of BELs to retrieve the LUTs
# @return list of LUTs
proc get_bels_lut6 { of_objects } {
    set luts [list]
    set luts [concat $luts [get_bels -of_objects $of_objects -filter {TYPE=~LUT*6}]]
    return $luts
}

# Get all REG resources of the given BELs
#
# @param of_objects list of BELs to retrieve the REGs
# @return list of REGs
proc get_bels_ff { of_objects } {
    set of_objects [get_sites $of_objects]
    set ffs [list]
    set ffs [concat $ffs [get_bels -of_objects $of_objects -filter {TYPE==FF_INIT}]]
    set ffs [lsort [concat $ffs [get_bels -of_objects $of_objects -filter {TYPE==REG_INIT}]]]
    return $ffs
}

# Placed the given cells on the given BELs with respect to the list orders.
#
# @param cells list of cells
# @param bels list of bells
# @return nothing
proc place_cells {cells bels} {
    if {[llength $bels] < [llength $cells]} {
        puts stderr "Cannot place [llength $cells] cells on [llength $bels] BELs!"
        return ""
    }
    set index 0
    foreach cell $cells {
        puts "Place $cell to [lindex $bels $index]"
        place_cell $cell [lindex $bels $index]
        incr index
    }
}

# Gets the top cell in hirachie foreach given cell.
#
# @param cells list of cells
# @return root cells
proc get_cells_root { cells } {
    set cells [get_cells $cells]
    set result [list]
    foreach cell $cells {
        set parent $cell
        set prev_parent [get_property PARENT $parent]
        set timeout 0
        while { [string length $prev_parent] ne 0 && $timeout ne 100} {
            set parent $prev_parent
            set prev_parent [get_property PARENT $parent]
            incr timeout
        }
        if { $timeout ne 100 } {
            lappend result $parent
        } else {
            puts stderr "TIMEOUT: get_cells_root $cell"
        }
    }
    return $result
}

# Get the root from a path.
# E.g. pr_0/pr_0_input/reg[0] -> pr_0
#
# @param values list of paths
# @return root element of the paths
proc get_roots { values } {
    set result [list]
    foreach value $values {
        set matched [regexp {^([a-zA-Z0-9\[\]_\.]+)/?.*$} $value -> name]
        if { $matched ne 0 } {
            lappend result $name
        }
    }
    if { [llength $result] eq 1 } {
        set result [lindex $result 0]
    }
    return $result
}

# Get name from a path.
# E.g. pr_0/pr_0_input/reg[0] -> reg[0]
#
# @param values list of paths
# @return name from the paths
proc get_names { values } {
    set result [list]
    foreach value $values {
        set matched [regexp {^.*/([a-zA-Z0-9\[\]_\.]+)$} $value -> name]
        if { $matched ne 0 } {
            lappend result $name
        }
    }
    if { [llength $result] eq 1 } {
        set result [lindex $result 0]
    }
    return $result
}

# Get all boundary nets from a cell. That means all nets of a cell from which
# the start or end cell is not inside the cell itself.
#
# @param of_cells list of cells
# @return boundary nets
proc get_boundary_nets { of_cells } {
    set of_cells [get_cells $of_cells]
    set result [list]
    foreach cell $of_cells {
        set nets [get_nets $cell/*]
        foreach net $nets {
            set boundary false
            set starts [get_cells_root [get_nets_start_cells $net]]
            set ends [get_cells_root [get_nets_end_cells $net]]
            foreach start $starts {
                if { [lsearch $ends $start] eq -1 } {
                    set boundary true
                    break
                }
            }
            if { $boundary eq true } {
                lappend result $net
            }
        }
    }
    return $result
}

# Outputs a list to the console. Child elements get indented.
#
# @param output_list list to output on the console
# @param level indent level used for childs
# @return nothing
proc puts_list { output_list {level 1} } {
    if { [string length $output_list] eq 0 } {
        return
    }
    for {set i 1} { $i < $level } {incr i} {
        puts -nonewline  "\t"
    }
    puts "{"
    foreach ele $output_list {
        if { [llength $ele] > 1 } {
            puts_list $ele [expr $level + 1]
        } else {
            for {set i 0} { $i < $level } {incr i} {
                puts -nonewline  "\t"
            }
            puts $ele
        }
    }
    for {set i 1} { $i < $level } {incr i} {
        puts -nonewline  "\t"
    }
    puts "}"
}

# get_nets wrapper for filtering clock nets
#
# @param nets nets to process
# @return nets without clock nets
proc get_nets_no_clk { nets } {
    get_nets -filter {TYPE!~*CLOCK*} $nets
}

# get_pins wrapper for filtering clock pins. Sadly only detecting clock pins
# only from the name of the pins.
#
# @param pins pins to process
# @return pins without clock pins
proc get_pins_no_clk { nets } {
    get_pins -filter {NAME!~*CLOCK* && NAME!~*clk*} $nets
}

# Compares two lists
#
# @param a list
# @param b list
# @return 0 if not equal, 1 if equal
proc lequal {a b} {
    if { [llength $a] ne [llength $b] } {
        return 0
    }
    foreach i $a {
        if {[lsearch -exact $b $i] == -1} {
            return 0
        }
    }
    return 1
}

# Checkes the existance of elements in a list
#
# @param a list to search in
# @param b list of elements to search in a
# @return 0 if b is not in a, 1 if b is in a
proc lcontains {a b} {
    foreach i $b {
        if {[lsearch -exact $a $i] eq -1 } {
            return 0
        }
    }
    return 1
}

# Relocates the given tiles with a column and row offset
# E.g. SLICE_X5Y0 5 10 -> SLICE_X10Y10
#
# @param tiles list of tiles
# @param offset_x column offset
# @param offset_y row offset
# @return list of relocated tiles
proc get_tiles_relocated { tiles { offset_x 0 } { offset_y 0 }} {
    set result [list]
    foreach tile $tiles {
        set matched [regexp {^([A-Z0-9_]+)_X([0-9]+)Y([0-9]+)$} $tile -> tile x y]
        if { $matched ne 0 } {
            lappend result "${tile}_X[expr $x + ${offset_x}]Y[expr $y + ${offset_y}]"
        }
    }
    return $result
}

# Normalizes a list of tile to column 0 and row 0
# E.g. SLICE_X5Y6 SLICE_X7Y7 -> SLICE_X0Y0 SLICE_X2Y1
#
# @param tiles list of tiles
# @return list of normalized tiles
proc get_tiles_normalized { tiles } {
    return [get_tiles_relocated $tiles -[get_tiles_offset_x $tiles] -[get_tiles_offset_y $tiles]]
}

# Returns the column offset of the tile list, which is the smallest column
# number
# E.g. SLICE_X5Y6 SLICE_X7Y7 -> 5
#
# @param tiles list of tiles
# @return column offset
proc get_tiles_offset_x { tiles } {
    return [lindex [get_cols $tiles] 0]
}

# Returns the row offset of the tile list, which is the smallest row
# number
# E.g. SLICE_X5Y6 SLICE_X7Y7 -> 6
#
# @param tiles list of tiles
# @return row offset
proc get_tiles_offset_y { tiles } {
    return [lindex [get_rows $tiles] 0]
}

# Compares given pblocks if they are relocatable. Does not compare the
# arrangement of resources over different resource types. Checkes wrong
# hirachie and nested Cell count and the amount and arrangement of resources of
# the same type
#
# @param pblocks list of pblocks
# @return 1 on success, 0 on error
proc verify_relocateable_pblocks { pblocks } {
    set verify_pblocks [get_pblocks $pblocks]
    if { [lequal $verify_pblocks $pblocks] eq 0 } {
        puts stderr "Verify Error: Invalid pblocks!"
        return 0
    }
    if {[llength $verify_pblocks] eq 1 } {
        puts stderr "Verify Error: need more than one pblock!"
        return 0
    }

    set reloc 1
    set base_pblock ""
    set base_types [list]
    set base_sites [list]

    foreach pblock $verify_pblocks {
        if { [get_property CELL_COUNT $pblock] ne 1 } {
            puts stderr "Verify Error: Pblock $pblock needs exactly one cell!"
            set reloc 0
        }
        if { [get_property PARENT $pblock] ne "ROOT" } {
            puts stderr "Verify Error: Pblock $pblock is nested!"
            set reloc 0
        }

        set comp_types [list]
        set comp_sites [list]

        puts "Verify pblock $pblock:"
        set comp_types [lsort [get_types [get_range_from_pblock $pblock]]]
        foreach type $comp_types {
            set sites [lsort [get_tiles_normalized [get_list_from_range [get_range_from_pblock $pblock $type]]]]
            puts "\t - [llength $sites] $type sites"
            lappend comp_sites $sites
        }

        if { [llength $base_types] eq 0 } {
            set base_types $comp_types
            set base_sites $comp_sites
            set base_pblock $pblock
        } else  {
            if { [lequal $base_sites $comp_sites] eq 0 } {
                puts stderr "Verify Error: pblock $pblock doesn't match with $base_pblock!"
                set reloc 0
            }
        }
    }
    if { $reloc eq 1 } {
        return 1
    } else {
        puts stderr "Verify Error: pblocks are not suitable for relocation!"
        return 0
    }
}

# Sets cells as isolated for the Isolated Design Flow
#
# @param cells list of cells
# @return nothing
proc set_isolated { cells } {
    set cells [get_cells $cells]
    foreach cell $cells {
        set_property HD.RECONFIGURABLE false $cell
        #set_property DONT_TOUCH false $cell
        set_property HD.ISOLATED true $cell
    }
}

# Sets cells as reconfigurable
#
# @param cells list of cells
# @return nothing
proc set_reconfigurable { cells } {
    set cells [get_cells $cells]
    foreach cell $cells {
        set_property HD.ISOLATED false $cell
        #set_property DONT_TOUCH true $cell
        set_property HD.RECONFIGURABLE true $cell
    }
}

# Escapes all special TCL characters in a value
#
# @param value
# @return escaped valued
proc escape { value } {
    return [string map [list \[ {\[} \] {\]} \* {\*} \? {\?} \\ {\\}] $value]
}

# Escapes all special regex characters in a value
#
# @param value
# @return escaped valued
proc escape_regex { value } {
    return [string map [list \[ {\[} \] {\]} \* {\*} \? {\?} \\ {\\} - {\-} ( {\(} ) {\)} + {\+} . {\.} , {\,} / {\/}] $value]
}

# Sorts the second lsit to match the first one. Also Strips off path elements
# for comparison. Useful to match cells or nets from different parent cells.
# E.g [X/T[0] X/T[1]] [Y/T[1] Y/T[0]] -> [X/T[0] X/T[1]] [Y/T[0] Y/T[1]]
#
# @param list1 list to compare against
# @param pList2 name of list to sort and compare to list one
# @param strip_filter regex filter to strip of path elements for comparison (default first path element)
# @return 0 on error, 1 on success
proc match_lists { list1 pList2 { strip_filter "[a-zA-Z0-9_\\.\\[\\]]+/?" } } {
    upvar 1 $pList2 list2
    set assoc_list [list]
    set result 1
    for {set i 0} { $i < [llength $list1] } { incr i } {
        set entry [lindex $list1 $i]
        set matching_entry ""
        set matched [regex ^${strip_filter}(.*)$ $entry -> value]
        if { $matched ne 0 } {
            set value [escape_regex $value]
            set index [lsearch -regex $list2 ^.*${value}$]
            if { $index ne -1 } {
                set matching_entry [lindex $list2 $index]
            } else {
                puts stderr "Associate Error: no matching element found for $value"
                set result 0
            }
        } else {
            puts stderr "Associate Error: strip filter $strip_filter not correct for entry $entry"
            set result 0
        }
        lappend assoc_list $matching_entry
    }
    if { $result eq 1 } {
        set list2 $assoc_list
    }
    return $result
}

# Helper Function for copy_object_properties to relocate the HD.PARTPIN_LOCS
# property from one cell to another cell. Does calculate the new
# interconnect tile location relative to the pblocks of the cells. Works
# directly on the vars of the caller function.
#
# @param pFrom name cell to copy from
# @param pTo name cell to copy to
# @param pProperty name of the property
# @param pValue name of the value to apply
# @return nothing
proc relocate_partpin_property { pFrom pTo pProperty pValue } {
    upvar 1 $pFrom from
    upvar 1 $pTo to
    upvar 1 $pProperty property
    upvar 1 $pValue value

    if { $property eq "HD.PARTPIN_LOCS" } {
        set prop [filter_tiles $value "INT_\[LR\]"]
        if { [string length $prop] ne 0 } {
            set from_cell [get_property PARENT_CELL $from]
            set to_cell [get_property PARENT_CELL $to]
            set pblock_from [get_pblocks [get_property PBLOCK [get_cells_root $from_cell]]]
            set pblock_to [get_pblocks [get_property PBLOCK [get_cells_root $to_cell]]]

            if { [string length $pblock_from] ne 0 && [string length $pblock_to] ne 0 } {
                set slice_range_from [get_list_from_range [get_range_from_pblock $pblock_from SLICE]]
                set slice_range_to [get_list_from_range [get_range_from_pblock $pblock_to SLICE]]

                set from_int [get_interconnects "SLICE_X[get_tiles_offset_x $slice_range_from]Y[get_tiles_offset_y $slice_range_from]"]
                set to_int [get_interconnects "SLICE_X[get_tiles_offset_x $slice_range_to]Y[get_tiles_offset_y $slice_range_to]"]

                set offset_x [expr [get_tiles_offset_x $to_int] - [get_tiles_offset_x $from_int]]
                set offset_y [expr [get_tiles_offset_y $to_int] - [get_tiles_offset_y $from_int]]
                set prop [get_tiles_relocated $prop $offset_x $offset_y]
                set value [lindex [get_list_from_range "${prop}:${prop}"] 0]
                puts "Parsing PARTPIN_LOC: Apply offset X${offset_x}Y${offset_y}"
            } else {
                puts "WARNING: NOT PARSING PARTPIN_LOC, there is no pblock on $from or $to"
            }
        } else {
            puts "WARNING: NOT PARSING PARTPIN_LOC, there is a PARTPIN_LOC Property but no Interconnect Tile on Object $from"
        }
    }
}

# Helper Function for copy_object_properties to relocate the LOC property from
# one cell to another cell. Does calculate the new LOC location relative to the
# pblocks of the cells. Works directly on the vars of the caller function.
#
# @param pFrom name cell to copy from
# @param pTo name cell to copy to
# @param pProperty name of the property
# @param pValue name of the value to apply
# @return nothing
proc relocate_loc_property { pFrom pTo pProperty pValue } {
    upvar 1 $pFrom from
    upvar 1 $pTo to
    upvar 1 $pProperty property
    upvar 1 $pValue value

    if { $property eq "LOC" } {
        set prop [filter_tiles $value SLICE]
        if { [string length $prop] ne 0 } {

            set pblock_from [get_pblocks [get_property PBLOCK [get_cells_root $from]]]
            set pblock_to [get_pblocks [get_property PBLOCK [get_cells_root $to]]]

            if { [string length $pblock_from] ne 0 && [string length $pblock_to] ne 0 } {
                set slice_range_from [get_list_from_range [get_range_from_pblock $pblock_from SLICE]]
                set slice_range_to [get_list_from_range [get_range_from_pblock $pblock_to SLICE]]
                set offset_x [expr [get_tiles_offset_x $slice_range_to] - [get_tiles_offset_x $slice_range_from]]
                set offset_y [expr [get_tiles_offset_y $slice_range_to] - [get_tiles_offset_y $slice_range_from]]
                set value [get_tiles_relocated $prop $offset_x $offset_y]
                puts "Parsing LOC: Apply offset X${offset_x}Y${offset_y}"
            } else {
                puts "WARNING: NOT PARSING LOC, there is no pblock on $from or $to"
            }
        } else {
            puts "WARNING: NOT PARSING LOC, there is a LOC Property but no SLICE Tile on Object $from"
        }
    }
}

# Copies multiple properties from objects to other objects. Optional can parse
# the property with a helper function if a modification is needed before
# applying the new property (see relocate_loc_property or
# relocate_parpin_property)
#
# @param properties list of properties to copy
# @param from list of objects to copy from
# @param to list of ibjects to copy to
# @param parse_prop name of a parsing property function
# @return nothing
proc copy_object_properties { properties from to { parse_prop "" }} {
    set parse 0
    if { [string length $parse_prop] ne 0 } {
        if { [string length [info commands $parse_prop]] ne 0 } {
            set parse 1
        } else {
            puts stderr "WARNING: proc $parse_prop not found!"
        }
    }


    foreach property $properties {
        foreach obj $to {
            reset_properties $property $obj
        }
        set value [get_property $property $from]
        if { [string length $value] ne 0 } {
            foreach obj $to {
                if { $parse eq 1 } {
                    [$parse_prop from obj property value]
                }
                puts "Copy property $property $value from $from to $obj"
                set_property $property $value $obj
            }
        }
    }
}

# Resets multiple properties on any given objects. Does ignore errors if
# propety could not be ressetted. Does have special threatment for some
# properties
#
# @param properties list of properties to reset
# @param objs list of objects
# @return nothing
proc reset_properties { properties objs } {
    set empty_properties {LOC BEL LOCK_PINS}
    set false_properties {IS_LOC_FIXED IS_BEL_FIXED DONT_TOUCH}
    set unsupported_properties {DONT_TOUCH}
    foreach obj $objs {
        foreach prop $properties {
            if { [lsearch $false_properties $prop] ne -1 } {
                catch [list set $prop 0 $obj] err
            } elseif { [lsearch $empty_properties $prop] ne -1 } {
                catch [list set $prop "" $obj] err
                catch [list reset_property $prop $obj] err
            } else {
                catch [list reset_property $prop $obj] err
            }
        }
    }
}

# Gets all pins from a cell hierarchical
#
# @param cells list of cells to retrieve the pins
# @return all hierarchical pins from the given cells
proc get_pins_hierarchical { cells } {
    set result [list]
    foreach cell $cells {
        lappend result [get_pins -quiet $cell]
        set result [concat $result [get_pins -hierarchical -filter NAME=~$cell/*]]
    }
    return $result

}

# Gets all nets from a cell hierarchical
#
# @param cells list of cells to retrieve the nets
# @return all hierarchical nets from the given cells
proc get_nets_hierarchical { cells } {
    set result [list]
    foreach cell $cells {
        lappend result [get_nets -quiet $cell]
        set result [concat $result [get_nets -hierarchical -filter NAME=~$cell/*]]
    }
    return $result
}

# Gets all cells from a cell hierarchical. The cell itself is also returned.
#
# @param cells list of cells to retrieve all cells
# @return all hierarchical cells from the given cells
proc get_cells_hierarchical { cells } {
    set result [list]
    foreach cell $cells {
        lappend result [get_cells $cell]
        set result [concat $result [get_cells -hierarchical -filter NAME=~$cell/*]]
    }
    return $result
}

# Cleans up a Cell for relocation. Resets properties which are important for
# relocation.
# RESETS ALL PROPERTIES INSIDE A CELL, NOT ONLY INTERFACE PROPERTIES!
#
# @param cells list of cells
# @return nothing
proc relocate_cleanup { cells } {
    set cells [get_cells $cells]
    foreach cell $cells {
        set clean_cells [get_cells_hierarchical $cell]
        reset_properties {IS_LOC_FIXED IS_BEL_FIXED LOC BEL LOCK_PINS} $clean_cells

        set clean_pins [get_pins_hierarchical $cell]
        reset_properties {HD.PARTPIN_LOCS} $clean_pins

        set clean_nets [get_nets_hierarchical $cell]
        reset_properties {FIXED_ROUTE} $clean_nets

        set boundary_nets [get_boundary_nets $cell]
        reset_properties {IS_LOC_FIXED IS_BEL_FIXED LOC BEL LOCK_PINS} [get_nets_end_cells $boundary_nets]
        reset_properties {IS_LOC_FIXED IS_BEL_FIXED LOC BEL LOCK_PINS} [get_nets_start_cells $boundary_nets]
    }
}

# Relocates the interface of a base_cell to a given list of cells. It retrieves
# the interface of the first cell and compares ot to the others. If they match
# it will copy all properties from the base_cell to the others with special
# threatment to the LOC property.
# Relocation of HD.PARTPIN_LOCS is not enabled, fix_plocs does the same!
#
# @param base_cell base_cell to relocate from
# @param cells list of cells to relocate to
# @return nothing
proc relocate_cells { base_cell cells } {
    set base_cell [get_cells $base_cell]
    set cells [get_cells $cells]
    if { [string length $base_cell] eq 0 } {
        return "ERROR: Need a base cell to relocate from"
    }
    if { [string length $cells] eq 0 } {
        return "ERROR: Need at least one target cell to relocate to"
    }

    set base_pins [get_pins_no_clk $base_cell/*]
    set base_nets [get_nets_no_clk [get_boundary_nets $base_cell]]
    #Associate List will strip off the root cell and compares the rest, lut_buffers in pr_buffer and pr are symmetric, split them up
    set base_intfs [get_nets_start_cells $base_nets]
    set base_intfs [concat $base_intfs [get_nets_end_cells $base_nets]]
    set base_intfs_1 [get_cells $base_intfs -filter NAME=~$base_cell/*]
    set base_intfs_2 [get_cells $base_intfs -filter NAME!~$base_cell/*]
    #base_intfs will be sorted: first cells from the $cell and then the rest
    set base_intfs [concat $base_intfs_1 $base_intfs_2]

    foreach cell $cells {
        set cpy 1
        set nets [get_nets_no_clk [get_boundary_nets $cell]]
        set pins [get_pins_no_clk $cell/*]

        if { [match_lists $base_nets nets] eq 0 } {
            puts stderr "Boundary nets from $cell not matching with $base_cell"
            set cpy 0
        } else {
            set intfs [get_nets_start_cells $nets]
            set intfs [concat $intfs [get_nets_end_cells $nets]]
            set intfs_1 [get_cells $intfs -filter NAME=~$cell/*]
            set intfs_2 [get_cells $intfs -filter NAME!~$cell/*]
            if { [match_lists $base_intfs_1 intfs_1] eq 0 } {
                puts stderr "Interface Cells from $cell not matching with $base_cell"
                set cpy 0
            }
            if { [match_lists $base_intfs_2 intfs_2] eq 0 } {
                puts stderr "Interface Cells to $cell not matching with $base_cell"
                set cpy 0
            }
            set intfs [concat $intfs_1 $intfs_2]
        }
        if { [match_lists $base_pins pins] eq 0 } {
            puts stderr "Pin Nets from $cell not matching with $base_cell"
            set cpy 0
        }

        if { $cpy eq 1 } {
            puts "Cleanup cell $cell"
            relocate_cleanup $cell

            for {set i 0} { $i < [llength $base_intfs]} {incr i} {
                set base_intf [get_cells [lindex $base_intfs $i]]
                set intf [get_cells [lindex $intfs $i]]
                puts "#$i: $base_intf -> $intf"
                copy_object_properties [list "LOCK_PINS" "LOC" "BEL" "IS_LOC_FIXED" "IS_BEL_FIXED" "DONT_TOUCH"] $base_intf $intf relocate_loc_property
            }
            for {set i 0} { $i < [llength $base_nets]} {incr i} {
                set base_net [get_nets [lindex $base_nets $i]]
                set net [get_nets [lindex $nets $i]]
                puts "#$i: $base_net -> $net"
                copy_object_properties [list "FIXED_ROUTE"] $base_net $net
            }

# After relocation, fix_plocs will do the job but this would works:
#            for {set i 0} { $i < [llength $base_pins]} {incr i} {
#                set base_pin [get_pins [lindex $base_pins $i]]
#                set pin [get_pins [lindex $pins $i]]
#                puts "#$i: $base_pin -> $pin"
#                copy_object_properties [list "HD.PARTPIN_LOCS"] $base_pin $pin relocate_partpin_property
#            }

        }
    }
}
