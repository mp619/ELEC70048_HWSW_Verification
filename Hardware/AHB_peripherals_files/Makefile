testbench:
	echo "Compiling..."
	vlog -work work +acc=blnr -noincr -timescale 1ns/1ps tbench/* rtl/multiplier.sv

	echo "Optimizing..."
	vopt -work work tb_top -o work_opt

	echo "Opening vsim"
	vsim work_opt -gui

testbench_2:
	echo "Compiling..."
	vlog -work work +acc=blnr -noincr -timescale 1ns/1ps rtl/multiplier.sv tbench_2/*

	echo "Optimizing..."
	vopt -work work multiplier_top -o work_opt

	echo "Opening vsim"
	vsim work_opt -gui

testbench_3:
	echo "Compiling..."
	vlog -work work +acc=blnr -noincr -timescale 1ns/1ps rtl/multiplier.sv tbench_2/*

	echo "Optimizing..."
	vopt -work work multiplier_top -o work_opt

	echo "Opening vsim"
	vsim work_opt -c -do setup.do \
		-l out.log &

example:
	echo "Compiling..."
	vlog -work work +acc=blnr -noincr -timescale 1ns/1ps tbench_example/*

	echo "Optimizing..."
	vopt -work work multiplier_top -o work_opt

	echo "Opening vsim"
	vsim work_opt -gui

setdisplay:
	export DISPLAY=localhost:16.0
