testbench_gpio:
	echo "Compiling..."
	vlog -work work +acc=blnr +cover -noincr -timescale 1ns/1ps rtl/AHB_GPIO/AHBGPIO_parity.sv tbench_gpio/*

	echo "Optimizing..."
	vopt -work work AHBGPIO_top -o work_opt

	echo "Opening vsim"
	vsim work_opt -gui -coverage

gpio_coverage:
	vcover report -details -html gpio.ucdb

testbench_gpio_nogui:
	echo "Compiling..."
	vlog -work work +acc=blnr +cover -noincr -timescale 1ns/1ps rtl/AHB_GPIO/AHBGPIO_parity.sv tbench_gpio/*

	echo "Optimizing..."
	vopt -work work AHBGPIO_top -o work_opt

	echo "Opening vsim"
	vsim work_opt -c -coverage -do ./filesdo/setup.do \
		-l ./logs/outGPIO.log & \

testbench_vga:
	echo "Compiling..."
	vlog -work work +acc=blnr +cover -noincr -timescale 1ns/1ps -f ./filesVC/ahbvga_sys.vc 

	echo "Optimizing..."
	vopt -work work AHBVGA_top -o work_opt

	echo "Opening vsim"
	vsim work_opt -gui -coverage

vga_coverage:
	vcover report -details -html vga.ucdb

testbench_vga_nogui:
	echo "Compiling..."
	vlog -work work +acc=blnr -noincr -timescale 1ns/1ps -f ./filesVC/ahbvga_sys.vc 

	echo "Optimizing..."
	vopt -work work AHBVGA_top -o work_opt

	echo "Opening vsim"
	vsim work_opt -c -do ./filesdo/setupvga.do \
		-l ./logs/outVGA.log &

testbench_top:
	echo "Compiling..."
	vlog -work work +acc=blnr -noincr -timescale 1ns/1ps -f ./filesVC/ahblite_sys.vc

	echo "Optimizing..."
	vopt ahblite_sys_tb -o work_opt

	echo "Opening vsim"
	vsim work_opt -gui

testbench_jg:
	jg rtl/AHB_GPIO/AHBGPIO.tcl

setdisplay:
	export DISPLAY=localhost:16.0
	source /usr/local/cadence/JASPER_2018.06.002/settings.sh 



