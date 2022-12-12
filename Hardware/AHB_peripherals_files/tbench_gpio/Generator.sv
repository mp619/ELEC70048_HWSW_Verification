`include "Transaction.sv"
class Generator;                // Change to SINGLE TRANSACTION
    mailbox gen2driv;

    // Packet count
    int dir0_pkts;
    int dir1_pkts;
    int random_pkts;

    // Number of Packets
    int pkt_count = 0;

    Transaction tr;

    localparam [15:0] gpio_dir_addr = 16'h0004;


    function new(mailbox gen2driv, int dir0_pkts, int dir1_pkts, int random_pkts);
        this.gen2driv = gen2driv;
        //get number of packets
        this.dir0_pkts = dir0_pkts;
        this.dir1_pkts = dir1_pkts;
        this.random_pkts = random_pkts;
    endfunction

    task test1();
        repeat(dir0_pkts) begin
            tr = new(); 
            tr.constraint_mode(0); 
            if( !tr.randomize() ) $fatal ("[Generator] Address transaction randomization fail");
            tr.post_randomize();
            $display("[Generator] Transaction randomization pass");
            tr.display();
            // Put packet into mailbox
            gen2driv.put(tr);
            pkt_count++;
        end
    endtask

    task test2();
        repeat(dir1_pkts) begin
            tr = new();
            tr.constraint_mode(0); 
            if( !tr.randomize() ) $fatal ("[Generator] Address transaction randomization fail");
            tr.post_randomize();
            $display("[Generator] Transaction randomization pass");
            tr.display();
            // Put packet into mailbox
            gen2driv.put(tr);
            pkt_count++;
        end
    endtask

    task test3();
        logic gpio_dir = 0;
        repeat(random_pkts) begin
            tr = new();
            //tr.test3.constraint_mode(1); 
             if( !tr.randomize() ) $fatal ("[Generator] Address transaction randomization fail");
            tr.post_randomize();
            $display("[Generator] Transaction randomization pass");
            if (pkt_count%10 == 0)   //Change Direction
                begin
                    tr.HADDR = gpio_dir_addr;
                    tr.HWRITE = 1;
                end
            if ((pkt_count-1)%10 == 0)   //Change Direction
                begin
                    tr.HWDATA = gpio_dir;
                    tr.HWRITE = 1;
                    gpio_dir = ~gpio_dir;
                end
            tr.display();
            // Put packet into mailbox
            gen2driv.put(tr);
            pkt_count++;
        end
    endtask

    task main();
        $display("[Generator] Starting at T=%0t", $time);
        // Randomize 2 packets: One for address phase, One for data phase
        test1();
        test2();
        test3();
    endtask
endclass: Generator