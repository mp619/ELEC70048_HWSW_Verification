log -r /*
add wave ahbgpio1/*
run  100us
coverage save -assert -directive -cvg -codeAll tbench_gpio.ucdb