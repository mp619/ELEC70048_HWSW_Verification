//
// Multiplier implemented as successive addition of one operand
//

module multiplier 
   #(parameter WIDTH = 5)     // Multiplier width in bits
   (mult_if.DUT multif);      // Instantiate the interface
    
   logic                        busy;
   logic [WIDTH-1:0]            op0, op1;
   logic [2*WIDTH-1:0]          acc;
   logic                        start;
   
   assign start        = multif.req & multif.rdy;
   assign multif.rdy   = ~busy;
   assign multif.done  = busy & (op0 == '0);

   always @(posedge multif.clk or negedge multif.rst_n)
     if (!multif.rst_n)
       busy <= 1'b0;
     else if (start)
       busy <= 1'b1;
     else if (multif.done)
       busy <= 1'b0;

   assign inject_bug = (acc == 126);  // Inject a bug to test the testbench
   
   always @(posedge multif.clk)
     if (start) begin
        op0 <= multif.a;
        op1 <= multif.b;
        acc <= '0;
     end else if (busy) begin
        op0 <= op0 - 1'b1;
        acc <= acc + op1 /* + inject_bug */;  // Uncomment to inject a bug
     end

   assign multif.ab = acc;

   // Check behaviour
   //-----------------------------------------------------------------------------------------

   logic [2*WIDTH-1:0] ab_chk;
   
   always @(posedge multif.clk)
     if (start)
       ab_chk <= multif.a * multif.b;

   // Verification property   
   check_result: assert property(
                                 @(posedge multif.clk) disable iff(!multif.rst_n)
                                 multif.done |-> (multif.ab == ab_chk)
                                 );

endmodule // multiplier
