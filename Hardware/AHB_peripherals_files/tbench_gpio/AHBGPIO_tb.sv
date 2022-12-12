`include "Environment.sv"

program automatic AHBGPIO_tb(AHBGPIO_intf ahbgpio_intf);
    environment env;

    initial begin 
        env = new(ahbgpio_intf.DRIVER, ahbgpio_intf.MONITOR);
        // Intilazation of DUT
        env.run_test();
    end
endprogram