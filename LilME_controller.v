module LilME_controller #(
    parameter dw = 31,   // Data width
    parameter aw = 31,   // Address width
    parameter row = 4,   // Number of rows
    parameter col = 4    // Number of columns
)
(
    input clk,
    input reset,
    input [2:0] ME_opcode,   // Global system control opcode
    input A_opcode,          // 1-bit Matrix_A control opcode
    input B_opcode,          // 1-bit Matrix_B control opcode
    input [aw:0] Address_out,
    input [dw:0] Data_in,
    output reg [dw:0] Data_out,
    output reg Busy,
    output reg [dw:0] result
);

    // Internal signal definitions
    wire [127:0] matrix_A_data;  // 128-bit output from Matrix_A
    wire [127:0] matrix_B_data;  // 128-bit output from Matrix_B
    wire [255:0] mult_result;    // 256-bit output from Multiplier_M
    wire Busy_A, Busy_B, Busy_M;

    // State encoding
    reg [2:0] current_state, next_state;
    localparam IDLE          = 3'b000;
    localparam LOAD_ADDRESS  = 3'b001;
    localparam LOAD_A        = 3'b010;
    localparam LOAD_B        = 3'b011;
    localparam CALC          = 3'b100;
    localparam DATA_OUT      = 3'b101;
    localparam READ_PLUS     = 3'b110;
    localparam READ_MULTIPLY = 3'b111;

    // Counter for data read-out, scalable with matrix size
    reg [$clog2(2*row)-1:0] read_counter;
    reg [2:0] out_counter;  // Counter to scroll through 256-bit mult_result in 32-bit chunks

    // Matrix_A module instantiation
    Matrix_A #(.row(4), .col(4)) matrix_A (
        .clk(clk),
        .reset(reset),
        .A_opcode(A_opcode),
        .Data_to_A(Data_in),
        .Data_out(matrix_A_data),
        .Busy_A(Busy_A)
    );

    // Matrix_B module instantiation
    Matrix_B #(.row(4), .col(4)) matrix_B (
        .clk(clk),
        .n_reset(reset),
        .opcode(B_opcode),
        .Data_to_B(Data_in),
        .Data_out(matrix_B_data),
        .Busy(Busy_B)
    );

    // Multiplier_M module instantiation
    Multiplier_M #(.dw(dw), .row(row), .col(col)) multiplier (
        .clk(clk),
        .n_reset(reset),
        .opcode(ME_opcode[1:0]),
        .in_A(matrix_A_data),
        .in_B(matrix_B_data),
        .out_M(mult_result),
        .busy_M(Busy_M)
    );

    // FSM Sequential Block
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            read_counter <= 0;
            out_counter <= 0;
        end else begin
            current_state <= next_state;
            if (current_state == DATA_OUT) begin
                if (out_counter < 7) begin
                    out_counter <= out_counter + 1;
                end else begin
                    out_counter <= 0;
                    read_counter <= read_counter + 1;
                end
            end else begin
                read_counter <= 0;
                out_counter <= 0;
            end
        end
    end

    // FSM Combinational Block
    always @(*) begin
        // Default assignments
        next_state = current_state;
        Data_out = 0;
        Busy = 1'b0;

        case (current_state)
            IDLE: begin
                Busy = 1'b0;
                case (ME_opcode)
                    3'b001: next_state = LOAD_ADDRESS;
                    3'b010: next_state = LOAD_A;
                    3'b011: next_state = LOAD_B;
                    3'b100: next_state = CALC;          // Placeholder for A_+_B, not implemented in Multiplier_M
                    3'b101: next_state = CALC;          // Placeholder for A_x_B operation
                    3'b110: next_state = READ_PLUS;     // Placeholder for read_+_result, not implemented in Multiplier_M
                    3'b111: next_state = READ_MULTIPLY; // Set up for read_x_result
                    default: next_state = IDLE;
                endcase
            end

            LOAD_ADDRESS: begin
                Busy = Busy_A | Busy_B;
                if (!Busy) next_state = IDLE;
            end
            
            LOAD_A: begin
                Busy = Busy_A;
                if (!Busy_A) next_state = IDLE;
            end

            LOAD_B: begin
                Busy = Busy_B;
                if (!Busy_B) next_state = IDLE;
            end

            CALC: begin
                Busy = Busy_M;
                if (!Busy_M) next_state = DATA_OUT;
            end

            DATA_OUT: begin
                // Output 32-bit chunks from 256-bit mult_result
                case (out_counter)
                    3'd0: Data_out = mult_result[31:0];
                    3'd1: Data_out = mult_result[63:32];
                    3'd2: Data_out = mult_result[95:64];
                    3'd3: Data_out = mult_result[127:96];
                    3'd4: Data_out = mult_result[159:128];
                    3'd5: Data_out = mult_result[191:160];
                    3'd6: Data_out = mult_result[223:192];
                    3'd7: Data_out = mult_result[255:224];
                endcase
                Busy = 1'b1;
                
                // Transition to IDLE after full read-out
                if (read_counter == (2*row - 1) && out_counter == 7) 
                    next_state = IDLE;
            end

            READ_PLUS: begin
                // Placeholder state; perform no operation as Multiplier_M does not support addition
                Busy = 1'b1;
                next_state = IDLE;
            end

            READ_MULTIPLY: begin
                // State for reading multiplication results from Multiplier_M
                case (out_counter)
                    3'd0: Data_out = mult_result[31:0];
                    3'd1: Data_out = mult_result[63:32];
                    3'd2: Data_out = mult_result[95:64];
                    3'd3: Data_out = mult_result[127:96];
                    3'd4: Data_out = mult_result[159:128];
                    3'd5: Data_out = mult_result[191:160];
                    3'd6: Data_out = mult_result[223:192];
                    3'd7: Data_out = mult_result[255:224];
                endcase
                Busy = 1'b1;

                // Transition to IDLE after full read-out
                if (read_counter == (2*row - 1) && out_counter == 7)
                    next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Store result in the result register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            result <= 0;
        end else if (current_state == CALC && !Busy_M) begin
            result <= mult_result[31:0]; // Store a portion of the result for observation
        end
    end

endmodule
