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
    output wire DLS_ERROR,

    input wire [4:0] inject_bug       // Testing Purposes
);
    reg         dls_error;

    wire [31:0] s_HRDATA;
    wire        s_HREADYOUT;
    wire        s_HSYNC;
    wire        s_VSYNC;
    wire [7:0]  s_RGB;


    

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

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn)
            dls_error <= 0;
        else
        begin
            dls_error <= ((HREADYOUT ^ (s_HREADYOUT+inject_bug[0])) || (HSYNC ^ (s_HSYNC+inject_bug[1])) || (VSYNC ^ (s_VSYNC+inject_bug[2])) || (HRDATA ^ (s_HRDATA+inject_bug[3])) || (RGB ^ (s_RGB)+inject_bug[4]));
        end
    end

    assign DLS_ERROR = dls_error;

// Possible Assertions
//---------------------------------------------------------------------------------

    wire CONTROL;
    assign CONTROL = HTRANS[1] && HREADY && HWRITE && HSEL;

  // Check DLS
  check_dls: assert property(
    @(posedge HCLK) disable iff(!HRESETn)
    (!(HREADYOUT == s_HREADYOUT) || !(HSYNC == s_HSYNC) || !(VSYNC == s_VSYNC) || !(HRDATA == s_HRDATA) || !(RGB == s_RGB)) && inject_bug == 0 |-> ##1 DLS_ERROR
  );

  // Check length of HSYNC
  check_hsync: assert property(
    @(posedge HCLK) disable iff(!HRESETn)
    $past(HSYNC) & !HSYNC ##1 CONTROL[*1602] |-> !HSYNC & $past(HSYNC) |-> ##1 !HSYNC
  );  
  


endmodule