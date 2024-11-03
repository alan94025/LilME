module Multiplier_M #(
	parameter dw = 32,
	parameter row = 4,
	parameter col = 4
)
(
	input wire clk,
	input wire n_reset,
	input wire opcode,
    input wire [8*row*col-1:0] in_A, // 8*4*4 = 128
    input wire [8*row*col-1:0] in_B, // 8*4*4 = 128
	output wire [16*row*col-1:0] out_M, // 16*4*4 = 256
	output reg busy_M
);
reg [$clog2(row):0] row_counter;
reg [$clog2(col):0] col_counter;
reg [$clog2(col):0] ops_counter;

wire [7:0] A [row-1:0][col-1:0]; // 8*4*4 = 128
wire [7:0] B [row-1:0][col-1:0]; // 8*4*4 = 128
reg [15:0] M [row-1:0][col-1:0]; // 16*4*4 = 256

genvar gen_i;
genvar gen_j;
integer i;
integer j;

//always @(in_A or in_B or M)
//begin
generate
    for (gen_i = 0; gen_i < row; gen_i = gen_i + 1)
	begin
        for (gen_j = 0; gen_j < col; gen_j = gen_j + 1)
		begin
            assign A[gen_i][gen_j] = in_A[gen_i*col*8+gen_j*8+: 8];
            assign B[gen_i][gen_j] = in_B[gen_i*col*8+gen_j*8+: 8];
            //B[i][j] = in_B[i*col*8+j*8+7:i*col*8+j*8];
            assign out_M[gen_i*col*16+gen_j*16+: 16] = M[gen_i][gen_j];
            //out_M[i*col*16+j*16+15:i*col*16+j*16] = M[i][j];
        end
    end
endgenerate
//end

always @(posedge clk or negedge n_reset)
begin
    if (!n_reset)
	begin
        for (i = 0; i < row; i = i + 1)
		begin
            for (j = 0; j < col; j = j + 1)
			begin
                M[i][j] <= 16'b0;
            end
        end
        row_counter <= 0;
        col_counter <= 0;
        ops_counter <= 0;
        busy_M <= 1'b0;
    end
	else
	begin
        if (opcode && !busy_M) // idle go to mult
		begin
            for (i = 0; i < row; i = i + 1)
			begin
                for (j = 0; j < col; j = j + 1)
				begin
                    M[i][j] <= 16'b0;
                end
            end
            row_counter <= 0;
            col_counter <= 0;
            ops_counter <= 0;
            busy_M <= 1'b1;
        end
		else if (busy_M) // already busy in mult
		begin
			// default values
	        for (i = 0; i < row; i = i + 1)
			begin
	            for (j = 0; j < col; j = j + 1)
				begin
	                M[i][j] <= M[i][j];
	            end
	        end
	        row_counter <= row_counter;
	        col_counter <= col_counter;
	        ops_counter <= ops_counter;
	        busy_M <= busy_M;

            if (ops_counter < col) // doing ops for selected row,col
			begin
                M[row_counter][col_counter] <= M[row_counter][col_counter] + 
                                                         A[row_counter][ops_counter] * 
                                                         B[ops_counter][col_counter];
                ops_counter <= ops_counter + 1;
            	busy_M <= 1'b1;
            end
			else // ops done for selected row,col
			begin
                ops_counter <= 0; // reset ops
                if (col_counter < col - 1) // same row,increment col
				begin
                    col_counter <= col_counter + 1;
                end
				else // next A,M row, reset col
				begin
                    col_counter <= 0; // reset col
                    if (row_counter < row - 1) // next row for A,M
					begin
                        row_counter <= row_counter + 1;
                    end
					else // all row,col done
					begin
                        busy_M <= 1'b0;
						/*
                        for (i = 0; i < row; i = i + 1)
						begin
                            for (j = 0; j < col; j = j + 1)
							begin
                                result[i][j] <= temp_result[i][j];
                            end
                        end
						*/
                    end
                end
            end
        end
        else // idle
		begin
	        for (i = 0; i < row; i = i + 1)
			begin
	            for (j = 0; j < col; j = j + 1)
				begin
	                M[i][j] <= M[i][j];
	            end
	        end
	        row_counter <= row_counter;
	        col_counter <= col_counter;
	        ops_counter <= ops_counter;
	        busy_M <= busy_M;
		end
    end
end
/*
case(State)
    idle:
      begin
        if(Byte_ready==1)
          begin
            Next_State = byte_ready2load;
          end
        else
          begin
            Next_State = idle;
          end
      end
*/

endmodule
