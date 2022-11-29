interface AHBVGA_intf
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

    // DUT outputs
    logic           HREADYOUT;
    logic [31:0]    HRDATA;
    logic           HSYNC;
    logic           VSYNC;
    logic [7:0]     RGB;
    logic           DLS_ERROR;

    clocking cb_DRIVER @(posedge clk);
        output  HADDR;
        output  HTRANS;
        output  HWDATA;
        output  HWRITE;
        output  HSEL;
        output  HREADY;

        input   HREADYOUT;
        input   HRDATA;
        input   HSYNC;
        input   VSYNC;
        input   RGB; 
        input   DLS_ERROR;             
    endclocking    

    clocking cb_MONITOR @(posedge clk);
        input   HADDR;
        input   HTRANS;
        input   HWDATA;
        input   HWRITE;
        input   HSEL;
        input   HREADY;

        input   HREADYOUT;
        input   HRDATA;
        input   HSYNC;
        input   VSYNC;
        input   RGB;
        input   DLS_ERROR;            
    endclocking

    modport DRIVER
    (
        input clk,
        input rst_n,
        clocking cb_DRIVER
    );

    modport MONITOR
    (
        input clk,
        input rst_n,
        clocking cb_MONITOR
    );

endinterface
