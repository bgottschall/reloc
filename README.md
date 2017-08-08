# Designing Relocatable Partitions with Vivado Design Suite

* Implement one bitstream and configure it in different FPGA locations FPGA
* Combining Isolation Design Flow and Partial Reconfiguration
* Preserving Compability of bitstreams over different implementations
* Much less implementation time

# procs.tcl
This file contains a collection of tcl functions which are useful and necessary for the relocation process. Source this file for the relocation process in pr_script.tcl or simply to extend the Vivado features.

# pr_script.tcl
This file contains a complete example workflow for a relocation process. On the first few lines are different parameters to control the workflow and interface placement. The workflow is only compatible with the design guidelines described in 'reloc.pdf'.

# reloc.pdf
This is the complete guide with all explanations and examples.

# zedboard_example
Example Project for the ZedBoard.

* Open with Vivado
* Open and generate shipped block design
* source procs.tcl
* source pr_script.tcl

Implemented design has now 3 relocatable partions.

# relocater
Working proof of concept. Creating FAR Profiles from existing Bitstreams and patching them in new ones!

* Get Header and FAR Informations from bitstreams
* Writing the FAR Addresses into profile files
* Patching bitstreams with FAR Address Profiles

WARNING: make always a copy of the bitstreams you are working on. If the patching is successful the relocater overwrites the bitstream.
