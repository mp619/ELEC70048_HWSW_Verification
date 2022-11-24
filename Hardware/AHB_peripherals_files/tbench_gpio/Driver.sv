`define driver_vintf ahbgpio_driv_vintf.cb_DRIVER
`include "Generator.sv"
// Class to drive signals into interface
class Driver;   
    // Virtual interface
    virtual AHBGPIO_intf ahbgpio_driv_vintf;

    // Mailbox handle
    mailbox gen2driv;

    // Number of Packets
    int no_packets;

    // Packet count
    int pkt_count = 0;

    function new(virtual AHBGPIO_intf ahbgpio_driv_vintf, mailbox gen2driv, int no_packets);
        //get interface
        this.ahbgpio_driv_vintf = ahbgpio_driv_vintf;
        //get mailbox
        this.gen2driv = gen2driv;
        //get number of packets
        this.no_packets = no_packets;
    endfunction

    task ahb_address_phase(input logic [31:0]addr);
        @(posedge ahbgpio_driv_vintf.clk)
        begin
            `driver_vintf.HADDR <= addr;        // Input data
            `driver_vintf.HWRITE <= 1;          // Set read/write bit for now
            `driver_vintf.HSEL <= 1;            // Set HSEL bit for now
            `driver_vintf.HREADY <= 1;          // Set HREADY bit for now
            `driver_vintf.HTRANS <= 2;          //Set HTRANS
        end 
    endtask

    task ahb_data_phase(input logic [31:0]addr, input logic [31:0]data);
        @(posedge ahbgpio_driv_vintf.clk)
        begin
            `driver_vintf.HADDR <= addr;        // Give address
            `driver_vintf.HWDATA <= data;
            `driver_vintf.HWRITE <= 1; // Set read/write bit for now
            `driver_vintf.HSEL <= 1;          // Set HSEL bit for now
            `driver_vintf.HREADY <= 1;        // Set HREADY bit for now
            `driver_vintf.HTRANS <= 2;          //Set HTRANS
        end
    endtask

    task reset;
        wait(!ahbgpio_driv_vintf.rst_n);     // Wait while reset is asserted
        $display("[Driver] Reset Start");
        `driver_vintf.HADDR <= 0;
        `driver_vintf.HTRANS <= 0;
        `driver_vintf.HWDATA <= 0;
        `driver_vintf.HWRITE <= 0;
        `driver_vintf.HSEL <= 0;
        `driver_vintf.HREADY <= 0;
        `driver_vintf.GPIOIN <= 0;
        `driver_vintf.PARITYSEL <= 0;
        wait(ahbgpio_driv_vintf.rst_n);
        $display("[Driver] Reset End");
    endtask

    task test();        
        ahb_data_phase(16'h0000,0);               //Start with 0
        // ahb_data_phase(16'h0000,0);         //Start with 0
        // `driver_vintf.GPIOIN <= 5;  
        // ahb_data_phase(16'h0004,0);        //Get direction reg   
        // `driver_vintf.GPIOIN <= 4; 
        // `driver_vintf.HWDATA <= 7;
        // ahb_data_phase(16'h0000,1);         //Change to output
        // `driver_vintf.GPIOIN <= 3; 
        // ahb_data_phase(16'h0000,0);        //Read from output 
        // `driver_vintf.GPIOIN <= 2;          // !!!!!! Mistake in RTL, eaventhough set to read from output, system reads from input
        // `driver_vintf.HWDATA <= 8;
        // ahb_data_phase(16'h0000,0);         //Change to input
        // ahb_data_phase(16'h0000,6);         //
        ahb_data_phase(16'h0004,0);
        ahb_data_phase(16'h0004,1);
        ahb_data_phase(16'h0004,0);
        ahb_data_phase(16'h0004,1);
        ahb_data_phase(16'h0004,0);
        ahb_data_phase(16'h0004,1);
        ahb_data_phase(16'h0000,1);
        `driver_vintf.GPIOIN <= 15; 
        ahb_data_phase(16'h0000,3);
        ahb_data_phase(16'h0000,4);
        ahb_data_phase(16'h0000,5);
        ahb_data_phase(16'h0000,6);
        ahb_data_phase(16'h0000,7);
        ahb_data_phase(16'h0000,8);
    endtask


    task main();
        $display("[Driver] Starting at T=%0t", $time);
        repeat(no_packets) begin 
            Transaction tr;
            gen2driv.get(tr);                                               // Get address phase random data
            $display("[Driver] Packet No. %0d", pkt_count+1);
            ahb_address_phase(tr.HADDR);
            //$display("[Driver] --Address Phase-- HADDR = %0h, T=%0t", tr.HADDR, $time);
            gen2driv.get(tr);                                               // Get data phase random data
            //$display("[Driver] ----Data Phase--- HADDR = %0h, HWDATA = %0h, T=%0t", tr.HADDR, tr.HWDATA, $time);
            ahb_data_phase(tr.HADDR, tr.HWDATA);                            // Proceed with data phase
            $display("[Driver] Packet Complete, T=%0t", $time);
            //test();

            pkt_count++;
        end
    endtask
endclass : Driver