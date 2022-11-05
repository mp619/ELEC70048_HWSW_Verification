module multiplier_tb 
  #(parameter WIDTH = 5)
    (
    input  logic                  clk,
    output  logic                 rst_n,
    output  logic                 req,
    input logic                   rdy,
    output  logic [WIDTH-1:0]     a,
    output  logic [WIDTH-1:0]     b,
    input logic                   done,
    input logic [2*WIDTH-1:0]     ab        
    );

  initial begin
    rst_n = 0;
    #100 rst_n = 1;
    @(posedge clk);
      req = 1;
    @(posedge clk);
      if (req == 1)
        $display("rdy is high");
        $finish;
  end
endmodule