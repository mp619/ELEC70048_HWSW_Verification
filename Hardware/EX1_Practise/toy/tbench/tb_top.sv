module tb_top;

  // Parameters
  parameter WIDTH = 5;

  // Wires                 
  logic                       clk;
  logic                       rst_n;
  logic                       req;
  logic                       rdy;
  logic [WIDTH-1:0]       a;
  logic [WIDTH-1:0]       b;
  logic                       done;
  logic [2*WIDTH-1:0]     ab; 

  // Modules

  tb_clk clock
  (
    .clk      (clk)
  );
  
  multiplier 
  #(.WIDTH (WIDTH)) multi 
    (
      .clk      (clk),
      .rst_n    (rst_n),
      .req      (req),
      .rdy      (rdy),
      .a        (a),
      .b        (b),
      .done     (done),
      .ab       (ab)
    );

  multiplier_tb_2
  #(.WIDTH (WIDTH)) multi_tb 
    (
      .clk      (clk),
      .rst_n    (rst_n),
      .req      (req),
      .rdy      (rdy),
      .a        (a),
      .b        (b),
      .done     (done),
      .ab       (ab)
    );

endmodule