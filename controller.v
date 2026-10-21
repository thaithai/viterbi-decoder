module controller(
    input  wire        clk, 
    input  wire        rst_n,
    input  wire [15:0] data_in,
    input  wire        en,
    input  wire        done_comp,   
    
    output reg  [1:0]  data_in_2bit,
    output reg         en_comp             
);
    reg [15:0] shift_reg;
    reg [2:0]  cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_in_2bit <= 2'b00;
            shift_reg    <= 16'b0;
            en_comp      <= 1'b0;
            cnt          <= 3'd0;
        end else begin
            if (en && !en_comp) begin
                // Bắt đầu chu kỳ xử lý 16-bit mới
                shift_reg    <= {data_in[13:0], 2'b00}; // Dịch sẵn để lấy các cặp bit sau
                data_in_2bit <= data_in[15:14];         // Lấy ngay 2 bit đầu tiên (cặp số 0)
                en_comp      <= 1'b1;
                cnt          <= 3'd1;
            end else if (en_comp) begin
                if (cnt == 3'd7) begin
                    // Đã xử lý đủ 8 cặp bit (đủ 8 chu kỳ clock)
                    en_comp      <= 1'b0;
                    cnt          <= 3'd0;
                    data_in_2bit <= 2'b00;
                end else begin
                    // Lấy cặp 2 bit tiếp theo ở các chu kỳ tiếp theo
                    data_in_2bit <= shift_reg[15:14];
                    shift_reg    <= {shift_reg[13:0], 2'b00};
                    cnt          <= cnt + 1'b1;
                end
            end
        end      
    end
endmodule
