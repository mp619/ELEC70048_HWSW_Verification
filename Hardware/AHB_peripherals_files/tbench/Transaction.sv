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
    logic               DLS_ERROR;

    // Bug injection
    rand logic  [4:0]   inject_bug;         

    constraint hwdata_special { HWDATA[5:0] != newline0;
                                HWDATA[5:0] != newline1;
                                HWDATA[5:0] != backspace;}

    constraint bug { inject_bug dist {5'b00000:/60, [0:31]:/40 };}

    function void display();
        $display("[Transaction] Outputs: HADDR, HTRANS, HWDATA, HWRITE, HSEL, HREADY, BUG");
        $display("[Transaction] Values: %0h, %0h, %0h, %0b, %0b, %0b, %0h", HADDR, HTRANS, HWDATA, HWRITE, HSEL, HREADY, inject_bug);
    endfunction

    function void reset();
        HADDR = 0;
        HTRANS = 0;
        HSEL = 0;
        HWDATA = 0;
        HWRITE = 0;
        HREADY = 0;
        
        inject_bug = 0;
    endfunction

    function void post_randomize();
        count++;
    endfunction

endclass: Transaction



