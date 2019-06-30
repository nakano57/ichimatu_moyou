//完成
module syncgen(
  input CLK,
  input RST,
  output PCK,
  output reg VGA_HS,
  output reg VGA_VS,
  output reg[9:0] HCNT,
  output reg[9:0] VCNT
);

`include "vga_param.vh"

wire locked;

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG

  clk_wiz_0 pckgen
   (
    // Clock out ports
    .clk_out1(PCK),     // output clk_out1
    // Status and control signals
    .reset(RST), // input reset
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(CLK)
    );      // input clk_in1
// INST_TAG_END ------ End INSTANTIATION Template ---------

//pckgen pckgen (.SYSCLK(CLK),.PCK(PCK));

wire hcntend = (HCNT==HPERIOD-12'h001);

//水平カウンタ
always @(posedge PCK) begin
  if(RST)
    HCNT <= 12'h000;
  else if (hcntend)
    HCNT <= 12'h000;
  else
    HCNT <= HCNT + 12'h001;
end

//垂直カウンタ
always @(posedge PCK) begin
  if(RST)
    VCNT <= 12'h000;
  else if (hcntend)begin
    if(VCNT == VPERIOD - 12'h001)
      VCNT <= 12'h000;
    else
      VCNT <= VCNT+12'h001;
  end
end

wire [9:0] hsstart = HFRONT - 12'h001;
wire [9:0] hsend = HFRONT + HWIDTH - 12'h001;
wire [9:0] vsstart = VFRONT;
wire [9:0] vsend = VFRONT + VWIDTH;

always @(posedge PCK) begin
  if(RST)
    VGA_HS <= 1'b1;
  else if (HCNT == hsstart)
    VGA_HS <= 1'b0;
  else if (HCNT==hsend)
    VGA_HS <= 1'b1;
end

always @(posedge PCK) begin
  if(RST)
    VGA_VS <= 1'b1;
  else if (HCNT == hsstart) begin
    if (VCNT == vsstart)
      VGA_VS <= 1'b0;
    else if (VCNT == vsend)
      VGA_VS <= 1'b1;
  end
end


endmodule
