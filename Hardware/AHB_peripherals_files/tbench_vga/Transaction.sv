class Transaction;
    int count = 0;

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

    //constraint addr_dist { HADDR dist {16'h0000:/42.5, 16'h0004:/42.5, [0:65535]:/15}; };

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



