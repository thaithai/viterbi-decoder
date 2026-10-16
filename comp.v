module comp(
    input wire clk, rst_n,
    input wire [1:0] data_in_2bit,
    input wire en_comp,
    output reg path1,
    output reg path2,
    output reg path3,
    output reg path4,
    output reg [1:0] min_state,
    output reg comp_done, 
    output reg [2:0] cnt_write,
    output reg en_write
);
    reg [2:0] cnt;
    reg [4:0] error_state00, error_state01, error_state10, error_state11;
    reg [1:0] out [7:0];
    wire [1:0] hamming_dist [7:0];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out[0] <= 2'b00; out[1] <= 2'b11;
            out[2] <= 2'b11; out[3] <= 2'b00;
            out[4] <= 2'b10; out[5] <= 2'b01;
            out[6] <= 2'b01; out[7] <= 2'b10;
        end else if (en_comp) begin
            out[0] <= 2'b00; out[1] <= 2'b11; 
            out[2] <= 2'b11; out[3] <= 2'b00; 
            out[4] <= 2'b10; out[5] <= 2'b01; 
            out[6] <= 2'b01; out[7] <= 2'b10; 
        end
    end

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : hd_calc
            assign hamming_dist[i] = (data_in_2bit[0] ^ out[i][0]) + (data_in_2bit[1] ^ out[i][1]);
        end
    endgenerate

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            path1 <= 1'b0; path2 <= 1'b0; path3 <= 1'b0; path4 <= 1'b0;
            min_state <= 2'b00;
            comp_done <= 1'b0;
            cnt <= 3'd0;
            cnt_write <= 3'd0;
            en_write <= 1'b0;
            error_state00 <= 5'd0; error_state01 <= 5'd0;
            error_state10 <= 5'd0; error_state11 <= 5'd0;
        end else if (en_comp) begin
            case (cnt)
                3'd0: begin
                    path1 <= 1'b0; path2 <= 1'b0; path3 <= 1'b0; path4 <= 1'b0;
                    error_state00 <= hamming_dist[0];
                    error_state10 <= hamming_dist[1];
                    error_state01 <= 5'd31; error_state11 <= 5'd31;
                end
                3'd1: begin
                    path1 <= 1'b0; path2 <= 1'b0; path3 <= 1'b0; path4 <= 1'b0;
                    error_state00 <= error_state00 + hamming_dist[0];
                    error_state10 <= error_state00 + hamming_dist[1];
                    error_state01 <= error_state10 + hamming_dist[4];
                    error_state11 <= error_state10 + hamming_dist[5];
                end
                default: begin
                    if ((error_state00 + hamming_dist[0]) <= (error_state01 + hamming_dist[2])) begin
                        path1 <= 1'b0; error_state00 <= error_state00 + hamming_dist[0];
                    end else begin
                        path1 <= 1'b1; error_state00 <= error_state01 + hamming_dist[2];
                    end

                    if ((error_state00 + hamming_dist[1]) <= (error_state01 + hamming_dist[3])) begin
                        path2 <= 1'b0; error_state10 <= error_state00 + hamming_dist[1];
                    end else begin
                        path2 <= 1'b1; error_state10 <= error_state01 + hamming_dist[3];
                    end

                    if ((error_state10 + hamming_dist[4]) <= (error_state11 + hamming_dist[6])) begin
                        path3 <= 1'b0; error_state01 <= error_state10 + hamming_dist[4];
                    end else begin
                        path3 <= 1'b1; error_state01 <= error_state11 + hamming_dist[6];
                    end

                    if ((error_state10 + hamming_dist[5]) <= (error_state11 + hamming_dist[7])) begin
                        path4 <= 1'b0; error_state11 <= error_state10 + hamming_dist[5];
                    end else begin
                        path4 <= 1'b1; error_state11 <= error_state11 + hamming_dist[7];
                    end
                end
            endcase

            // Tìm state có error nhỏ nhất cuối chu kỳ
            if ((error_state00 <= error_state01) && (error_state00 <= error_state10) && (error_state00 <= error_state11))
                min_state <= 2'b00;
            else if ((error_state01 <= error_state00) && (error_state01 <= error_state10) && (error_state01 <= error_state11))
                min_state <= 2'b01;
            else if ((error_state10 <= error_state00) && (error_state10 <= error_state01) && (error_state10 <= error_state11))
                min_state <= 2'b10;
            else
                min_state <= 2'b11;

            cnt_write <= cnt;
            en_write <= 1'b1;
            comp_done <= 1'b1;
            cnt <= cnt + 1'b1;
        end else begin
            en_write <= 1'b0;
            comp_done <= 1'b0;
        end
    end
endmodule