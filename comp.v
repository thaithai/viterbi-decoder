module comp (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [1:0]  data_in_2bit,
    input  wire        en_comp,

    output reg  [3:0]  path,          
    output reg  [1:0]  min_state,
    output reg         comp_done,

    output reg  [2:0]  addr_write,
    output reg         en_write
);
    reg [2:0] cnt;
    reg [4:0] error_state00, error_state01, error_state10, error_state11;

    localparam [1:0] out0 = 2'b00;   // state 00 --0--> 00
    localparam [1:0] out1 = 2'b11;   // state 00 --1--> 10
    localparam [1:0] out2 = 2'b11;   // state 01 --0--> 00
    localparam [1:0] out3 = 2'b00;   // state 01 --1--> 10
    localparam [1:0] out4 = 2'b10;   // state 10 --0--> 01
    localparam [1:0] out5 = 2'b01;   // state 10 --1--> 11
    localparam [1:0] out6 = 2'b01;   // state 11 --0--> 01
    localparam [1:0] out7 = 2'b10;   // state 11 --1--> 11

    wire [1:0] hamming_dist [0:7];

    assign hamming_dist[0] = (data_in_2bit[0] ^ out0[0]) + (data_in_2bit[1] ^ out0[1]);
    assign hamming_dist[1] = (data_in_2bit[0] ^ out1[0]) + (data_in_2bit[1] ^ out1[1]);
    assign hamming_dist[2] = (data_in_2bit[0] ^ out2[0]) + (data_in_2bit[1] ^ out2[1]);
    assign hamming_dist[3] = (data_in_2bit[0] ^ out3[0]) + (data_in_2bit[1] ^ out3[1]);
    assign hamming_dist[4] = (data_in_2bit[0] ^ out4[0]) + (data_in_2bit[1] ^ out4[1]);
    assign hamming_dist[5] = (data_in_2bit[0] ^ out5[0]) + (data_in_2bit[1] ^ out5[1]);
    assign hamming_dist[6] = (data_in_2bit[0] ^ out6[0]) + (data_in_2bit[1] ^ out6[1]);
    assign hamming_dist[7] = (data_in_2bit[0] ^ out7[0]) + (data_in_2bit[1] ^ out7[1]);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            path            <= 4'b0000;
            min_state       <= 2'b00;
            
            comp_done       <= 1'b0;
            cnt             <= 3'd0;
            addr_write      <= 3'd0;
            en_write        <= 1'b0;
            
            error_state00   <= 5'd0;
            error_state01   <= 5'd0;
            error_state10   <= 5'd0;
            error_state11   <= 5'd0;
        end
        else if (en_comp) begin
            case (cnt)
                3'd0: begin
                    error_state00   <= hamming_dist[0];
                    error_state10   <= hamming_dist[1];
                    // error_state01   <= 5'd31;
                    // error_state11   <= 5'd31;
                end
                3'd1: begin
                    error_state00   <= error_state00 + hamming_dist[0];
                    error_state10   <= error_state00 + hamming_dist[1];
                    error_state01   <= error_state10 + hamming_dist[4];
                    error_state11   <= error_state10 + hamming_dist[5];
                end
                default: begin
                    if ((error_state00 + hamming_dist[0]) <= (error_state01 + hamming_dist[2])) begin
                        path[0]         <= 1'b0;
                        error_state00   <= error_state00 + hamming_dist[0];
                    end else begin
                        path[0]         <= 1'b1;
                        error_state00   <= error_state01 + hamming_dist[2];
                    end

                    if ((error_state00 + hamming_dist[1]) <= (error_state01 + hamming_dist[3])) begin
                        path[2]         <= 1'b0;             
                        error_state10   <= error_state00 + hamming_dist[1];
                    end else begin
                        path[2]         <= 1'b1;
                        error_state10   <= error_state01 + hamming_dist[3];
                    end

                    if ((error_state10 + hamming_dist[4]) <= (error_state11 + hamming_dist[6])) begin
                        path[1]         <= 1'b0;                 
                        error_state01   <= error_state10 + hamming_dist[4];
                    end else begin
                        path[1]         <= 1'b1;
                        error_state01   <= error_state11 + hamming_dist[6];
                    end

                    if ((error_state10 + hamming_dist[5]) <= (error_state11 + hamming_dist[7])) begin
                        path[3]         <= 1'b0;                 
                        error_state11   <= error_state10 + hamming_dist[5];
                    end else begin
                        path[3]         <= 1'b1;
                        error_state11   <= error_state11 + hamming_dist[7];
                    end
                end
            endcase

            addr_write  <= cnt;
            en_write    <= 1'b1;
            comp_done   <= 1'b1;
            cnt         <= cnt + 1'b1;
        end
        else begin
            en_write  <= 1'b0;
            comp_done <= 1'b0;
        end
    end

    always @(*) begin
        if ( (error_state00 <= error_state01) && (error_state00 <= error_state10) && (error_state00 <= error_state11) )
            min_state = 2'b00;
        else if ( (error_state01 <= error_state00) && (error_state01 <= error_state10) && (error_state01 <= error_state11) )
            min_state = 2'b01;
        else if ( (error_state10 <= error_state00) && (error_state10 <= error_state01) && (error_state10 <= error_state11) )
            min_state = 2'b10;
        else
            min_state = 2'b11;
    end
endmodule
