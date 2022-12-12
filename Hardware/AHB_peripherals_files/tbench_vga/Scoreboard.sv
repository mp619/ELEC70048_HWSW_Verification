`include "Monitor.sv"
`include "font_lib.sv"

class Scoreboard;
    virtual AHBVGA_intf ahbvga_scb_vintf;
    mailbox mon2scb;

    // Cell info
    int letter_count = 0;
    logic expected_pixel;

    logic [9:0] cell_no = 0;
    int CELL_WIDTH = 8;
    int CELL_HEIGHT = 16;
    logic [3:0] cell_row;
    logic [3:0] cell_col;

    // Coordinates
    int x = 0;
    int y = 0;
    int X_MAX = 240;
    int Y_MAX = 480;
    logic console_area; 
    logic pixel_div = 0;  

    Transaction tr;
    Transaction tr_q [$:1];                 //Transaction queue size of 2
    logic [7:0] validletters_q [$];         //Valid Letters Queue

    localparam [23:0] sel_console = 12'h000000000000;

    typedef struct {
        int no = 0;           // Error Number
        time time_q [$];            // Time_queue
    } st_error;

    st_error err;

    function new(virtual AHBVGA_intf ahbvga_scb_vintf, mailbox mon2scb);
        this.ahbvga_scb_vintf = ahbvga_scb_vintf;
        this.mon2scb = mon2scb;
    endfunction

    function void displayValid();
        $display("-------------------[Time = %0t][Scoreboard][Queue]----------------------------", $time);
        $display("Letter No. %0d = %0s", letter_count, validletters_q[letter_count]);
        $display("------------------------------------------------------------------------------");
    endfunction

    function void displayInvalid();
        $display("-------------------[Time = %0t][Scoreboard][Queue]----------------------------", $time);
        $display("ERROR Invalid ASCII Character, Letter No. %0d", letter_count);
        $display("------------------------------------------------------------------------------");
    endfunction

    function void displayErrors();
        $display("-------------------[Time = %0t][Scoreboard][Error Summary]---------------------", $time);
        $display("Error No. %0d", err.no);
        for(int i = 0; i < err.no; i++)
        begin
            $display("Error @ time %0t", err.time_q[i]);
        end
    endfunction

    function void validletter();
        if (tr_q[0].HWRITE & tr_q[0].HSEL & tr_q[0].HTRANS[1] & tr_q[0].HREADYOUT & (tr_q[0].HADDR == sel_console))
        begin
            if ((tr.HWDATA[6:0] >= 8'h00) && (tr.HWDATA[6:0] <= 8'h7f) )
            begin
                validletters_q.push_back(tr.HWDATA[6:0]);    //Save character in a queue/buffer
                displayValid();
                letter_count++;
            end
            else
            begin
                validletters_q.push_back(8'h00);    //Save character in a queue/buffer 
                displayInvalid();
                letter_count++;
                err.no++;
                err.time_q.push_back($time);
               end
        end 
    endfunction

    function void coordinates();
        pixel_div = ~pixel_div;     // Divide pixel clock by 2
        if (tr_q[0].VSYNC && !tr.VSYNC)     // New frame
        begin
            x = 0;  // Reset Count
            y = 0;  // Reset Count
        end
        if (tr_q[0].HSYNC && !tr.HSYNC)    // New line
        begin 
            y++;    //Increment y
            x = 0;  //Restart x
        end
        if(pixel_div)                        // Divide pixel print by 2, print only first pixel
        begin
            x++;
            //$display("[%0d, %0d]", y,x);
        end
    endfunction

    function void FindConsoleArea();
        if (((y-35) >= 0) && ((y-35) < Y_MAX) && ((x-147) >= 0) && ((x-147) < X_MAX))
            console_area = 1;
        else
            console_area = 0;
    endfunction

    function void FindCharacterNo();
        int row_no;
        int col_no;
        
        row_no = $floor((x-147)/CELL_WIDTH);
        col_no = $floor((y-35)/CELL_HEIGHT);  

        cell_no = row_no + 30*(col_no);
    endfunction

    function void GetExpectedPixel();
        logic [10:0] addr;
        logic [7:0] char_line;

        cell_row = (y-35)%CELL_HEIGHT;
        cell_col = (x-147)%CELL_WIDTH;

        if (cell_no < letter_count)                         // Check we are within the range of printed letters
        begin
            addr = {validletters_q[cell_no], cell_row};      // First nibble is row number and last two is ascii character address
            char_line = font_lib(addr);
        end
        else
            char_line = 8'b00000000;

        expected_pixel = char_line[7-cell_col];

        $write("%b, %0d", char_line, expected_pixel);
    endfunction

    function void CheckChar();
        logic pixel;
        pixel = |tr.RGB;        //Extract pixel data
        $display(", %0d", pixel);
        if (pixel != expected_pixel)
            begin
            $display("[Time = %0t][Scoreboard] ERROR Pixel output fail in Cell no. %0d letter %0s", $time, cell_no, validletters_q[cell_no]);
            err.no++;
            err.time_q.push_back($time);
            end
        else if ((cell_row == (CELL_HEIGHT-1)) && (cell_col == (CELL_WIDTH-1)) && (cell_no < letter_count)) 
            $display("[Time = %0t][Scoreboard] Complete character %0s in Cell no. %0d", $time, validletters_q[cell_no], cell_no);
    endfunction

    task main();
        tr = new();
        tr.reset();
        tr_q.push_front(tr);
        tr_q.push_front(tr);
        forever begin
            // Getting data
            @(posedge ahbvga_scb_vintf.clk);
            mon2scb.get(tr);

            // Testing sequance
            validletter();
            coordinates();
            if (pixel_div)
            begin
                FindConsoleArea();
                if (console_area)
                begin
                    FindCharacterNo();
                    GetExpectedPixel();
                    CheckChar();
                end
            end

            // Push oldest transaction out
            tr_q.delete(1);
            tr_q.push_front(tr);
            //pkt_count++;
        end
    endtask 

endclass