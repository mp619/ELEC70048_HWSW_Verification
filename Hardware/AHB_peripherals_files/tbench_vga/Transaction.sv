class Transaction;
    int count = 0;
    // Special Characters
    localparam [5:0] backspace  = 6'b001000;
    localparam [5:0] newline0   = 6'b001101;
    localparam [5:0] newline1   = 6'b001010;

    rand logic [31:0]    HADDR;
    rand logic [1:0]     HTRANS;
    rand logic [31:0]    HWDATA;
    rand logic           HWRITE;
    rand logic           HSEL;
    rand logic           HREADY;

    // DUT outputs
    logic               HREADYOUT;
    logic [31:0]        HRDATA;
    logic               HSYNC;
    logic               VSYNC;
    logic [7:0]         RGB;         

    constraint hwdata_special { HWDATA[5:0] != newline0;
                                HWDATA[5:0] != newline1;
                                HWDATA[5:0] != backspace;}

    function void display();
        $display("[Transaction] Outputs: HADDR, HTRANS, HWDATA, HWRITE, HSEL, HREADY");
        $display("[Transaction] Values: %0h, %0h, %0h, %0b, %0b, %0b", HADDR, HTRANS, HWDATA, HWRITE, HSEL, HREADY);
    endfunction

    function void reset();
        HADDR = 0;
        HTRANS = 0;
        HSEL = 0;
        HWDATA = 0;
        HWRITE = 0;
        HREADY = 0;
    endfunction

    function void post_randomize();
        count++;
    endfunction

endclass: Transaction



