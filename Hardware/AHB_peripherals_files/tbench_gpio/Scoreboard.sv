`include "Monitor.sv"
class Scoreboard;
    virtual AHBGPIO_intf ahbgpio_scb_vintf;
    mailbox mon2scb;

    int no_packets;
    int pkt_count;

    Transaction tr;
    Transaction tr_q [$:1];         //Transaction queue size of 2

    localparam [7:0] gpio_data_addr = 8'h00;
    localparam [7:0] gpio_dir_addr = 8'h04;

    function new(virtual AHBGPIO_intf ahbgpio_scb_vintf, mailbox mon2scb, int no_packets);
        this.ahbgpio_scb_vintf = ahbgpio_scb_vintf;
        this.mon2scb = mon2scb;
        this.no_packets = no_packets;
    endfunction

    function void display();
        $display("-------------------[Time = %0t][Scoreboard][Packet no. %0d]-------------------", $time, pkt_count+1);
        tr_q[1].display();
        tr_q[0].display();
        $display("------------------------------------------------------------------------------");
    endfunction

    task main();
        tr = new();
        tr.reset();
        tr_q.push_front(tr);
        tr_q.push_front(tr);
        forever begin
            // Getting data
            @(posedge ahbgpio_scb_vintf.clk);
            mon2scb.get(tr);
            // @(posedge ahbgpio_scb_vintf.clk);
            // mon2scb.get(tr_sample);

            display();

            //Check Reset
            if(!(ahbgpio_scb_vintf.rst_n))
            begin
                if(!(
                    tr.HADDR     == 0 &
                    tr.HTRANS    == 0 &
                    tr.HSEL      == 0 &
                    tr.HWDATA    == 0 &
                    tr.GPIOIN    == 0 &
                    tr.HWRITE    == 0 &
                    tr.HREADY    == 0 &
                    tr.PARITYSEL == 0 
                ))  $fatal ("[Time = %0t][Scoreboard] Reset FAIL", $time);  
            end

            //Check direction
            if((tr_q[1].HADDR == gpio_dir_addr) & (tr_q[1].HSEL) & tr_q[1].HWRITE & tr_q[1].HTRANS[1])
            begin
                if(!(tr.GPIODIR[15:0] == tr_q[0].HWDATA[15:0])) $fatal ("[Time = %0t][Scoreboard] Direction fail expected %0d actual %0d", $time, tr_q[0].HWDATA[0], tr.GPIODIR[0]);
                $display ("[Time = %0t][Scoreboard] Direction pass expected %0d actual %0d", $time, tr_q[0].HWDATA[0], tr.GPIODIR[0]);
            end 
            else
            begin
                if(!(tr.GPIODIR[15:0] == tr_q[0].GPIODIR[15:0])) $fatal ("[Time = %0t][Scoreboard] GPIODIR Unexpected Change", $time);  
            end

            //Check write
            if((tr_q[0].GPIODIR == 16'h0001) & (tr_q[1].HADDR[7:0] == gpio_data_addr) & tr_q[1].HSEL & tr_q[1].HWRITE & tr_q[1].HTRANS[1])
            begin 
                if(!(tr.GPIOOUT[15:0] == tr_q[0].HWDATA[15:0])) $fatal ("[Time = %0t][Scoreboard] GPIOOUT Write fail expected %0d actual %0d", $time, tr_q[0].HWDATA[15:0], tr.GPIOOUT[15:0]);
                $display ("[Time = %0t][Scoreboard] GPIOOUT Write pass expected %0d actual %0d", $time, tr_q[0].HWDATA[15:0], tr.GPIOOUT[15:0]);
                //Check parity
                if(!(tr_q[0].PARITYSEL))   //Check if even parity works
                begin 
                    if(^tr.GPIOOUT) $fatal ("[Time = %0t][Scoreboard] Even PARITYBIT fail expected even parity, actual odd", $time);
                end 
                else                        //Check if odd parity works
                begin 
                    if(!(^tr.GPIOOUT)) $fatal ("[Time = %0t][Scoreboard] Odd PARITYBIT fail expected odd parity, actual even", $time);
                end  
            end
            else
            begin
                if(!(tr.GPIOOUT[15:0] == tr_q[0].GPIOOUT[15:0])) $fatal ("[Time = %0t][Scoreboard] GPIOOUT Unexpected Write", $time);  
            end

            //Check read
            if((tr_q[0].GPIODIR == 16'h0000))
            begin
                if(!(tr.HRDATA[15:0] == tr_q[0].GPIOIN[15:0])) $fatal ("[Time = %0t][Scoreboard] GPIOIN Input Read fail expected %0d actual %0d", $time, tr_q[0].GPIOIN[15:0], tr.HRDATA[15:0]);
                $display ("[Time = %0t][Scoreboard] GPIOIN Input Read pass expected %0d actual %0d", $time, tr_q[0].GPIOIN[15:0], tr.HRDATA[15:0]); 
                //Check if PARITYERR works
                if(!(tr.PARITYERR == ^(tr_q[0].GPIOIN)^tr_q[0].PARITYSEL))  $fatal ("[Time = %0t][Scoreboard] PARITYERR GPIOIN fail expected %0d actual %0d", $time, ^(tr_q[0].GPIOIN)^tr_q[0].PARITYSEL, tr.PARITYERR); 
            end 
            else if((tr_q[0].GPIODIR == 16'h0001))
            begin 
                if(!(tr.HRDATA[15:0] == tr_q[0].GPIOOUT[15:0])) $fatal ("[Time = %0t][Scoreboard] GPIOIN Input Read fail expected %0d actual %0d", $time, tr_q[0].GPIOOUT[15:0], tr.HRDATA[15:0]);
                $display ("[Time = %0t][Scoreboard] GPIOIN Input Read pass expected %0d actual %0d", $time, tr_q[0].GPIOOUT[15:0], tr.HRDATA[15:0]); 
                //Check if PARITYERR works
                if(!(tr.PARITYERR == ^(tr_q[0].GPIOOUT)^tr_q[0].PARITYSEL))  $fatal ("[Time = %0t][Scoreboard] PARITYERR GPIOOUT fail expected %0d actual %0d", $time, ^(tr_q[0].GPIOOUT)^tr_q[0].PARITYSEL, tr.PARITYERR);          
            end
            else 
            begin 
                if(!(tr.HRDATA[15:0] == tr_q[0].HRDATA[15:0])) $fatal ("[Time = %0t][Scoreboard] GPIOIN Input Unexpected Read", $time); 
                if(!(tr.PARITYERR == tr_q[0].PARITYERR)) $fatal ("[Time = %0t][Scoreboard] PARITYERR Unexpected change", $time);                    
            end


            // Get last address and select values to be used next round
            tr_q.delete(1);
            tr_q.push_front(tr);
            pkt_count++;
        end
    endtask 

endclass