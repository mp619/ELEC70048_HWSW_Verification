class Transaction;
    int count = 0;

    rand logic [15:0]       HADDR;
    rand logic [1:0]        HTRANS;
    rand logic              HSEL;
    rand logic [15:0]       HWDATA;
    rand logic [16:0]       GPIOIN;
    rand logic              HWRITE;
    rand logic              HREADY;
    rand logic              PARITYSEL;

    logic                   HREADYOUT;
    logic [15:0]            HRDATA;
    logic [16:0]            GPIOOUT;
    logic                   PARITYERR;  
    logic [15:0]            GPIODIR;          

    constraint addr_dist { HADDR dist {16'h0000:/42.5, 16'h0004:/42.5, [0:65535]:/15}; };

    function void display();
        $display("[Transaction] Outputs: HADDR, HTRANS, HWDATA, HWRITE, HSEL, HREADY, GPIOIN, PARITYSEL");
        $display("[Transaction] Values: %0h, %0h, %0h, %0b, %0b, %0b, %0h, %0d", HADDR, HTRANS, HWDATA, HWRITE, HSEL, HREADY, GPIOIN, PARITYSEL);
    endfunction

    function void reset();
        HADDR = 0;
        HTRANS = 0;
        HSEL = 0;
        HWDATA = 0;
        GPIOIN = 0;
        HWRITE = 0;
        HREADY = 0;
        PARITYSEL = 0;
    endfunction

    function void post_randomize();
        count++;
    endfunction

endclass: Transaction



