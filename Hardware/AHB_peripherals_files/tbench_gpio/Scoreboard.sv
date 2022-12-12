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

    typedef struct {
        int no = 0;                 // Error Number
        time time_q [$];            // Time_queue
    } st_error;

    st_error err;

    function new(virtual AHBGPIO_intf ahbgpio_scb_vintf, mailbox mon2scb, int no_packets);
        this.ahbgpio_scb_vintf = ahbgpio_scb_vintf;
        this.mon2scb = mon2scb;
        this.no_packets = no_packets;
    endfunction

    function void display();
        $display("-------------------[Time = %0t][Scoreboard][Packet no. %0d]-------------------", $time, pkt_count);
        //tr_q[1].display();
        tr_q[0].display();
        $display("------------------------------------------------------------------------------");
    endfunction

    function void displayErrors();
        $display("-------------------[Time = %0t][Scoreboard][Error Summary]-------------------------", $time);
        $display("Error No. %0d", err.no);
        for(int i = 0; i < err.no; i++)
        begin
            $display("Error @ time %0t", err.time_q[i]);
        end
    endfunction

    function void addError();
        err.no++;
        err.time_q.push_back($time);
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
                )) 
                begin 
                    $display ("[Time = %0t][Scoreboard] ERRROR Reset FAIL", $time);  
                    addError();
                end
            end

            //Check direction
            if((tr_q[1].HADDR == gpio_dir_addr) & (tr_q[1].HSEL) & tr_q[1].HWRITE & tr_q[1].HTRANS[1])
            begin
                if(!(tr.GPIODIR[15:0] == tr_q[0].HWDATA[15:0])) 
                begin
                    $display ("[Time = %0t][Scoreboard] ERROR Direction fail expected %h actual %h", $time, tr_q[0].HWDATA, tr.GPIODIR); //ERROR
                    addError();
                end
                else if ((tr.GPIODIR[15:0] == 16'h0001) | (tr.GPIODIR[15:0] == 16'h0000))
                    $display ("[Time = %0t][Scoreboard] Direction pass expected %h actual %h", $time, tr_q[0].HWDATA, tr.GPIODIR);
                else 
                    $display ("[Time = %0t][Scoreboard] INVALID Direction change to %h", $time, tr.GPIODIR);
            end 
            else
            begin
                if(!(tr.GPIODIR[15:0] == tr_q[0].GPIODIR[15:0])) 
                begin
                    $display ("[Time = %0t][Scoreboard] ERROR GPIODIR Unexpected Change", $time);  //ERROR
                    addError();
                end
            end

            //Check write
            if((tr_q[0].GPIODIR == 16'h0001) & (tr_q[1].HADDR[7:0] == gpio_data_addr) & tr_q[1].HSEL & tr_q[1].HWRITE & tr_q[1].HTRANS[1])
            begin 
                if(!(tr.GPIOOUT[15:0] == tr_q[0].HWDATA[15:0])) 
                begin
                    $display ("[Time = %0t][Scoreboard] ERROR GPIOOUT Write fail expected %0h actual %0h", $time, tr_q[0].HWDATA[15:0], tr.GPIOOUT[15:0]); //ERROR
                    addError();             
                end 
                else 
                    $display ("[Time = %0t][Scoreboard] GPIOOUT Write pass expected %0h actual %0h", $time, tr_q[0].HWDATA[15:0], tr.GPIOOUT[15:0]);
                //Check parity
                if(!(tr_q[0].PARITYSEL))   //Check if even parity works
                begin 
                    if(^tr.GPIOOUT)
                    begin 
                        $display ("[Time = %0t][Scoreboard] ERROR Even PARITYBIT fail expected even parity, actual odd", $time); //ERROR
                        addError();
                    end
                end 
                else                        //Check if odd parity works
                begin 
                    if(!(^tr.GPIOOUT)) 
                    begin
                        $display ("[Time = %0t][Scoreboard] ERROR Odd PARITYBIT fail expected odd parity, actual even", $time); //ERROR
                        addError(); 
                    end
                end  
            end
            else
            begin
                if(!(tr.GPIOOUT[15:0] == tr_q[0].GPIOOUT[15:0])) 
                begin
                    $display ("[Time = %0t][Scoreboard] ERROR GPIOOUT Unexpected Write", $time);    //ERROR  
                    addError();
                end
            end

            //Check read
            if((tr_q[0].GPIODIR == 16'h0000))
            begin
                if(!(tr.HRDATA[15:0] == tr_q[0].GPIOIN[15:0])) 
                begin 
                    $display ("[Time = %0t][Scoreboard] ERROR GPIOIN Input Read fail expected %0h actual %0h", $time, tr_q[0].GPIOIN[15:0], tr.HRDATA[15:0]);   //ERROR
                    addError();
                end
                else
                    $display ("[Time = %0t][Scoreboard] GPIOIN Input Read pass expected %0h actual %0h", $time, tr_q[0].GPIOIN[15:0], tr.HRDATA[15:0]); 
                //Check if PARITYERR works
                if(!(tr.PARITYERR == ^(tr_q[0].GPIOIN)^tr_q[0].PARITYSEL))  
                begin
                    $display ("[Time = %0t][Scoreboard] ERROR PARITYERR GPIOIN fail expected %0d actual %0d", $time, ^(tr_q[0].GPIOIN)^tr_q[0].PARITYSEL, tr.PARITYERR); //ERROR
                    addError();
                end
                else 
                    $display ("[Time = %0t][Scoreboard] PARITYERR GPIOIN pass expected %0d actual %0d", $time, ^(tr_q[0].GPIOIN)^tr_q[0].PARITYSEL, tr.PARITYERR);
            end 
            else if((tr_q[0].GPIODIR == 16'h0001))
            begin 
                if(!(tr.HRDATA[15:0] == tr_q[0].GPIOOUT[15:0])) 
                begin
                    $display ("[Time = %0t][Scoreboard] ERROR GPIOOUT Input Read fail expected %0h actual %0h", $time, tr_q[0].GPIOOUT[15:0], tr.HRDATA[15:0]); //ERROR
                    addError();
                end
                else
                    $display ("[Time = %0t][Scoreboard] GPIOOUT Input Read pass expected %0h actual %0h", $time, tr_q[0].GPIOOUT[15:0], tr.HRDATA[15:0]); 
                //Check if PARITYERR works
                if(!(tr.PARITYERR == ^(tr_q[0].GPIOOUT)^tr_q[0].PARITYSEL))  
                begin
                    $display ("[Time = %0t][Scoreboard] ERROR PARITYERR GPIOOUT fail expected %0d actual %0d", $time, ^(tr_q[0].GPIOOUT)^tr_q[0].PARITYSEL, tr.PARITYERR);  //ERROR
                    addError(); 
                end   
                else 
                    $display ("[Time = %0t][Scoreboard] PARITYERR GPIOOUT pass expected %0d actual %0d", $time, ^(tr_q[0].GPIOOUT)^tr_q[0].PARITYSEL, tr.PARITYERR);    
            end
            else 
            begin 
                if(!(tr.HRDATA[15:0] == tr_q[0].HRDATA[15:0])) 
                begin
                    $display ("[Time = %0t][Scoreboard] ERROR GPIOIN Input Unexpected Read", $time);    //ERROR
                    addError();
                end
                if(!(tr.PARITYERR == tr_q[0].PARITYERR)) 
                begin
                    $display ("[Time = %0t][Scoreboard] PARITYERR Unexpected change", $time);   //ERROR   
                    addError();
                end              
            end
            // Get last address and select values to be used next round
            tr_q.delete(1);
            tr_q.push_front(tr);
            pkt_count++;
        end
    endtask 

endclass