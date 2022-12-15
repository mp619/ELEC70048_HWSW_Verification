// Used to monitor interface and send data to scoreboard
`define monitor_vintf ahbgpio_mon_vintf.cb_MONITOR
`include "Driver.sv"

class Monitor; 
    virtual AHBGPIO_intf ahbgpio_mon_vintf;
    mailbox mon2scb;   // Monitor to scoreboard
    int no_packets;

    // Packet count
    int pkt_count = 0;

    covergroup cg_inputs;
        cp_haddr    : coverpoint `monitor_vintf.HADDR[15:0] {
                        bins data   = {16'h0000};
                        bins dir    = {16'h0004};
                        bins max    = {16'hFFFF};
                        bins misc   = default;
        }
        cp_hwdata   : coverpoint `monitor_vintf.HWDATA[15:0] {
                        bins dir0   = {16'h0000};
                        bins dir1   = {16'h0001};
                        bins max    = {16'hFFFF};
                        bins misc   = default;
        }
        cp_gpioin   : coverpoint `monitor_vintf.GPIOIN {
                        //bins even   = cp_gpioin with (item%2 == 0);
                        //bins odd    = cp_gpioin with (item%2 == 1);
                        bins min    = {16'h0000};
                        bins max    = {17'h1FFFF};
        }       
    endgroup

    covergroup cg_outputs;
        cp_dir      : coverpoint `monitor_vintf.GPIODIR {
                        bins dir0   = {16'h0000};
                        bins dir1   = {16'h0001};
                        bins misc   = default;
        }
    endgroup

    function new (virtual AHBGPIO_intf ahbgpio_mon_vintf, mailbox mon2scb, int no_packets);
        this.ahbgpio_mon_vintf = ahbgpio_mon_vintf;
        this.mon2scb = mon2scb;
        this.no_packets = no_packets;
        cg_inputs = new();
        cg_outputs = new();
    endfunction

    function void displayCoverage();
        $display("-------------------[Time = %0t][TestBench][Coverage]-------------------------", $time);
        $display("HADDR Coverage = %f %%", cg_inputs.cp_haddr.get_inst_coverage());
        $display("HWDATA Coverage = %f %%", cg_inputs.cp_hwdata.get_inst_coverage());
        $display("GPIOIN Coverage = %f %%", cg_inputs.cp_gpioin.get_inst_coverage());
        $display("Direction Coverage = %f %%", cg_outputs.cp_dir.get_inst_coverage());
        $display("-----------------------------------------------------------------------------");
    endfunction

    task main();
        forever begin
            Transaction tr;
            tr = new();
            @(posedge ahbgpio_mon_vintf.clk);                                           //Miss out address phase
            $display("[Time = %0t][Monitor] Sampling output No. %0d", $time, pkt_count);
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

            //tr.display(); 
            cg_inputs.sample();  
            cg_outputs.sample();    
            mon2scb.put(tr); 
            pkt_count++;          
        end
    endtask
endclass
