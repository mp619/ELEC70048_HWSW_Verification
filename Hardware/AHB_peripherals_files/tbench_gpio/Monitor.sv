// Used to monitor interface and send data to scoreboard
`define monitor_vintf ahbgpio_mntr_vintf.cb_MONITOR
`include "Transaction.sv"
class Monitor; 
    virtual AHBGPIO_intf ahbgpio_mntr_vintf;
    mailbox mntr2scb;   // Monitor to scoreboard

    function new (virtual AHBGPIO_intf ahbgpio_mntr_vintf, mailbox mntr2scb);
        this.ahbgpio_mntr_vintf = ahbgpio_mntr_vintf;
        this.mntr2scb = mntr2scb;
    endfunction

    task main();
        forever begin 
            Transaction tr;
            tr = new();
            @(posedge ahbgpio_mntr_vintf.clk);
            tr.HADDR     = `monitor_vintf.HADDR;
            tr.HTRANS    = `monitor_vintf.HTRANS;
            tr.HSEL      = `monitor_vintf.HSEL;
            tr.HWDATA    = `monitor_vintf.HWDATA;
            tr.GPIOIN    = `monitor_vintf.GPIOIN;
            tr.HWRITE    = `monitor_vintf.HWRITE;
            tr.HREADY    = `monitor_vintf.HREADY;
            tr.PARITYSEL = `monitor_vintf.PARITYSEL;
        end
    endtask
endclass