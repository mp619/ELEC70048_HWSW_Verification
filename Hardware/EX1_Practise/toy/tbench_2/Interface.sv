interface multi_inf 
    #(parameter WIDTH = 5)
    (
        input logic clk
    );

    // Set Wires
    logic                 rst_n;    //Input
    logic                 req;      //Input
    logic                 rdy;      //Output
    logic [WIDTH-1:0]     a;        //Input
    logic [WIDTH-1:0]     b;        //Input
    logic                 done;     //Output
    logic [2*WIDTH-1:0]   ab;       //Output

    // Driver Clocking Block - Ensures that rdy and req signal only activate on a clock

    clocking cb @(posedge clk);
        input rdy;
        output req;
    endclocking 

    // Set modports
    modport TB  //Testbench mod port with forced clocked rdy and req signal
    (   
        input clk,
        input done,
        input ab,
        output rst_n,
        output a,
        output b,
        clocking cb
    );

    modport MULTI // Multiplier mod port - everything is already clocked
    (
        input clk,
        output rdy,
        output done,
        output ab,
        input rst_n,
        input req,
        input a,
        input b
    );

endinterface