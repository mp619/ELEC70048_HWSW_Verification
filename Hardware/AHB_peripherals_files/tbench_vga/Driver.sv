`define driver_vintf ahbvga_driv_vintf.cb_DRIVER
`include "Generator.sv"
// Class to drive signals into interface
class Driver;   
    // Virtual interface
    virtual AHBVGA_intf ahbvga_driv_vintf;

    // Mailbox handle
    mailbox gen2driv;

    // Number of Packets
    int no_packets;

    // Packet count
    int pkt_count = 0;

    int frame_count = 0;

    function new(virtual AHBVGA_intf ahbvga_driv_vintf, mailbox gen2driv, int no_packets);
        //get interface
        this.ahbvga_driv_vintf = ahbvga_driv_vintf;
        //get mailbox
        this.gen2driv = gen2driv;
        //get number of packets
        this.no_packets = no_packets;
    endfunction

    task ahb_address_phase(input logic [31:0]addr);
        @(posedge ahbvga_driv_vintf.clk)
        begin
            `driver_vintf.HADDR <= addr;        // Input data
            `driver_vintf.HWRITE <= 1;          // Set read/write bit for now
            `driver_vintf.HSEL <= 1;            // Set HSEL bit for now
            `driver_vintf.HREADY <= 1;          // Set HREADY bit for now
            `driver_vintf.HTRANS <= 2;          //Set HTRANS
        end 
    endtask

    task ahb_data_phase(input logic [31:0]addr, input logic [31:0]data);
        @(posedge ahbvga_driv_vintf.clk)
        begin
            `driver_vintf.HADDR <= addr;        // Give address
            `driver_vintf.HWDATA <= data;
            `driver_vintf.HWRITE <= 1; // Set read/write bit for now
            `driver_vintf.HSEL <= 1;          // Set HSEL bit for now
            `driver_vintf.HREADY <= 1;        // Set HREADY bit for now
            `driver_vintf.HTRANS <= 2;          //Set HTRANS
        end
    endtask

    task reset();
        wait(!ahbvga_driv_vintf.rst_n);     // Wait while reset is asserted
        $display("[Driver] Reset Start");
        `driver_vintf.HADDR <= 0;
        `driver_vintf.HTRANS <= 0;
        `driver_vintf.HWDATA <= 0;
        `driver_vintf.HWRITE <= 0;
        `driver_vintf.HSEL <= 0;
        `driver_vintf.HREADY <= 0;
        `driver_vintf.inject_bug <= 0;
        wait(ahbvga_driv_vintf.rst_n);
        $display("[Driver] Reset End");
    endtask

    task test();        
        ahb_data_phase(16'h0000,0);                 // Start with 0
        for(int j = 0; j < 1; j++)
        begin
        for(int i = 8'h31; i < 8'h5a; i++)
        begin 
            ahb_data_phase(16'h0000,i);            
        end
        end
        ahb_data_phase(16'h0000,0);                 //End with space 
        `driver_vintf.HWRITE <= 0;
    endtask

    task main();
        $display("[Driver] Starting at T=%0t", $time);
        ahb_data_phase(32'h00000000, 0); 
        repeat(no_packets) begin 
            Transaction tr;
            $display("[Driver] Packet No. %0d", pkt_count+1);
            gen2driv.get(tr);                                        // Get address phase random data
            ahb_data_phase(0, tr.HWDATA);                            // Proceed with data phase
            `driver_vintf.inject_bug <= tr.inject_bug;               // Inject Bug
            $display("[Driver] Packet Complete, T=%0t", $time);
            pkt_count++;
        end
        ahb_data_phase(16'h0000,0);                 //End with space
        `driver_vintf.HWRITE <= 0;
    endtask
endclass : Driver