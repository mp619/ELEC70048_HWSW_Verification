class Transaction;
    int count = 0;

    rand logic [31:0]       HADDR;
    rand logic [1:0]        HTRANS;
    rand logic              HSEL;
    rand logic [31:0]       HWDATA;
    rand logic [16:0]       GPIOIN;
    rand logic              HWRITE;
    rand logic              HREADY;
    rand logic              PARITYSEL;

    logic                   HREADYOUT;
    logic [31:0]            HRDATA;
    logic [16:0]            GPIOOUT;
    logic                   PARITYERR;  
    logic [31:0]            GPIODIR;          

    constraint gpioin {
        GPIOIN dist {17'h00000:/2, 17'hFFFFF:/2, [0:131072]:/96};
    };

    constraint htrans {
        HTRANS dist {2'b10:/90, [0:3]:/10};
    };

    // constraint test3 { 
    //     HADDR dist {16'h0000:/20, 16'h0004:/10, [0:65535]:/70};    
    //     HWDATA dist {16'h0000:/10, 16'h0001:/10, [0:65535]:/80};
    //     };

    // constraint test3 {
    //     {(count%10 == 0) -> HADDR==gpio_dir_addr};
    // };

    function void display();
        $display("[Transaction] Outputs: HADDR, HTRANS, HWDATA, HWRITE, HSEL, HREADY, GPIOIN, PARITYSEL");
        $display("[Transaction] Values: %h, %h, %h, %0b, %0b, %0b, %h, %0d", HADDR, HTRANS, HWDATA, HWRITE, HSEL, HREADY, GPIOIN, PARITYSEL);
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



