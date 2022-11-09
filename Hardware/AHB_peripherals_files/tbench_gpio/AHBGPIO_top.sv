// AHBGPIO Top level

module AHBGPIO_top;

    logic clk;
    logic rst_n;

// Clk and reset drivers    

    initial begin
        clk = 0;
        forever #5 clk = !clk;
    end

    initial begin
        rst_n = 0;              //Assert reset
        repeat (5) @(posedge clk) rst_n = 1;           //De-assert reset
    end 

    AHBGPIO_intf ahbgpio_intf(.clk(clk),
                              .rst_n(rst_n));
                              
    AHBGPIO ahbgpio1(.HCLK(clk),
                     .HRESETn(rst_n),
                     .HADDR(ahbgpio_intf.HADDR),
                     .HTRANS(ahbgpio_intf.HTRANS),
                     .HWDATA(ahbgpio_intf.HWDATA),
                     .HWRITE(ahbgpio_intf.HWRITE),
                     .HSEL(ahbgpio_intf.HSEL),
                     .HREADY(ahbgpio_intf.HREADY),
                     .GPIOIN(ahbgpio_intf.GPIOIN),
                     .HREADYOUT(ahbgpio_intf.HREADYOUT),
                     .HRDATA(ahbgpio_intf.HRDATA),
                     .GPIOOUT(ahbgpio_intf.GPIOOUT));

    AHBGPIO_tb ahbgpio_tb(ahbgpio_intf);
    
endmodule