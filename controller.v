module controller(
    input wire clk, rst_n,
    input wire start,
    input wire [15:0] data_in,
    input wire comp_done,
    input wire en,
    input wire done,               // Nhận tín hiệu done từ traceback để kết thúc
    output reg [1:0] data_in_2bit,
    output reg en_comp,
    output reg en_mem,
    output reg en_trb
);
    parameter IDLE      = 2'b00;
    parameter PROCESS   = 2'b01;
    parameter TRACEBACK = 2'b10;

    reg [1:0] state, next_state;
    reg [2:0] chunk_cnt;
    reg [15:0] shift_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            chunk_cnt <= 3'd0;
            shift_reg <= 16'b0;
        end else begin
            state <= next_state;
            case (state)
                IDLE: begin
                    chunk_cnt <= 3'd0;
                    if (start && en) begin
                        shift_reg <= data_in;
                    end
                end
                PROCESS: begin
                    if (comp_done) begin
                        chunk_cnt <= chunk_cnt + 1'b1;
                        shift_reg <= shift_reg >> 2;
                    end
                end
                TRACEBACK: begin
                    if (done) begin
                        chunk_cnt <= 3'd0;
                    end
                end
            endcase
        end
    end

    always @* begin
        next_state   = state;
        en_comp      = 1'b0;
        en_mem       = 1'b0;
        en_trb       = 1'b0;
        data_in_2bit = shift_reg[1:0];

        case (state)
            IDLE: begin
                if (start && en) begin
                    next_state = PROCESS;
                end
            end
            PROCESS: begin
                en_comp = 1'b1;
                data_in_2bit = shift_reg[1:0];
                if (comp_done) begin
                    en_mem = 1'b1;
                    if (chunk_cnt == 3'd7) begin
                        next_state = TRACEBACK;
                    end
                end
            end
            TRACEBACK: begin
                en_trb = 1'b1;
                if (done) begin
                    next_state = IDLE;
                end
            end
            default: next_state = IDLE;
        endcase
    end
endmodule