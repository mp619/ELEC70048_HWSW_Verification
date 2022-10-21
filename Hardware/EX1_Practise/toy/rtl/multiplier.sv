module multiplier
  #(parameter WIDTH = 5)
   (
    input  logic                clk,
    input  logic                rst_n,
    input  logic                req,
    output logic                rdy,
    input  logic [WIDTH-1:0]    a,
    input  logic [WIDTH-1:0]    b,
    output logic                done,
    output logic [2*WIDTH-1:0]  ab
    );

   logic                        busy;
   logic [WIDTH-1:0]            op0, op1;
   logic [2*WIDTH-1:0]          acc;
   logic                        start;
   
   assign start = req & rdy;
   assign rdy   = ~busy;
   assign done  = busy & (op0 == '0);

   always @(posedge clk or negedge rst_n)
     if (!rst_n)
       busy <= 1'b0;
     else if (start)
       busy <= 1'b1;
     else if (done)
       busy <= 1'b0;

   assign inject_bug = (acc == 126);
   
   always @(posedge clk)
     if (start) begin
        op0 <= a;
        op1 <= b;
        acc <= '0;
     end else if (busy) begin
        op0 <= op0 - 1'b1;
        acc <= acc + op1 /* + inject_bug */;
     end

   assign ab = acc;

   // Check behaviour
   //-----------------------------------------------------------------------------------------

   logic [2*WIDTH-1:0] ab_chk;
   
   always @(posedge clk)
     if (start)
       ab_chk <= a * b;

   // Verification property   
   check_result: assert property(
                                 @(posedge clk) disable iff(!rst_n)
                                 done |-> (ab == ab_chk)
                                 );

   // Designer bring-up cover
   cover_interesting_value: cover property(
                                           @(posedge clk) disable iff (!rst_n)
                                           done && ab == 'd35
                                           );
  
endmodule // multiplier
