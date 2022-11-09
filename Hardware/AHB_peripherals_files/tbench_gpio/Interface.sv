interface AHBGPIO_intf
    (
        input logic clk,
        input logic rst_n
    );

    // Set Wires

    // DUT inputs
    logic [31:0]    HADDR;
    logic [1:0]     HTRANS;
    logic [31:0]    HWDATA;
    logic           HWRITE;
    logic           HSEL;
    logic           HREADY;
    logic [15:0]    GPIOIN; 

    // DUT outputs
    logic           HREADYOUT;
    logic [31:0]    HRDATA;
    logic [15:0]    GPIOOUT;

    clocking cb_DRIVER @(posedge clk);
        output  HADDR;
        output  HTRANS;
        output  HWDATA;
        output  HWRITE;
        output  HSEL;
        output  HREADY;
        output  GPIOIN;

        input   HREADYOUT;
        input   HRDATA;
        input   GPIOOUT;              
    endclocking    

    clocking cb_MONITOR @(posedge clk);
        input   HADDR;
        input   HTRANS;
        input   HWDATA;
        input   HWRITE;
        input   HSEL;
        input   HREADY;
        input   GPIOIN;

        input   HREADYOUT;
        input   HRDATA;
        input   GPIOOUT;              
    endclocking

    modport DRIVER
    (
        input clk,
        rst_n,
        clocking cb_DRIVER
    );

    modport MONITOR
    (
        input clk,
        rst_n,
        clocking cb_MONITOR
    );


endinterface
