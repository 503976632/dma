`define FIFO_DEPTH 16
`define DATA_WIDTH 32
module sync_fifo(
 input HCLK,
 input FIFOReset,
 input [`DATA_WIDTH - 1:0]in_HRDATA_m,
 input ReadDataEnable,
 input WriteDataEnable,
 
 output  empty,
 output  full,
 output reg [`DATA_WIDTH - 1:0]out_HWDATA_m
 );
 
 //parameters define
 parameter FIFO_WIDH = 4;
 
 reg [FIFO_WIDH - 1:0] rp_reg;//读指针
 reg [FIFO_WIDH - 1:0] wp_reg;//写指针
 reg [FIFO_WIDH:0]   cnt_reg;
 reg [`DATA_WIDTH - 1:0] men[`FIFO_DEPTH - 1:0];
 
 //rp_reg
 always@(posedge HCLK or posedge  FIFOReset) begin
  if(FIFOReset == 1)
   rp_reg <= 4'd0;
  else if(!empty && ReadDataEnable == 1'b1)
   rp_reg <= rp_reg + 1'b1;
  else rp_reg <= rp_reg;
 
 end 
 
 //wp_reg
 always@(posedge HCLK or posedge  FIFOReset) begin
  if(FIFOReset == 1)
   wp_reg <= 4'd0;
  else if(!full && WriteDataEnable == 1'b1)
   wp_reg <= wp_reg + 1'b1;
  else wp_reg <= wp_reg;
 
 end 
 
 //cnt_reg
 always@(posedge HCLK or posedge  FIFOReset) begin
  if(FIFOReset == 1)
   cnt_reg <= 4'd0;
  else if(!full && WriteDataEnable == 1'b1 && !empty && ReadDataEnable == 1'b1)
   cnt_reg <= cnt_reg;
  else if(!full && WriteDataEnable == 1'b1)
   cnt_reg <= cnt_reg + 1'b1;
  else if(!empty && ReadDataEnable == 1'b1)
   cnt_reg <= cnt_reg - 1'b1;
  else 
   cnt_reg <= cnt_reg;
 end 
 
 //men
 always@(posedge HCLK) begin
  if(!full && WriteDataEnable == 1'b1)
   men[wp_reg] <= in_HRDATA_m;
  if(!empty && ReadDataEnable == 1'b1)
   out_HWDATA_m <= men[rp_reg];
 end 
 
 assign empty = (cnt_reg == 5'd0) ? 1'b1 : 1'b0;
 assign full = (cnt_reg == 5'd16) ? 1'b1 : 1'b0;
 
endmodule




