// Used to monitor interface and send data to scoreboard
`define monitor_vintf ahbvga_mon_vintf.cb_MONITOR
`include "Driver.sv"
class Monitor; 
    virtual AHBVGA_intf ahbvga_mon_vintf;
    mailbox mon2scb;   // Monitor to scoreboard
    int no_packets;

    // Packet count
    int pkt_count = 0;

    // last HSYNC and VSYNC
    logic last_HSYNC = 0;
    logic last_VSYNC = 0;

    // Frame_count
    int frame_count = 0;

    //Pixel_count
    logic pixel_div = 1;

    // File descriptor
    int fd; 
        


    function new (virtual AHBVGA_intf ahbvga_mon_vintf, mailbox mon2scb, int no_packets);
        this.ahbvga_mon_vintf = ahbvga_mon_vintf;
        this.mon2scb = mon2scb;
        this.no_packets = no_packets;
    endfunction

    task print();
        if (last_VSYNC && !`monitor_vintf.VSYNC) 
        begin
            $display("[Monitor] New Frame no. %0d at T = %0t", frame_count+1, $time);
            $fdisplay(fd ,"New Frame no. %0d at T = %0t", frame_count+1, $time);
            frame_count++;
        end
        if (last_HSYNC && !`monitor_vintf.HSYNC)    // New line
        begin 
            $fwrite(fd ,"\n");
        end
        if(pixel_div)                               // Divide pixel print by 2, print only first pixel
        begin
            if (`monitor_vintf.RGB == 8'h1C)
                $fwrite(fd ,"#");
            else if (`monitor_vintf.RGB == 0)
                $fwrite(fd ," "); 
            else 
                $fwrite(fd ,"X"); 
        end
        pixel_div = ~pixel_div;
        last_HSYNC = `monitor_vintf.HSYNC;
        last_VSYNC = `monitor_vintf.VSYNC;
    endtask


    task main();    
        $display("[Monitor] Starting at T = %0t", $time);
        fd = $fopen("./vga_out.txt", "w");
        forever begin
            Transaction tr;
            tr = new();
            @(posedge ahbvga_mon_vintf.clk);                                           //Miss out address phase
            //$display("[Monitor] Sampling output No. %0d, T = %0t", pkt_count+1, $time);
            tr.HADDR     = `monitor_vintf.HADDR;
            tr.HTRANS    = `monitor_vintf.HTRANS;
            tr.HSEL      = `monitor_vintf.HSEL;
            tr.HWDATA    = `monitor_vintf.HWDATA;
            tr.HWRITE    = `monitor_vintf.HWRITE;
            tr.HREADY    = `monitor_vintf.HREADY;

            tr.HREADYOUT = `monitor_vintf.HREADYOUT;
            tr.HRDATA    = `monitor_vintf.HRDATA;
            tr.HSYNC     = `monitor_vintf.HSYNC;
            tr.VSYNC     = `monitor_vintf.VSYNC;
            tr.RGB       = `monitor_vintf.RGB;

            print();

            mon2scb.put(tr); 
            pkt_count++;          
        end
    endtask
endclass