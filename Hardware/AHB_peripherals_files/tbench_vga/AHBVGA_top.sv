// AHBVGA Top level

module AHBVGA_top;

    logic clk;
    logic rst_n;

// Clk and reset drivers    

    initial begin
        clk = 0;
        forever #5 clk = !clk;     // 25Mhz Clock 
    end

    initial begin
        rst_n = 1;                  
        @(posedge clk);
        rst_n = 0;                  //Assert reset
        repeat (5) begin 
            @(posedge clk);
        end
        rst_n = 1;                  //De-assert reset
    end 

    AHBVGA_intf ahbvga_intf(.clk(clk),
                              .rst_n(rst_n));
                              
    AHBVGADLS  ahbvga1( .HCLK(clk),
                     .HRESETn(rst_n),
                     .HADDR(ahbvga_intf.HADDR),
                     .HTRANS(ahbvga_intf.HTRANS),
                     .HWDATA(ahbvga_intf.HWDATA),
                     .HWRITE(ahbvga_intf.HWRITE),
                     .HSEL(ahbvga_intf.HSEL),
                     .HREADY(ahbvga_intf.HREADY),
                     .HREADYOUT(ahbvga_intf.HREADYOUT),
                     .HRDATA(ahbvga_intf.HRDATA),
                     .HSYNC(ahbvga_intf.HSYNC),
                     .VSYNC(ahbvga_intf.VSYNC),
                     .RGB(ahbvga_intf.RGB),
                     .DLS_ERROR(ahbvga_intf.DLS_ERROR));

    //AHBGPIO_tb ahbgpio_tb(ahbgpio_intf);
    AHBVGA_tb tb1(ahbvga_intf);

    // initial begin 
    //     $dumpfile("dump.vcd");
    //     $dumpvars;
    // end
    
endmodule