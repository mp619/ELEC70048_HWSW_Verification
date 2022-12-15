log -r /*
add wave ahbgpio1/*
run  100us
toggle disable /AHBGPIO_top/ahbgpio1/HRDATA[31:16]
toggle disable /AHBGPIO_top/ahbgpio1/GPIODIR[15:1]
toggle disable /AHBGPIO_top/ahbgpio1/gpio_data_next[15-0]
coverage save -assert -directive -cvg -codeAll tbench_gpio.ucdb