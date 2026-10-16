module mem_path(
    input wire clk, rst_n,
    input wire en_write,
    input wire en_read,
    input wire [2:0] cnt_write,
    input wire [2:0] cnt_read,
    input wire path_in1,
    input wire path_in2,
    input wire path_in3,
    input wire path_in4,
    output reg [3:0] path_bit,
    output reg mem_done
);
    reg [3:0] mem [7:0];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem[0] <= 4'b0; mem[1] <= 4'b0; mem[2] <= 4'b0; mem[3] <= 4'b0;
            mem[4] <= 4'b0; mem[5] <= 4'b0; mem[6] <= 4'b0; mem[7] <= 4'b0;
            mem_done <= 1'b0;
        end else begin
            if (en_write) begin
                mem[cnt_write] <= {path_in4, path_in3, path_in2, path_in1};
                mem_done <= 1'b1;
            end else begin
                mem_done <= 1'b0;
            end
        end
    end

    always @(*) begin
        if (en_read)
            path_bit = mem[cnt_read];
        else
            path_bit = 4'b0000;
    end
endmodule