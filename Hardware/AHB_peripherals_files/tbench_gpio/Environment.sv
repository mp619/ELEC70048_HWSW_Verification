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

    int dir0_pkts = 150;
    int dir1_pkts = 150;
    int random_pkts = 400;

    function new(virtual AHBGPIO_intf ahbgpio_vintf_DRIVER, virtual AHBGPIO_intf ahbgpio_vintf_MONITOR);
        this.ahbgpio_vintf = ahbgpio_vintf;
        gen2driv = new();
        gen = new(gen2driv, dir0_pkts, dir1_pkts, random_pkts);
        driv = new(ahbgpio_vintf_DRIVER, gen2driv, dir0_pkts, dir1_pkts, random_pkts); 
        mon2scb = new();
        mon = new(ahbgpio_vintf_MONITOR, mon2scb, dir0_pkts + dir1_pkts + random_pkts);
        scb = new(ahbgpio_vintf_MONITOR, mon2scb, dir0_pkts + dir1_pkts + random_pkts);
    endfunction

    task init();
        driv.reset();
    endtask 

    task test();
        fork 
        // Thread 1
        begin
            gen.main();
            driv.main();    
        end
        // Thread 2
        mon.main();
        scb.main();
        join_any
    endtask

    task post_test();
        scb.displayErrors();
        mon.displayCoverage();
    endtask

    task run_test();
        $display("[Environment] Starting at T = %0t", $time);
        init();
        test();
        $display("[Environment] gen.no_packets = %0d", gen.pkt_count);
        $display("[Environment] driv.pkt_count = %0d", driv.pkt_count);
        post_test();
        $stop;
    endtask
endclass