// Multiplier top level

module multiplier_top
    #(parameter WIDTH = 5);
        
        logic clk;

        initial begin
            clk = 0;                    // Initialize clk at logic = 0
            forever #100 clk = !clk;     // clk with a period of 200ns
        end

    multi_inf multif(clk);  // Give clock signal to interface
    multiplier mul1 (multif);   // Insantiate DUT
    multiplier_tb mul1_tb (multif);  // Instantiate TB

endmodule