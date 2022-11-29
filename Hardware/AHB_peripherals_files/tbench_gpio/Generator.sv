`include "Transaction.sv"
class Generator;                // Change to SINGLE TRANSACTION
    Transaction tr;
    mailbox gen2driv;
    int no_packets;

    function new(mailbox gen2driv, int no_packets);
        this.gen2driv = gen2driv;
        this.no_packets = no_packets;
    endfunction

    task main();
        $display("[Generator] Starting at T=%0t", $time);
        // Randomize 2 packets: One for address phase, One for data phase
        repeat(no_packets) begin 
            tr = new();
            if( !tr.randomize() ) $fatal ("[Generator] Address transaction randomization fail");
            $display("[Generator] Address transaction randomization pass");
            tr.display();
            // Put packet into mailbox
            gen2driv.put(tr);

            // tr = new();
            // if( !tr.randomize() ) $fatal ("[Generator] Data transaction randomization fail");
            // $display("[Generator] Data transaction randomization pass");
            // tr.display();
            // // Put packet into mailbox
            // gen2driv.put(tr);
        end
    endtask
endclass: Generator