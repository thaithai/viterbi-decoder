module traceback(
    input wire clk, rst_n,
    input wire en_trb,
    input wire [1:0] min_state,
    input wire [3:0] path_bit,
    output reg [2:0] cnt,
    output reg [7:0] data_out,
    output reg done
);
    reg [1:0] current_state;
    reg trb_active;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt <= 3'd7;
            done <= 1'b0;
            current_state <= 2'b00;
            data_out <= 8'b0;
            trb_active <= 1'b0;
        end
        else begin
            if (en_trb) begin
                if (!trb_active) begin
                    current_state <= min_state;
                    cnt <= 3'd7;
                    trb_active <= 1'b1;
                    done <= 1'b0;
                end else begin
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
                        done <= 1'b1;
                        trb_active <= 1'b0;
                    end else begin
                        cnt <= cnt - 1'b1;
                    end
                end
            end else begin
                done <= 1'b0;
                trb_active <= 1'b0;
            end
        end
    end
endmodule