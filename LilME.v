module LilME #
  (
  parameter aw = 31, 
  parameter dw = 31,
  parameter row = 4,
  parameter col = 4 )
  ( 
    input wire [2:0] ME_opcode,
   input wire clk,
   input wire reset,
   input wire A_opcode,
   input wire B_opcode,
   output wire Busy,
   output wire [aw:0] Address_out ,
   input wire [dw:0] Data_in,
   output wire [dw:0] Data_out,
   output wire [dw:0] result
  );
  LilME_controller #
  (
    .aw(aw),
    .dw(dw),
    .row(row),
    .col(col)
  )
  controller 
  (
    .clk(clk),
    .reset(reset),
    .ME_opcode(ME_opcode),
    .A_opcode(A_opcode),
    .B_opcode(B_opcode),
    .Address_out(Address_out),
    .Data_in(Data_in),
    .Data_out(Data_out),
    .Busy(Busy),
    .result(result)
  );

endmodule
  
