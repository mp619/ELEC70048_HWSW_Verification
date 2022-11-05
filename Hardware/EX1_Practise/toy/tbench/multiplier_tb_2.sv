module multiplier_tb_2 
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

  logic [2*WIDTH-1:0] ab_chk; 
  integer i;
  integer j;

  //class scoreboard;
  //  unsigned num_success;
  //  unsigned num_fail;
  //endclass

  initial begin
    // Initialize outputs
    rst_n = 0;
    req = 0;
    a = 0;
    b = 0;
    //scoreboard.num_success = 0;
    //scoreboard.num_fail = 0;

    @(posedge clk);
    rst_n = 1;

    // Test all possible combinations
    for (i = 0; i <= 31; i++) begin
      for (j = 0; j <= 31; j++) begin
        wait(rdy);
        a = i;
        b = j;

        @(posedge clk);
        req = 1;
        ab_chk = a*b;
        @(posedge clk);
        req = 0;

        wait(done);
        assert(ab == ab_chk) $display ("Success! %d * %d = %d", a, b, ab_chk);
          else $error ("FAIL! %d * %d =/ %d", a, b, ab_chk);
      end
    end

    $stop;
    
  end
endmodule