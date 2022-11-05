// Multiplier Testbench

program automatic multiplier_tb
    #(parameter WIDTH = 5)  // Number of bits
    (multi_inf.TB multif);   // Instantiate the interface

    parameter int maxa = (2*WIDTH) - 1; // Max a
    parameter int maxb = (2*WIDTH) - 1; // Max b
    int test_count;                 // Keep record of number of tests

    class Operand_val; 
        rand logic [WIDTH-1:0] i;
        rand logic [WIDTH-1:0] j;
        int count = 0;

        constraint c_maxa {(count%100 == 0) -> i==maxa;}  // Every 100 ticks, test a max
        constraint c_maxb {(count%100 == 0) -> j==maxb;}  

        function void post_randomize();
            count++;
        endfunction
    endclass

    Operand_val opvals;                                     //Instantiate class for test range

    covergroup cover_a_values;                              // Functional coverage point for max vals
        coverpoint multif.a {
            bins zero = {0};
            bins lo   = {[1:7]};
            bins med  = {[8:23]};
            bins hi   = {[24:30]};
            bins max  = {31};
        }
    endgroup

    covergroup cover_max_vals;
        coverpoint multif.ab {
            bins max = {maxa*maxb};
            bins misc = default;
        }
    endgroup


    task init_reset();
    begin
        multif.rst_n = 0;   
        @(posedge multif.clk); 
        @(posedge multif.clk);                              // Keep low for 2 clock cycles
        multif.rst_n = 1;                                   // Deassert reset
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
        cover_a_values cova;        // Instantiate coverage for results
        cover_max_vals covmax;      // Instantiate converage for results
        cova = new();
        covmax = new();
        opvals = new();             //random operand values object


        init_reset();   //begin with reset asserted
        initial_check();    //Initial check
        
        for (test_count = 0; test_count < 128; test_count++)
        begin
            @(posedge multif.clk); 

            assert (opvals.randomize) else $fatal;
            multif.a = opvals.i;
            multif.b = opvals.j;                        // Randomize as inputs
            cova.sample();                              // Collect a coverage
            multif.cb.req <= 1;                         // Request calc

            wait (multif.done == 1);
            covmax.sample();
            multif.cb.req <= 0;
        end
        
        @(posedge multif.clk); 
        $stop;

    end

endprogram     