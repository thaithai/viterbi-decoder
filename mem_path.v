module mem_path(
    input wire clk, rst_n,
    
    input wire en_write,

    input wire [2:0] addr_write,
    input wire [2:0] addr_read,

    input wire [3:0] path,
    
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
                mem[addr_write] <= path;
                if (addr_write == 3'd7) begin
                    mem_done <= 1'b1;
                end else begin
                    mem_done <= 1'b0;
                end
            end else begin
                mem_done <= 1'b0;
            end
        end
    end

    assign path_bit = mem[addr_read];

endmodule
