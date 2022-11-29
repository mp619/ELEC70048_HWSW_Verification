testbench_gpio:
	echo "Compiling..."
	vlog -work work +acc=blnr -noincr -timescale 1ns/1ps rtl/AHB_GPIO/AHBGPIO_parity.sv tbench_gpio/*

	echo "Optimizing..."
	vopt -work work AHBGPIO_top -o work_opt

	echo "Opening vsim"
	vsim work_opt -gui

testbench_gpio_nogui:
	echo "Compiling..."
	vlog -work work +acc=blnr -noincr -timescale 1ns/1ps rtl/AHB_GPIO/AHBGPIO_parity.sv tbench_gpio/*

	echo "Optimizing..."
	vopt -work work AHBGPIO_top -o work_opt

	echo "Opening vsim"
	vsim work_opt -c -do setup.do \
		-l out.log &

testbench_vga:
	echo "Compiling..."
	vlog -work work +acc=blnr -noincr -timescale 1ns/1ps rtl/AHB_VGA/* tbench_vga/*

	echo "Optimizing..."
	vopt -work work AHBVGA_top -o work_opt

	echo "Opening vsim"
	vsim work_opt -gui

testbench_vga_nogui:
	echo "Compiling..."
	vlog -work work +acc=blnr -noincr -timescale 1ns/1ps rtl/AHB_VGA/* tbench_vga/*

	echo "Optimizing..."
	vopt -work work AHBVGA_top -o work_opt

	echo "Opening vsim"
	vsim work_opt -c -do setupvga.do \
		-l out.log &

testbench_top:
	echo "Compiling..."
	vlog -f ahblite_sys.vc

	echo "Optimizing..."
	vopt -work work +acc=blnr -noincr -timescale 1ns/1ps ahblite_sys_tb -o work_opt

	echo "Opening vsim"
	vsim work_opt -gui

testbench_jg:
	jg rtl/AHB_GPIO/AHBGPIO.tcl

setdisplay:
	export DISPLAY=localhost:16.0
	source /usr/local/cadence/JASPER_2018.06.002/settings.sh 

