`include "Monitor.sv"
class Scoreboard;
    virtual AHBVGA_intf ahbvga_scb_vintf;
    mailbox mon2scb;

    int pkt_count;

    Transaction tr;
    //Transaction tr_q [$:1];         //Transaction queue size of 1

    localparam [7:0] gpio_data_addr = 8'h00;
    localparam [7:0] gpio_dir_addr = 8'h04;

    function new(virtual AHBVGA_intf ahbvga_scb_vintf, mailbox mon2scb);
        this.ahbvga_scb_vintf = ahbvga_scb_vintf;
        this.mon2scb = mon2scb;
    endfunction

    function void display();
        $display("-------------------[Time = %0t][Scoreboard][Packet no. %0d]-------------------", $time, pkt_count+1);
        //tr_q[1].display();
        //tr_q[0].display();
        $display("------------------------------------------------------------------------------");
    endfunction

    task main();
        // tr = new();
        // tr.reset();
        // tr_q.push_front(tr);
        // tr_q.push_front(tr);
        forever begin
            // Getting data
            //@(posedge ahbgpio_scb_vintf.clk);
            //mon2scb.get(tr);

            // tr_q.delete(1);
            // tr_q.push_front(tr);
            //pkt_count++;
        end
    endtask 

endclass