module tb_clk
    (
        output logic clk
    );

initial begin
    clk = 0;
    forever #100 clk = !clk;
end

endmodule