`define driver_vintf ahbgpio_driv_vintf.cb_DRIVER
`include "Generator.sv"
// Class to drive signals into interface
class Driver;   
    // Virtual interface
    virtual AHBGPIO_intf ahbgpio_driv_vintf;

    // Mailbox handle
    mailbox gen2driv;

    // Number of Packets
    int pkt_count = 0;

    // Packet count
    int dir0_pkts;
    int dir1_pkts;
    int random_pkts;

    function new(virtual AHBGPIO_intf ahbgpio_driv_vintf, mailbox gen2driv, int dir0_pkts, int dir1_pkts, int random_pkts);
        //get interface
        this.ahbgpio_driv_vintf = ahbgpio_driv_vintf;
        //get mailbox
        this.gen2driv = gen2driv;
        //get number of packets
        this.dir0_pkts = dir0_pkts;
        this.dir1_pkts = dir1_pkts;
        this.random_pkts = random_pkts;
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

    task ahb_data_phase(input logic [31:0]addr, input logic [31:0]data, input logic hwrite, input logic hsel, input logic hready, input logic [1:0] htrans, input logic paritysel);
        @(posedge ahbgpio_driv_vintf.clk)
        begin
            `driver_vintf.HADDR <= addr;                    // Give address
            `driver_vintf.HWDATA <= data;
            `driver_vintf.HWRITE <= hwrite;                 // Set read/write bit for now
            `driver_vintf.HSEL <= hsel;                     // Set HSEL bit for now
            `driver_vintf.HREADY <= hready;                 // Set HREADY bit for now
            `driver_vintf.HTRANS <= htrans;                 // Set HTRANS
            `driver_vintf.PARITYSEL <= paritysel;           // Set Parity
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

    // task test();        
    //     ahb_data_phase(16'h0000,0);               //Start with 0
    //     // ahb_data_phase(16'h0000,0);         //Start with 0
    //     // `driver_vintf.GPIOIN <= 5;  
    //     // ahb_data_phase(16'h0004,0);        //Get direction reg   
    //     // `driver_vintf.GPIOIN <= 4; 
    //     // `driver_vintf.HWDATA <= 7;
    //     // ahb_data_phase(16'h0000,1);         //Change to output
    //     // `driver_vintf.GPIOIN <= 3; 
    //     // ahb_data_phase(16'h0000,0);        //Read from output 
    //     // `driver_vintf.GPIOIN <= 2;          // !!!!!! Mistake in RTL, eaventhough set to read from output, system reads from input
    //     // `driver_vintf.HWDATA <= 8;
    //     // ahb_data_phase(16'h0000,0);         //Change to input
    //     // ahb_data_phase(16'h0000,6);         //
    //     ahb_data_phase(16'h0004,0);
    //     ahb_data_phase(16'h0004,1);
    //     ahb_data_phase(16'h0004,0);
    //     ahb_data_phase(16'h0004,1);
    //     ahb_data_phase(16'h0004,0);
    //     ahb_data_phase(16'h0004,1);
    //     ahb_data_phase(16'h0000,1);
    //     `driver_vintf.GPIOIN <= 15; 
    //     ahb_data_phase(16'h0000,3);
    //     ahb_data_phase(16'h0000,4);
    //     ahb_data_phase(16'h0000,5);
    //     ahb_data_phase(16'h0000,6);
    //     ahb_data_phase(16'h0000,7);
    //     ahb_data_phase(16'h0000,8);
    // endtask

    task Test1();   // Test direction = 0 only Read
        // Direction starts at 0
        repeat(dir0_pkts)
        begin
            Transaction tr;
            gen2driv.get(tr); 
            $display("[Driver] Packet No. %0d", pkt_count+1);
            `driver_vintf.GPIOIN <= tr.GPIOIN;       // Set GPIOIN
            ahb_data_phase(0, tr.HWDATA, tr.HWRITE, tr.HSEL, 1, 2, tr.PARITYSEL);
            pkt_count++;
            $display("[Driver] Packet Complete, T=%0t", $time);
        end
    endtask

    task Test2();   // Test direction = 1 Read/Write
        // Set Direction to 1
        ahb_data_phase(4, 32'h00000001, 1, 1, 1, 2, 0);
        ahb_data_phase(0, 32'h00000001, 1, 1, 1, 2, 0);    // Setting direction address to output
        repeat(dir1_pkts)
        begin
            Transaction tr;
            gen2driv.get(tr); 
            $display("[Driver] Packet No. %0d", pkt_count+1);
            `driver_vintf.GPIOIN <= tr.GPIOIN;       // Set GPIOIN
            ahb_data_phase(0, tr.HWDATA, tr.HWRITE, tr.HSEL, 1, 2, tr.PARITYSEL);
            pkt_count++;
            $display("[Driver] Packet Complete, T=%0t", $time);
        end
    endtask

    task Test3();   // Test random test cases
        repeat(random_pkts)
        begin
            Transaction tr;
            gen2driv.get(tr); 
            $display("[Time = %0t][Driver] Packet No. %0d", $time, pkt_count+1);
            `driver_vintf.GPIOIN <= tr.GPIOIN;       // Set GPIOIN
            ahb_data_phase(tr.HADDR, tr.HWDATA, tr.HWRITE, tr.HSEL, 1, 2, tr.PARITYSEL);
            pkt_count++;
            $display("[Time = %0t][Driver] Packet Complete", $time);
        end
    endtask

    task main();
        $display("[Driver] Starting at T=%0t", $time);                                        
        Test1();
        Test2();
        Test3();
    endtask
endclass : Driver