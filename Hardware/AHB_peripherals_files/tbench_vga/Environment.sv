//`include "Transaction.sv"
//`include "Generator.sv"
//`include "Monitor.sv"
`include "Scoreboard.sv"
class environment;
    virtual AHBVGA_intf ahbvga_vintf;

    Generator gen;
    Driver driv;
    Monitor mon;
    Scoreboard scb;

    mailbox gen2driv;
    mailbox mon2scb;

    int no_packets = 898;

    function new(virtual AHBVGA_intf ahbvga_vintf_DRIVER, virtual AHBVGA_intf ahbvga_vintf_MONITOR);
        this.ahbvga_vintf = ahbvga_vintf_MONITOR;
        gen2driv = new();
        gen = new(gen2driv, no_packets);
        driv = new(ahbvga_vintf_DRIVER, gen2driv, no_packets); 
        mon2scb = new();
        mon = new(ahbvga_vintf_MONITOR, mon2scb, no_packets);
        scb = new(ahbvga_vintf_MONITOR, mon2scb);
    endfunction

    task init();
        driv.reset();
    endtask 

    task endframe();
        mon.oneframe();
        scb.displayErrors();
        mon.displayCoverage();
    endtask

    task test();
        fork
        begin
            gen.main();
            //driv.test();
            driv.main();
        end
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
        //waitframe();
        test();
        $display("[Environment] Exporting vga_out.txt at T = %0t", $time);

        // test();
        endframe();
        $stop;
    endtask
endclass