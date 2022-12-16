`timescale 1ns/1ps
`include "Monitor.sv"
module ahblite_sys_tb(

);

logic RESET, CLK;
logic [7:0] SW;

logic [7:0] LED;
logic HSYNC;
logic VSYNC;
logic [2:0] VGAGREEN;

Monitor mon;


AHBVGA_intf ahbvga_intf(.clk(CLK), .rst_n(~RESET));

AHBLITE_SYS dut(.CLK(CLK),
                .RESET(RESET), 
                .LED(LED), 
                .HSYNC(ahbvga_intf.HSYNC), 
                .VSYNC(ahbvga_intf.VSYNC), 
                .VGARED(ahbvga_intf.RGB[7:5]), 
                .VGAGREEN(ahbvga_intf.RGB[4:2]), 
                .VGABLUE(ahbvga_intf.RGB[1:0]),
                .SW(SW));



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

initial 
begin
   SW = 8'h3A;
   mon = new(ahbvga_intf.MONITOR);
   mon.main();
end

// initial begin
//    RESET=1;
//    #30 RESET=0;
//    #20 RESET=1;
// end

   // initial begin
   //    CLK = 0;
   //    forever #5 CLK = !CLK;     // 
   // end

   // initial begin
   //    RESET = 1;   
   //    @(posedge CLK);              
   //    RESET = 0;                  //Assert reset
   //    repeat (10) begin 
   //       @(posedge CLK);
   //    end
   //    RESET = 1;                  //De-assert reset
   // end 

endmodule

