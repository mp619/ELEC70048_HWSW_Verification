testbench_gpio:
	echo "Compiling..."
	vlog -work work +acc=blnr -noincr -timescale 1ns/1ps rtl/AHB_GPIO/*	tbench_gpio/*

	echo "Optimizing..."
	vopt -work work AHBGPIO_top -o work_opt

	echo "Opening vsim"
	vsim work_opt -gui

testbench_nogui:
	echo "Compiling..."
	vlog -work work +acc=blnr -noincr -timescale 1ns/1ps rtl/AHB_GPIO/*	tbench_gpio/*

	echo "Optimizing..."
	vopt -work work AHBGPIO_top -o work_opt

	echo "Opening vsim"
	vsim work_opt -c -do setup.do \
		-l out.log &

setdisplay:
	export DISPLAY=localhost:16.0
