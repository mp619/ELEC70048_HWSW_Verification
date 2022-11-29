`include "Environment.sv"

program automatic AHBVGA_tb(AHBVGA_intf ahbVGA_intf);
    environment env;

    initial begin 
        env = new(ahbvga_intf.DRIVER, ahbvga_intf.MONITOR);

        //Intilazation of DUT
        env.run_test();

    end
endprogram

