class Transaction;
    int count = 0;

    rand logic [15:0]        HADDR;
    rand logic               HTRANS;
    rand logic               HSEL;

    rand logic [15:0]   HWDATA;
    rand logic [16:0]   GPIOIN;
    rand logic          HWRITE;
    rand logic          HREADY;
    rand logic          PARITYSEL;

    function void display();
        $display("Transaction: HADDR, HTRANS, HWDATA, HWRITE, HSEL, HREADY, GPIOIN, PARITYSEL");
        $display("Values: %0h, %0h, %0h, %0b, %0b, %0b, %0h, %0d", HADDR, HTRANS, HWDATA, HWRITE, HSEL, HREADY, GPIOIN, PARITYSEL);
    endfunction

    function void post_randomize();
        count++;
    endfunction

endclass: Transaction



