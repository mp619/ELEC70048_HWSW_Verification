`timescale 1ns/1ps
module ahblite_sys_tb(

);

reg RESET, CLK;
wire [7:0] LED;

AHBLITE_SYS dut(.CLK(CLK), .RESET(RESET), .LED(LED));

// Note: you can modify this to give a 50MHz clock or whatever is appropriate

initial
begin
   CLK=0;
   forever
   begin
      #5 CLK=1;
      #5 CLK=0;
   end
end

initial
begin
   RESET=0;
   #30 RESET=1;
   #20 RESET=0;
end

endmodule

