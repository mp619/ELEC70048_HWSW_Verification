log -r /*
add wave /ahblite_sys_tb/dut/CLK
add wave /ahblite_sys_tb/dut/RESET
add wave /ahblite_sys_tb/dut/LED
add wave /ahblite_sys_tb/dut/SW
add wave /ahblite_sys_tb/dut/HWDATA
add wave /ahblite_sys_tb/dut/HRDATA
add wave /ahblite_sys_tb/dut/HSEL_MEM
add wave /ahblite_sys_tb/dut/HSEL_GPIO
add wave /ahblite_sys_tb/dut/HSEL_VGA
add wave /ahblite_sys_tb/dut/uAHBGPIO/gpio_dir
add wave /ahblite_sys_tb/dut/uAHBGPIO/HADDR
add wave /ahblite_sys_tb/dut/uAHBGPIO/HWDATA
add wave /ahblite_sys_tb/dut/uAHBGPIO/HRDATA
run  1us
#run 17ms