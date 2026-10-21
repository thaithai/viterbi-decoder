module traceback( // xem lai traceback
    input wire clk, rst_n,
    
    input wire en_trb,           // Xung kích hoạt 1 nhịp (nối trực tiếp từ mem_done)

    input wire [1:0] min_state,
    input wire [3:0] path_bit,

    output wire [2:0] addr_read,
    output reg [7:0] data_out,
    output reg done
);
    reg [1:0] current_state;
    reg [2:0] cnt;
    reg       running;          // Cờ nội bộ để tự chạy đủ 8 chu kỳ sau khi nhận xung kích hoạt

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt           <= 3'd7;
            done          <= 1'b0;
            current_state <= 2'b00;
            data_out      <= 8'b0;
            running       <= 1'b0;
        end
        else begin
            if (en_trb && !running) begin
                running       <= 1'b1;
                cnt           <= 3'd7;
                current_state <= min_state; 
                done          <= 1'b0;
            end 
            else if (running) begin
                case (current_state)
                    2'b00: begin
                        current_state <= {1'b0, path_bit[0]};
                        data_out[cnt] <= path_bit[0];
                    end
                    2'b01: begin
                        current_state <= {1'b1, path_bit[1]};
                        data_out[cnt] <= path_bit[1];
                    end
                    2'b10: begin
                        current_state <= {1'b0, path_bit[2]};
                        data_out[cnt] <= path_bit[2];
                    end
                    2'b11: begin
                        current_state <= {1'b1, path_bit[3]};
                        data_out[cnt] <= path_bit[3];
                    end
                endcase
                
                if (cnt == 3'd0) begin
                    running <= 1'b0; // Đã chạy xong 8 chu kỳ
                    done    <= 1'b1; // Bật tín hiệu hoàn tất
                end else begin
                    cnt     <= cnt - 1'b1;
                    done    <= 1'b0;
                end
            end 
            else begin
                done <= 1'b0;
            end
        end
    end

    assign addr_read = cnt;
endmodule
