// AHBGPIO testbench

program automatic AHBGPIO_tb
    (AHBGPIO_intf.TB ahbgpio_intf);


    logic [31:0] gpio_data_addr = 32'h00000000;
    logic [31:0] gpio_dir_addr = 32'h00000004;
    logic [15:0] write_test_var = 16'h0055;
    logic [15:0] read_test_GPIOIN_var = 16'h0050;   
    logic [15:0] read_test_GPIOOUT_var = 16'h0045;
    logic data_check;
    logic parity_sel;
    logic parity_check;

    task ahb_address_phase(input logic [31:0]addr, input logic [31:0]data);
        @(posedge ahbgpio_intf.clk)
        begin
            ahbgpio_intf.cb_TB.HADDR <= addr;       // Give address
            ahbgpio_intf.cb_TB.HWDATA <= data;      // Input data
            ahbgpio_intf.cb_TB.HWRITE <= 1;        // Set read/write bit
        end 
    endtask

    task ahb_data_phase(input logic [31:0]data);
        @(posedge ahbgpio_intf.clk)
        begin
            ahbgpio_intf.cb_TB.HWDATA <= data;
            ahbgpio_intf.cb_TB.HWRITE <= 0;
        end
    endtask

    task write_test();
        parity_sel = 0;

        ahb_address_phase(gpio_dir_addr, 0);            // Set direction register
        ahb_address_phase(gpio_data_addr, 1);           // Set to GPIOOUT
        ahb_data_phase(write_test_var);                 // Input test variable
        ahbgpio_intf.cb_TB.PARITYSEL <= parity_sel;                  // For intial test, even parity
        repeat(2) @(posedge ahbgpio_intf.clk);          // Wait 2 cycles to read

        data_check = ahbgpio_intf.cb_TB.GPIOOUT[15:0] == write_test_var;    //Check data is correct
        parity_check = ahbgpio_intf.cb_TB.GPIOOUT[16] == (^write_test_var)^parity_sel;    //Check parity bit is correct
        assert(data_check && parity_check) 
            $display ("Initial write check pass: GPIO_OUT = %0d; PARITYBIT = %0d, expected result is %0d; %0d", ahbgpio_intf.cb_TB.GPIOOUT[15:0], ahbgpio_intf.cb_TB.GPIOOUT[16] , write_test_var, (^write_test_var)^ahbgpio_intf.cb_TB.PARITYSEL);
        else 
            $error ("Initial write check FAIL: GPIO_OUT = %0d; PARITYBIT = %0d, expected result is %0d; %0d", ahbgpio_intf.cb_TB.GPIOOUT[15:0], ahbgpio_intf.cb_TB.GPIOOUT[16] , write_test_var, (^write_test_var)^ahbgpio_intf.cb_TB.PARITYSEL);
    endtask

    task read_test_GPIOIN();
        parity_sel = 0;

        ahb_address_phase(gpio_dir_addr, 0);            // Set direction register
        ahb_address_phase(gpio_data_addr, 0);           // Set to GPIOIN
        ahbgpio_intf.cb_TB.PARITYSEL <= parity_sel;              // For intial test, even parity
        @(posedge ahbgpio_intf.clk);
        ahbgpio_intf.cb_TB.GPIOIN <= {(^read_test_GPIOIN_var)^~parity_sel, read_test_GPIOIN_var}; // Test variable to read with wrong parity
        repeat(2) @(posedge ahbgpio_intf.clk);          // Wait 2 cycles to read

        data_check = ahbgpio_intf.cb_TB.HRDATA[15:0] == read_test_GPIOIN_var[15:0];
        parity_check = ahbgpio_intf.cb_TB.PARITYERR;    // Parity error should be high
        assert(data_check && parity_check) $display ("Initial read GPIOIN check pass: HRDATA = %0d; PARITYERR = %0d, expected result is %0d; 1", ahbgpio_intf.cb_TB.HRDATA[15:0], ahbgpio_intf.cb_TB.PARITYERR, read_test_GPIOIN_var[15:0]);
            else $error ("Initial read GPIOIN check FAIL: HRDATA = %0d; PARITYERR = %0d, expected result is %0d; 1", ahbgpio_intf.cb_TB.HRDATA[15:0], ahbgpio_intf.cb_TB.PARITYERR, read_test_GPIOIN_var[15:0]);
    endtask

    task read_test_GPIOOUT();
        parity_sel = 0;
        // First one must write to GPIOOUT...
        ahb_address_phase(gpio_dir_addr, 0);            // Set direction register
        ahb_address_phase(gpio_data_addr, 1);           // Set to GPIOOUT
        ahb_data_phase(read_test_GPIOOUT_var);          // Input test variable
        ahbgpio_intf.cb_TB.PARITYSEL <= parity_sel;              // For intial test, even parity
        repeat(3) @(posedge ahbgpio_intf.clk);          // Wait 2 cycles to read

        data_check = ahbgpio_intf.cb_TB.HRDATA[15:0] == read_test_GPIOOUT_var;
        assert(data_check) $display ("Initial read GPIOOUT check pass: HRDATA = %0d, expected result is %0d", ahbgpio_intf.cb_TB.HRDATA[15:0], read_test_GPIOOUT_var);
            else $error ("Initial read GPIOOUT check FAIL: HRDATA = %0d, expected result is %0d", ahbgpio_intf.cb_TB.HRDATA[15:0], read_test_GPIOOUT_var);
    endtask 

    task setup();
        ahbgpio_intf.cb_TB.GPIOIN <= 32'h00000000;          // Set HRDATA to 0
        ahbgpio_intf.cb_TB.HREADY <= 1;                     // No wait times (Maybe test?)
        ahbgpio_intf.cb_TB.HTRANS <= 2'b10;                 // Trans = 2
        ahbgpio_intf.cb_TB.HSEL <= 1;                       // Select bit high
    endtask   

// Test bench
    initial 
    begin 
        wait(ahbgpio_intf.rst_n == 1);                      // Wait for reset to be over
        setup();

        write_test();
        read_test_GPIOIN();
        read_test_GPIOOUT();
        $stop;

    end

endprogram