//////////////////////////////////////////////////////////////////////////////////
//END USER LICENCE AGREEMENT                                                    //
//                                                                              //
//Copyright (c) 2012, ARM All rights reserved.                                  //
//                                                                              //
//THIS END USER LICENCE AGREEMENT (�LICENCE�) IS A LEGAL AGREEMENT BETWEEN      //
//YOU AND ARM LIMITED ("ARM") FOR THE USE OF THE SOFTWARE EXAMPLE ACCOMPANYING  //
//THIS LICENCE. ARM IS ONLY WILLING TO LICENSE THE SOFTWARE EXAMPLE TO YOU ON   //
//CONDITION THAT YOU ACCEPT ALL OF THE TERMS IN THIS LICENCE. BY INSTALLING OR  //
//OTHERWISE USING OR COPYING THE SOFTWARE EXAMPLE YOU INDICATE THAT YOU AGREE   //
//TO BE BOUND BY ALL OF THE TERMS OF THIS LICENCE. IF YOU DO NOT AGREE TO THE   //
//TERMS OF THIS LICENCE, ARM IS UNWILLING TO LICENSE THE SOFTWARE EXAMPLE TO    //
//YOU AND YOU MAY NOT INSTALL, USE OR COPY THE SOFTWARE EXAMPLE.                //
//                                                                              //
//ARM hereby grants to you, subject to the terms and conditions of this Licence,//
//a non-exclusive, worldwide, non-transferable, copyright licence only to       //
//redistribute and use in source and binary forms, with or without modification,//
//for academic purposes provided the following conditions are met:              //
//a) Redistributions of source code must retain the above copyright notice, this//
//list of conditions and the following disclaimer.                              //
//b) Redistributions in binary form must reproduce the above copyright notice,  //
//this list of conditions and the following disclaimer in the documentation     //
//and/or other materials provided with the distribution.                        //
//                                                                              //
//THIS SOFTWARE EXAMPLE IS PROVIDED BY THE COPYRIGHT HOLDER "AS IS" AND ARM     //
//EXPRESSLY DISCLAIMS ANY AND ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING     //
//WITHOUT LIMITATION WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR //
//PURPOSE, WITH RESPECT TO THIS SOFTWARE EXAMPLE. IN NO EVENT SHALL ARM BE LIABLE/
//FOR ANY DIRECT, INDIRECT, INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES OF ANY/
//KIND WHATSOEVER WITH RESPECT TO THE SOFTWARE EXAMPLE. ARM SHALL NOT BE LIABLE //
//FOR ANY CLAIMS, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, //
//TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE    //
//EXAMPLE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE EXAMPLE. FOR THE AVOIDANCE/
// OF DOUBT, NO PATENT LICENSES ARE BEING LICENSED UNDER THIS LICENSE AGREEMENT.//
//////////////////////////////////////////////////////////////////////////////////


module AHBGPIO(
  input wire HCLK,
  input wire HRESETn,
  input wire [31:0] HADDR,
  input wire [1:0] HTRANS,
  input wire [31:0] HWDATA,
  input wire HWRITE,
  input wire HSEL,
  input wire HREADY,
  input wire [16:0] GPIOIN,                   // MSB is PARITY
  input wire PARITYSEL,                       //If PARITYSEL = 1, Odd parity; If PARITYSEL = 0, Even parity
  
	
	//Output
  output wire HREADYOUT,
  output wire [31:0] HRDATA,
  output wire [16:0] GPIOOUT,                 // MSB is PARITY
  output wire PARITYERR
  
  );
  
  localparam [7:0] gpio_data_addr = 8'h00;
  localparam [7:0] gpio_dir_addr = 8'h04;

  reg [16:0] gpio_dataout;                    // MSB is PARITY
  reg [16:0] gpio_datain;                     // MSB is PARITY
  reg [15:0] gpio_dir;
  reg [15:0] gpio_data_next;
  reg [31:0] last_HADDR;
  reg [1:0] last_HTRANS;
  reg last_HWRITE;
  reg last_HSEL;

  integer i;
  
  assign HREADYOUT = 1'b1;
  
// Set Registers from address phase  
  always @(posedge HCLK)
  begin
    if(HREADY)
    begin
      last_HADDR <= HADDR;
      last_HTRANS <= HTRANS;
      last_HWRITE <= HWRITE;
      last_HSEL <= HSEL;
    end
  end

  // Update in/out switch
  always @(posedge HCLK, negedge HRESETn)
  begin
    if(!HRESETn)
    begin
      gpio_dir <= 16'h0000;
    end
    else if ((last_HADDR[7:0] == gpio_dir_addr) & last_HSEL & last_HWRITE & last_HTRANS[1])
      gpio_dir <= HWDATA[15:0];
  end
  
  // Update output value
  always @(posedge HCLK, negedge HRESETn)
  begin
    if(!HRESETn)
    begin
      gpio_dataout <= 16'h0000;
    end
    else if ((gpio_dir == 16'h0001) & (last_HADDR[7:0] == gpio_data_addr) & last_HSEL & last_HWRITE & last_HTRANS[1])
    begin
      gpio_dataout[15:0] <= HWDATA[15:0];
      gpio_dataout[16]   <= (^HWDATA[15:0])^PARITYSEL;    // Parity bit  
    end  
  end
  
  // Update input value
  always @(posedge HCLK, negedge HRESETn)
  begin
    if(!HRESETn)
    begin
      gpio_datain <= 16'h0000;
    end
    else if (gpio_dir == 16'h0000)
    begin
      gpio_datain[15:0] <= GPIOIN[15:0];
      gpio_datain[16] <= (^GPIOIN[16])^PARITYSEL;
    end
    else if (gpio_dir == 16'h0001)
    begin
      gpio_datain[15:0] <= GPIOOUT[15:0];
      gpio_datain[16] <= (^GPIOIN[16])^PARITYSEL;
    end
  end
         
  assign HRDATA[15:0] = gpio_datain[15:0];  
  assign PARITYERR = gpio_datain[16];
  assign GPIOOUT = gpio_dataout;

  
   // Possible Assertions
   //---------------------------------------------------------------------------------

  logic [15:0] gpio_datain_last;
  logic [15:0] gpio_dataout_last;

  always @(posedge HCLK, negedge HRESETn)
  begin 
    gpio_datain_last <= gpio_datain;
    gpio_dataout_last <= gpio_dataout; 
  end

  // Check that gpio registers do not change if the direction register is a fail
   check_datain: assert property(
                                 @(posedge HCLK) disable iff(!HRESETn)
                                  !(gpio_dir == 16'h0000 | gpio_dir == 16'h0001) |-> (gpio_datain_last == gpio_datain)
                                 );
                            
   check_dataout: assert property(
                                 @(posedge HCLK) disable iff(!HRESETn)
                                  !(gpio_dir == 16'h0000 | gpio_dir == 16'h0001) |-> (gpio_dataout_last == gpio_dataout)
                                 );

endmodule
