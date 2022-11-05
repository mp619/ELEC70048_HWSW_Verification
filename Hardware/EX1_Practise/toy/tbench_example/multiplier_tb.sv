// Multiplier testbench


program automatic multiplier_tb
  #(parameter WIDTH = 5)      // Multiplier width in bits
   (mult_if.TEST multif);     // Instantiate the interface

       
	parameter int maxa = (2**WIDTH) - 1;  // maximum value of operand a
        parameter int maxb = (2**WIDTH) - 1;  // maximum value of operand b

        integer   test_count;                 // Counter for number of operand pairs to test
 
      class Operand_values;                   // Declare a class to randomise the operand values
         rand logic [WIDTH-1:0]	i;
	 rand logic [WIDTH-1:0]	j;

         int count = 0;                      // Add constraints to force multiplication of max values every 100th test

	 constraint c_maxa {(count%100 == 0) -> i==maxa;}
         constraint c_maxb {(count%100 == 0) -> j==maxb;}

         function void post_randomize();
           count++;
         endfunction

      endclass

     Operand_values opvals;                   // Instantiate the class


      covergroup cover_a_values;              // Functional coverage point to check range of operand a values
         coverpoint multif.a {
           bins zero = {0};
           bins lo   = {[1:7]};
           bins med  = {[8:23]};
           bins hi   = {[24:30]};
           bins max  = {31};
       }
       endgroup

      covergroup cover_max_vals;              // Functional coverage point to check for multiplication of max values
          coverpoint  multif.ab {
           bins max = {maxa*maxb};
           bins misc = default;
          }
      endgroup

	task deassert_reset();
	begin
	   multif.rst_n = 0; // De-assert reset
	   @multif.cb;       // Keep it low for 2 clocks      
	   @multif.cb;
           multif.rst_n = 1;
	   @multif.cb;
	end
	endtask

	task initial_check();                         // Initial check of multiplier
	begin
	   wait (multif.cb.rdy);		      // Wait for multiplier to be idle
	   multif.a = 5;
 	   multif.b = 6;
	   multif.cb.req <= 1;		      // Initiate the multiplication
	   wait (multif.done == 1);           // And wait for it to finish
           assert (multif.ab == 30)
	     else $fatal ("Initial check of multiplier failed. Multiplier result = %0d, expected result is 30", multif.ab);
	   $display ("Initial check of multiplier passed. Multiplier result = %0d, expected result is 30", multif.ab);
           multif.cb.req <= 0;
	end
	endtask

        initial begin
          cover_a_values cova;              // Instantiate the functional coverage points
          cover_max_vals covmax;
          cova = new();
          covmax = new();
          opvals = new();                   // Allocate a random operand values object

	  deassert_reset();                 // Pulse reset low
	  initial_check();                  // Perform initial check of multiplier before starting random tests

          for (test_count = 0; test_count < 128;test_count++)
          begin
            @multif.cb;
            assert (opvals.randomize) else $fatal; // Randomise operand values
            multif.a=opvals.i;
            multif.b=opvals.j;
            cova.sample();                  // Collect coverage of operand a values
            multif.cb.req <= 1;             // Initiate the multiplication
            wait (multif.done == 1);        // Wait for multiplication to complete
            covmax.sample();                // Collect coverage of multiplication of maximum values
            multif.cb.req <= 0;
          end
        @multif.cb;
        $finish;
        end

endprogram

