module pattern(
  input CLK,
  input RST,
  output reg [4:0] VGA_R,
  output reg [4:0] VGA_G,
  output reg [4:0] VGA_B,
  output VGA_HS,
  output VGA_VS
);

`include "vga_param.vh"

localparam HSIZE = 10'd80;
localparam VSIZE = 10'd120;

wire PCK;
wire [9:0] HCNT,VCNT;

syncgen syncgen(
  .CLK (CLK),
  .RST (RST),
  .PCK (PCK),
  .VGA_HS (VGA_HS),
  .VGA_VS (VGA_VS),
  .HCNT (HCNT),
  .VCNT (VCNT)
);

wire [9:0] HBLANK = HFRONT + HWIDTH + HBACK;
wire [9:0] VBLANK = HFRONT + VWIDTH + VBACK;

wire disp_enable = (VBLANK <= VCNT) && (HBLANK-10'd1 <= HCNT) && (HCNT < HPERIOD - 10'd1);

wire [2:0] rgb_0 = (HCNT - HBLANK+10'd1)/HSIZE;
wire [2:0] rgb_1 = (((VCNT - VBLANK)/VSIZE)&1)==0 ? 3'd7 - rgb_0:rgb_0;

always @(posedge PCK)begin
  if(RST)
    {VGA_R,VGA_G,VGA_B} <= 12'h000;
  else if (disp_enable)
    {VGA_R,VGA_G,VGA_B} <= { {5{rgb_1[2]}}, {5{rgb_1[1]}}, {5{rgb_1[0]}} };
  else
    {VGA_R,VGA_G,VGA_B} <= 12'h000;
end

endmodule
