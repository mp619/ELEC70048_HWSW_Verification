// Multiplier test-bench top-level

// Declare interface

interface mult_if  
   #(parameter WIDTH = 5) 
       (input bit clk);

        logic req, rdy, done, rst_n;
 	logic [WIDTH-1:0]	a, b;
	logic [2*WIDTH-1:0]  	ab;

// Declare clocking block

clocking cb @(posedge clk);
    input rdy;
    output req;
endclocking

// Define modports for TEST (the testbench) and DUT (the multiplier)

   modport TEST (input a,b, output rst_n, ab, done,
                 clocking cb);
   modport DUT (input clk, rst_n, a, b, req,
                output ab, rdy, done);                ;
endinterface
  

module multiplier_top
 #(parameter WIDTH = 5);
    bit                     clk;

    initial begin                 // Create a free-running clock
       clk = 0;
       forever #100 clk = ! clk;
    end


  mult_if multif(clk);           // Interface with clocking block
  multiplier mul1 (multif);
  multiplier_tb mul1_tb (multif);

endmodule

