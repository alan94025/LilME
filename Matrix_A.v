module Matrix_A #(
    parameter row = 4,         // Number of rows (固定值 4)
    parameter column = 4       // Number of columns (固定值 4)
)(
    input wire clk,
    input wire reset,
    input wire A_opcode,       // 1-bit opcode: 0 = idle, 1 = write
    input wire [31:0] Data_to_A, // 32-bit input data
    output reg [row*column*32-1:0] Data_out, // 128-bit output data for entire matrix
    output reg Busy_A          // Busy flag to indicate operation in progress
);

    // 設置一個 4 元素的 32 位記憶體陣列來存儲矩陣
    reg [31:0] matrix [row-1:0]; // 用 row 參數來設置行數
    reg [$clog2(row)-1:0] write_index; // 用於追踪矩陣內的寫入位置

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            Busy_A <= 1'b0;
            write_index <= 0;
            integer i;
            for (i = 0; i < row; i = i + 1) begin
                matrix[i] <= 32'b0;
            end
        end else begin
            if (A_opcode == 1'b1) begin // Write operation
                Busy_A <= 1'b1;
                matrix[write_index] <= Data_to_A; // Write 32-bit input to current index
                write_index <= write_index + 1'b1; // Move to next element

                if (write_index == row - 1) begin // 如果寫入到最後一個元素
                    write_index <= 0;
                    Busy_A <= 1'b0; // 完成後標記為閒置
                end
            end else begin
                Busy_A <= 1'b0; // 若 A_opcode 為 0，則設為閒置
            end
        end
    end

    // 合併 `row` 個 32-bit 矩陣元素到一個 128-bit 輸出
    always @(*) begin
        integer j;
        Data_out = 0;
        for (j = 0; j < row; j = j + 1) begin
            Data_out[(j+1)*32-1 -: 32] = matrix[j];
        end
    end

endmodule
