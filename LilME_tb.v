`timescale 1ns/1ps
module LilME_tb;

    parameter dw = 31;
    parameter aw = 31;
    parameter row = 4;
    parameter col = 4;

    reg clk;
    reg reset;
    reg [2:0] ME_opcode;
    reg A_opcode;
    reg B_opcode;
    reg [aw:0] Address_out;
    reg [dw:0] Data_in;
    wire Busy;
    wire [dw:0] Data_out;
    wire [dw:0] result;

   LilME #(
        .dw(dw),
        .aw(aw),
        .row(row),
        .col(col)
    ) uut (
        .clk(clk),
        .reset(reset),
        .ME_opcode(ME_opcode),
        .A_opcode(A_opcode),
        .B_opcode(B_opcode),
        .Address_out(Address_out),
        .Data_in(Data_in),
        .Busy(Busy),
        .Data_out(Data_out),
        .result(result)
    );

   always #5 clk = ~clk;

initial begin
        clk = 0;
        reset = 1;
        ME_opcode = 3'b000;
        A_opcode = 0;
        B_opcode = 0;
        Data_in = 32'h00000000;
        Address_out = 32'h00000000;

        #10 reset = 0;

//testing Load_address （ME_opcode = 3'b001）

        #10 ME_opcode = 3'b001;
        #10 ME_opcode = 3'b000; //IDLE


//testing Load_Matrix_a （ME_opcode = 3'b010）

        #10 ME_opcode = 3'b010;
        A_opcode = 1;
        Data_in = 32'hA5A5A5A5;
        #20 ME_opcode = 3'b000;
        A_opcode = 0;

//testing Load_Matrix_b （ME_opcode = 3'b011）

        #10 ME_opcode = 3'b011;
        B_opcode = 1;
        Data_in = 32'h5A5A5A5A;
        #20 ME_opcode = 3'b000;
        B_opcode = 0;

 // testing MUL（ME_opcode = 3'b101）

        #10 ME_opcode = 3'b101;
        #20 ME_opcode = 3'b000;
    
 // testing read_MUL（ME_opcode = 3'b111）

        #10 ME_opcode = 3'b111;
        #50 ME_opcode = 3'b000;
    
        #100 $stop;
    end

   initial begin
        $monitor("Time=%0t | ME_opcode=%b | A_opcode=%b | B_opcode=%b | Address_out=%h | Data_in=%h | Data_out=%h | Busy=%b | result=%h",
                 $time, ME_opcode, A_opcode, B_opcode, Address_out, Data_in, Data_out, Busy, result);
    end

endmodule
