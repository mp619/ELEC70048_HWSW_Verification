// Multiplier Testbench

program automatic multiplier_tb
    #(parameter WIDTH = 5)  // Number of bits
    (multi_inf.TB multif);   // Instantiate the interface

    task init_reset();
    begin
        multif.rst_n = 0;   
        @(posedge multif.clk); 
        @(posedge multif.clk);     // Keep low for 2 clock cycles
        multif.rst_n = 1;   // Deassert reset
        @(posedge multif.clk); 
    end 
    endtask

    task initial_check();
    begin
        wait (multif.cb.rdy);       // Wait for ready signal
        multif.a = 7;
        multif.b = 8;
        multif.cb.req <= 1;         // Start multiplication

        wait (multif.done == 1);    // wait till done is high
        
        assert(multif.ab == 56) $display ("Initial check pass: Multiplier result = %0d, expected result is 56", multif.ab);
            else $error ("Initial check pass: Multiplier result = %0d, expected result is 56", multif.ab);

        multif.cb.req <= 0;         // Start multiplication
    end
    endtask

    initial begin
        init_reset();   //begin with reset asserted
        initial_check();    //Initial check
        $stop;
    end

endprogram     