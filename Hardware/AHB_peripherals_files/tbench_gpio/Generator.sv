`include "Transaction.sv"

class generator;
    Transaction tr;
    mailbox gen2driv;

    task main();
        // Randomize packet
        tr = new();
        if( !tr.randomize() ) $fatal ("Gen :: packet randomization fail");
        $display("Gen :: packet randomization pass");
        tr.display();

        // Put packet into mailbox

    endtask
endclass