// Used to monitor interface and send data to scoreboard
`define monitor_vintf ahbgpio_mon_vintf.cb_MONITOR
`include "Driver.sv"
class Monitor; 
    virtual AHBGPIO_intf ahbgpio_mon_vintf;
    mailbox mon2scb;   // Monitor to scoreboard
    int no_packets;

    // Packet count
    int pkt_count = 0;

    function new (virtual AHBGPIO_intf ahbgpio_mon_vintf, mailbox mon2scb, int no_packets);
        this.ahbgpio_mon_vintf = ahbgpio_mon_vintf;
        this.mon2scb = mon2scb;
        this.no_packets = no_packets;
    endfunction

    task main();
        forever begin
            Transaction tr;
            tr = new();
            @(posedge ahbgpio_mon_vintf.clk);                                           //Miss out address phase
            $display("[Monitor] Sampling output No. %0d, T = %0t", pkt_count+1, $time);
            tr.HADDR     = `monitor_vintf.HADDR;
            tr.HTRANS    = `monitor_vintf.HTRANS;
            tr.HSEL      = `monitor_vintf.HSEL;
            tr.HWDATA    = `monitor_vintf.HWDATA;
            tr.GPIOIN    = `monitor_vintf.GPIOIN;
            tr.HWRITE    = `monitor_vintf.HWRITE;
            tr.HREADY    = `monitor_vintf.HREADY;
            tr.PARITYSEL = `monitor_vintf.PARITYSEL;

            tr.HREADYOUT = `monitor_vintf.HREADYOUT;
            tr.HRDATA    = `monitor_vintf.HRDATA;
            tr.GPIOOUT   = `monitor_vintf.GPIOOUT;
            tr.PARITYERR = `monitor_vintf.PARITYERR;
            tr.GPIODIR   = `monitor_vintf.GPIODIR;

            mon2scb.put(tr); 
            pkt_count++;          
        end
    endtask
endclass