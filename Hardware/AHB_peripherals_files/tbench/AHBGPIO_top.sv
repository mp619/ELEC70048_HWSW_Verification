// AHBGPIO Top level

module AHBGPIO_top;

    logic clk;
    logic rst_n;

    
    initial begin
        clk = 0;
        forever #5 clk = !clk;
    end

    initial begin
        rst_n = 0;              //Assert reset
        #30 rst_n = 1;           //De-assert reset
    end 

    AHB_GPIO_INF ahbgpioif( .clk (clk),
                            .rst_n (rst_n));
    
endmodule