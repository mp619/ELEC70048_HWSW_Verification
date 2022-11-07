interface AHB_GPIO_INF 
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
    logic           HRDATA;
    logic           GPIOOUT;

    clocking cb_TB @(posedge clk);
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

    clocking cb_DUT @(posedge clk);
        input   HADDR;
        input   HTRANS;
        input   HWDATA;
        input   HWRITE;
        input   HSEL;
        input   HREADY;
        input   GPIOIN;

        output  HREADYOUT;
        output  HRDATA;
        output  GPIOOUT;              
    endclocking

    modport TB
    (
        input clk,
        clocking cb_TB
    );

    modport DUT
    (
        input clk,
        clocking cb_DUT
    );


endinterface
