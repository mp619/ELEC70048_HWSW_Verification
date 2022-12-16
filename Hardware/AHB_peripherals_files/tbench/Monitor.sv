`define monitor_vintf ahbvga_mon_vintf.cb_MONITOR
`include "Transaction.sv"
class Monitor; 
    virtual AHBVGA_intf ahbvga_mon_vintf;

    // Packet count
    int pkt_count = 0;

    // last HSYNC and VSYNC
    logic last_HSYNC;
    logic last_VSYNC;

    // Frame_count
    int frame_count = 0;

    //Pixel_count
    logic [1:0] pixel_div;

    // File descriptor
    int fd; 



    function new (virtual AHBVGA_intf ahbvga_mon_vintf);
        this.ahbvga_mon_vintf = ahbvga_mon_vintf;
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
        if(!pixel_div)                               // Divide pixel print by 4, print only first pixel
        begin
            if (`monitor_vintf.RGB == 8'h1C)
                $fwrite(fd ,"#");
            else if (`monitor_vintf.RGB == 0)
                $fwrite(fd ," "); 
            else 
                $fwrite(fd ,"X"); 
        end
        pixel_div++;
        last_HSYNC = `monitor_vintf.HSYNC;
        last_VSYNC = `monitor_vintf.VSYNC;
    endtask


    task main();    
        $display("[Monitor] Starting at T = %0t", $time);
        fd = $fopen($sformatf("./outputs/vga_out_top.txt"),"w");
        last_HSYNC = 0;
        last_VSYNC = 0;
        pixel_div = 0;
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

            //mon2scb.put(tr); 
            //pkt_count++;          
        end
    endtask
endclass