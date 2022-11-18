`define driver_vintf ahbgpio_driv_vintf.cb_DRIVER
`include "Generator.sv"
// Class to drive signals into interface
class Driver;   
    // Virtual interface
    virtual AHBGPIO_intf ahbgpio_driv_vintf;

    // Mailbox handle
    mailbox gen2driv;

    // Packet count
    int pkt_count = 0;

    function new(virtual AHBGPIO_intf ahbgpio_driv_vintf, mailbox gen2driv);
        //get interface
        this.ahbgpio_driv_vintf = ahbgpio_driv_vintf;
        //get mailbox
        this.gen2driv = gen2driv;
    endfunction

    task ahb_address_phase(input logic [31:0]addr, input logic [31:0]data);
        @(posedge ahbgpio_driv_vintf.clk)
        begin
            `driver_vintf.HADDR <= addr;       // Give address
            `driver_vintf.HWDATA <= data;      // Input data
            `driver_vintf.HWRITE <= 1;         // Set read/write bit for now
        end 
    endtask

    task ahb_data_phase(input logic [31:0]data);
        @(posedge ahbgpio_driv_vintf.clk)
        begin
            `driver_vintf.HWDATA <= data;
            `driver_vintf.HWRITE <= 0; // Set read/write bit for now
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

    task main();
        $display("[Driver] Starting at T=%0t", $time);
        forever begin 
            Transaction tr;
            gen2driv.get(tr);                                   // Get address phase random data
            $display("[Driver] Packet No. %0d", pkt_count+1);
            ahb_address_phase(tr.HADDR, tr.HWDATA);             // Proceed with address phase
            $display("[Driver] --Address Phase-- HADDR = %0h, HWDATA = %0h", tr.HADDR, tr.HWDATA);
            @(posedge ahbgpio_driv_vintf.clk);
            gen2driv.get(tr);                                   // Get data phase random data
            $display("[Driver] ----Data Phase--- HWDATA = %0h", tr.HWDATA);
            ahb_data_phase(tr.HWDATA);                          // Proceed with data phase
            repeat (2) begin 
                @(posedge ahbgpio_driv_vintf.clk);            // Wait to be able to read
            end
            $display("[Driver] Packet Complete");
            pkt_count++;
        end
    endtask
endclass : Driver