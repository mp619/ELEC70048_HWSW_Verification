`include "Driver.sv"
class environment;
    Generator gen;
    Driver driv;
    mailbox gen2driv;
    virtual AHBGPIO_intf ahbgpio_vintf;

    function new(virtual AHBGPIO_intf ahbgpio_vintf);
        this.ahbgpio_vintf = ahbgpio_vintf;
        gen2driv = new();
        gen = new(gen2driv);
        driv = new(ahbgpio_vintf, gen2driv); 
    endfunction

    task init();
        driv.reset();
    endtask 

    task test();
        gen.main();
        driv.main();
    endtask

    task post_test();
        wait(gen.no_packets == driv.pkt_count);
    endtask

    task run_test();
        $display("[Environment] Starting at T = %0t", $time);
        init();
        test();
        post_test();
        $stop;
    endtask
endclass