`include "Driver.sv"
class environment;
    Generator gen;
    Driver driv;
    mailbox gen2driv;
    virtual AHBGPIO_intf ahbgpio_vintf;
    int no_packets = 10;

    function new(virtual AHBGPIO_intf ahbgpio_vintf);
        this.ahbgpio_vintf = ahbgpio_vintf;
        gen2driv = new();
        gen = new(gen2driv, no_packets);
        driv = new(ahbgpio_vintf, gen2driv, no_packets); 
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
        $display("[Environment] gen.no_packets = %0d", gen.no_packets);
        $display("[Environment] driv.pkt_count = %0d", driv.pkt_count);
        post_test();
        $stop;
    endtask
endclass