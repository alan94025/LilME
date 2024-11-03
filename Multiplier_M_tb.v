// This will be a testbench for 2 input xor gate
`timescale 1ns/1ps
module Multiplier_M_tb;

  parameter dw = 32;
  parameter row = 4;
  parameter col = 4;

  // Inputs
  reg tb_clk;
  reg tb_n_reset;
  reg tb_opcode;
  reg [8*row*col-1:0] tb_in_A;
  reg [8*row*col-1:0] tb_in_B;
  // Output
  wire [16*row*col-1:0] tb_out_M;
  wire tb_busy_M;

  Multiplier_M #(.dw(dw),.row(row),.col(col))
	dut (
    .clk(tb_clk),
    .n_reset(tb_n_reset),
    .opcode(tb_opcode),
    .in_A(tb_in_A),
    .in_B(tb_in_B),
    .out_M(tb_out_M),
    .busy_M(tb_busy_M)
  );
  
  always begin
	tb_clk = 1'b0;
    #2;
	tb_clk = 1'b1;
    #2;
  end

  initial begin
		//initialize
	tb_n_reset = 1;
	tb_opcode = 0;
	tb_in_A <= 128'h0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a;
	tb_in_B <= 128'h0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a;


    @(posedge tb_clk);
    @(posedge tb_clk);
		//reset
    @(negedge tb_clk);
	tb_n_reset = 0;
    @(negedge tb_clk);
	tb_n_reset = 1;
		//give a few clk idle
    @(negedge tb_clk);
    @(negedge tb_clk);
    @(negedge tb_clk);
    @(negedge tb_clk);
    @(negedge tb_clk);
		//assert mult in opcode for 1 cycle
    @(negedge tb_clk);
	tb_opcode = 1;
    @(negedge tb_clk);
	tb_opcode = 0;
    @(negedge tb_clk);
    @(negedge tb_clk);
	#400
		//another set of matrix AB
    @(negedge tb_clk);
	tb_in_A <= 128'h100f0e0d0c0b0a090807060504030201;
	tb_in_B <= 128'h0102030405060708090a0b0c0d0e0f10;
    @(negedge tb_clk);
		//assert mult in opcode for 1 cycle
    @(negedge tb_clk);
	tb_opcode = 1;
    @(negedge tb_clk);
	tb_opcode = 0;
    @(negedge tb_clk);
	#400
    // End the simulation
    $stop;
  end
  
  
endmodule
