module Matrix_A #(
    parameter row = 4,         
    parameter col = 4       
)(
    input wire clk,
    input wire reset,
    input wire A_opcode,       
    input wire [31:0] Data_to_A, 
    output reg [row*col*32-1:0] Data_out, 
    output reg Busy_A          
);

    
    reg [31:0] matrix [row-1:0]; 
    reg [$clog2(row)-1:0] write_index; 
    integer i;
    integer j;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            Busy_A <= 1'b0;
            write_index <= 0;
            for (i = 0; i < row; i = i + 1) begin
                matrix[i] <= 32'b0;
            end
        end else begin
            if (A_opcode == 1'b1) begin 
                Busy_A <= 1'b1;
                matrix[write_index] <= Data_to_A; 
                write_index <= write_index + 1'b1; 

                if (write_index == row - 1) begin 
                    write_index <= 0;
                    Busy_A <= 1'b0; 
                end
            end else begin
                Busy_A <= 1'b0; 
            end
        end
    end

    
    always @(*) begin
        Data_out = 0;
        for (j = 0; j < row; j = j + 1) begin
            Data_out[(j+1)*32-1 -: 32] = matrix[j];
        end
    end

endmodule
