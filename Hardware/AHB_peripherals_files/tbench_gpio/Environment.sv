//`include "Transaction.sv"
//`include "Generator.sv"
//`include "Driver.sv"
`include "Scoreboard.sv"
class environment;
    virtual AHBGPIO_intf ahbgpio_vintf;

    Generator gen;
    Driver driv;
    Monitor mon;
    Scoreboard scb;

    mailbox gen2driv;
    mailbox mon2scb;

    int no_packets = 6;

    function new(virtual AHBGPIO_intf ahbgpio_vintf_DRIVER, virtual AHBGPIO_intf ahbgpio_vintf_MONITOR);
        this.ahbgpio_vintf = ahbgpio_vintf;
        gen2driv = new();
        gen = new(gen2driv, no_packets);
        driv = new(ahbgpio_vintf_DRIVER, gen2driv, no_packets); 
        mon2scb = new();
        mon = new(ahbgpio_vintf_MONITOR, mon2scb, no_packets);
        scb = new(ahbgpio_vintf_MONITOR, mon2scb, no_packets);
    endfunction

    task init();
        driv.reset();
    endtask 

    task test();
        fork 
        // Thread 1
        begin
            //gen.main();
            driv.test();    
        end
        // Thread 2
        mon.main();
        scb.main();
        join_any
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
        //post_test();
        $stop;
    endtask
endclass