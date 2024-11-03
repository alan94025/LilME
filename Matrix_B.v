module Matrix_B (
    input wire clk,
    input wire reset,
    input wire B_opcode, // 1-bit opcode: 0 = idle, 1 = write
    input wire [31:0] Data_to_B, // 32-bit input data
    output reg [127:0] Data_out, // 128-bit output data for entire matrix
    output reg Busy_B // Busy flag to indicate operation in progress
);

    reg [31:0] matrix [3:0]; // Array to store 4 elements of 32 bits each
    reg [1:0] write_index; // Index to track write position within the matrix

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            Busy_B <= 1'b0;
            write_index <= 2'b00;
            matrix[0] <= 32'b0;
            matrix[1] <= 32'b0;
            matrix[2] <= 32'b0;
            matrix[3] <= 32'b0;
        end else begin
            if (B_opcode == 1'b1) begin // Write operation
                Busy_B <= 1'b1;
                matrix[write_index] <= Data_to_B; // Write 32-bit input to current index
                write_index <= write_index + 1'b1; // Move to next element

                if (write_index == 2'b11) begin // If last element, reset index
                    write_index <= 2'b00;
                    Busy_B <= 1'b0; // Mark as done after writing the last element
                end
            end else begin
                Busy_B <= 1'b0; // Set to idle if B_opcode is 0
            end
        end
    end

    // Combine 4x 32-bit matrix elements into one 128-bit output
    always @(*) begin
        Data_out = {matrix[3], matrix[2], matrix[1], matrix[0]};
    end

endmodule
