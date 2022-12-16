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

    // Console Area
    logic console_area;
    int y_max = 480;
    int x_max = 240; 

    // Cell Numbering
    int cell_no = 0;
    int cell_width = 8;
    int cell_height = 16;

    // Frame_count
    int frame_count = 0;

    //Pixel_count
    logic pixel_div = 0;
    int x = 0;
    int y = 0;

    // File descriptor
    int fd; 

    covergroup cg_inputs;
        cp_hwdata   : coverpoint `monitor_vintf.HWDATA[7:0] {
                        bins zero   = {0};
                        bins lo     = {[1:42]};
                        bins med    = {[43:84]};
                        bins hi     = {[85:126]};
                        bins max    = {8'h7f};
                        bins misc   = default;
        }        
    endgroup

    function new (virtual AHBVGA_intf ahbvga_mon_vintf, mailbox mon2scb, int no_packets);
        this.ahbvga_mon_vintf = ahbvga_mon_vintf;
        this.mon2scb = mon2scb;
        this.no_packets = no_packets;
        cg_inputs = new();
    endfunction

    task oneframe();
        @(negedge `monitor_vintf.VSYNC);
        frame_count++;
        $display("[Time = %0t][Monitor] End of frame no. %0d", $time, frame_count);
    endtask

    function void coordinates();
        pixel_div = ~pixel_div;
        if (last_VSYNC && !`monitor_vintf.VSYNC) 
        begin
            frame_count++;
            $display("[Time = %0t][Monitor] End of frame no. %0d", $time, frame_count);
            x = 0;  // Reset Count
            y = 0;  // Reset Count
        end
        if (last_HSYNC && !`monitor_vintf.HSYNC)    // New line
        begin 
            y++;    //Increment y
            x = 0;  //Restart x
            $fwrite(fd ,"\n");
        end
        if(pixel_div)
        begin
            x++;
        end
        last_HSYNC = `monitor_vintf.HSYNC;
        last_VSYNC = `monitor_vintf.VSYNC;
    endfunction

    function void FindConsoleArea();
        if (((y-35) >= 0) && ((y-35) < y_max) && ((x-147) >= 0) && ((x-147) < 240))
            console_area = 1;
        else
            console_area = 0;
    endfunction

    function void FindCharacterNo();
        int row_no;
        int col_no;

        row_no = $floor((x-147)/cell_width);
        col_no = $floor((y-35)/cell_height);  

        cell_no = row_no + 30*(col_no);
    endfunction

    function void print();
        if (x == 0 && y == 0)
        begin
            $display("[Monitor] New Frame no. %0d at T = %0t", frame_count+1, $time);
            $fdisplay(fd ,"New Frame no. %0d at T = %0t", frame_count+1, $time);            
        end
        if(pixel_div)                               // Divide pixel print by 2, print only first pixel
        begin
            if ((!((y-35)%16) && !((x-147)%8)) && console_area)
                $fwrite(fd ,"%0d", cell_no);
            else if (`monitor_vintf.RGB == 8'h1C)
                $fwrite(fd ,"#");
            else if (`monitor_vintf.RGB == 0)
                $fwrite(fd ," "); 
            else 
                $fwrite(fd ,"X"); 
        end
    endfunction

    function void displayCoverage();
        $display("-------------------[Time = %0t][TestBench][Coverage]-------------------------", $time);
        $display("HWDATA Coverage = %f %%", cg_inputs.cp_hwdata.get_inst_coverage());
        $display("-----------------------------------------------------------------------------");
    endfunction

    task main();    
        $display("[Monitor] Starting at T = %0t", $time);
        fd = $fopen($sformatf("./outputs/vga_out.txt"),"w");
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
            tr.DLS_ERROR = `monitor_vintf.DLS_ERROR;
            tr.inject_bug= `monitor_vintf.inject_bug;

            coordinates();
            FindConsoleArea();
            FindCharacterNo();
            print();
            
            cg_inputs.sample();
            mon2scb.put(tr); 
            pkt_count++;          
        end
    endtask
endclass