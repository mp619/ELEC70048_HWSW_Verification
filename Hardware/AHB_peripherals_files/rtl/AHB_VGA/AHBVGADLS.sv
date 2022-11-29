module AHBVGADLS(
    input wire HCLK,
    input wire HRESETn,
    input wire [31:0] HADDR,
    input wire [31:0] HWDATA,
    input wire HREADY,
    input wire HWRITE,
    input wire [1:0] HTRANS,
    input wire HSEL,

    output wire [31:0] HRDATA,
    output wire HREADYOUT,

    output wire HSYNC,
    output wire VSYNC,
    output wire [7:0] RGB,
    output wire DLS_ERROR
);

    wire [31:0] s_HRDATA;
    wire        s_HREADYOUT;
    wire        s_HSYNC;
    wire        s_VSYNC;
    wire [7:0]  s_RGB;

    reg         dls_error;

    

    // Primary VGA
    AHBVGA ahbvga0(
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HADDR(HADDR),
        .HWDATA(HWDATA),
        .HREADY(HREADY),
        .HWRITE(HWRITE),
        .HTRANS(HTRANS),
        .HSEL(HSEL),
        .HRDATA(HRDATA),
        .HREADYOUT(HREADYOUT),
        .HSYNC(HSYNC),
        .VSYNC(VSYNC),
        .RGB(RGB)
    );

    // Secondary VGA
    AHBVGA ahbvga1(
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HADDR(HADDR),
        .HWDATA(HWDATA),
        .HREADY(HREADY),
        .HWRITE(HWRITE),
        .HTRANS(HTRANS),
        .HSEL(HSEL),
        .HRDATA(s_HRDATA),
        .HREADYOUT(s_HREADYOUT),
        .HSYNC(s_HSYNC),
        .VSYNC(s_VSYNC),
        .RGB(s_RGB)
    );

    always @(posedge HCLK, negedge HRESETn) begin
        if (!HRESETn)
            dls_error <= 0;
        else
        //DLS_ERROR <= ((HRDATA ^ s_HRDATA) || (HREADYOUT ^ s_HREADYOUT) || (HSYNC ^ s_HSYNC) || (VSYNC ^ s_VSYNC) || (RGB ^ s_RGB));
        dls_error <= ((HREADYOUT ^ s_HREADYOUT) || (HSYNC ^ s_HSYNC) || (VSYNC ^ s_VSYNC) || (HRDATA ^ s_HRDATA) || (RGB ^ s_RGB));
    end

    assign DLS_ERROR = dls_error;

endmodule