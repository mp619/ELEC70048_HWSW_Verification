testbench:
	echo "Compiling..."
	vlog -work work +acc=blnr -noincr -timescale 1ns/1ps tbench/* rtl/multiplier.sv

	echo "Optimizing..."
	vopt -work work tb_top -o work_opt

	echo "Opening vsim"
	vsim work_opt -gui

multiplier:
	echo "Compiling..."
	vlog -work work +acc=blnr -noincr -timescale 1ns/1ps rtl/multiplier.sv

	echo "Optimizing..."
	vopt -work work multiplier -o work_opt

	echo "Opening vsim"
	vsim work_opt -gui

setdisplay:
	export DISPLAY = localhost:15.0
