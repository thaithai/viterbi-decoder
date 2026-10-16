`timescale 1ns / 1ps

module tb_top;

    // Khai báo các tín hiệu Testbench kết nối với Top module
    reg clk;
    reg rst_n;
    reg en;
    reg [15:0] data_in;
    
    wire [7:0] data_out;
    wire done;

    // Khởi tạo module Top cần test
    top dut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .data_in(data_in),
        .data_out(data_out),
        .done(done)
    );

    // Tạo xung nhịp clock (Chu kỳ 10ns -> tần số 100MHz)
    always #5 clk = ~clk;

    initial begin
        // 1. Khởi tạo tín hiệu ban đầu
        clk = 0;
        rst_n = 0;
        en = 0;
        data_in = 16'h0000;

        // 2. Reset hệ thống
        #20;
        rst_n = 1;
        #10;

        // 3. Cấp dữ liệu test trực tiếp (Direct Test)
        // Ví dụ: Chuỗi 16-bit dữ liệu mã chập cần giải mã (ví dụ: 16'b1101_1010_0101_1100)
        data_in = 16'b1101101001011100; 
        en = 1; // Bật tín hiệu bắt đầu giải mã
        
        // Giữ tín hiệu en trong 1 chu kỳ clock để Controller nhận lệnh start
        #10;
        en = 0;

        // 4. Chờ cho quá trình tính toán ACS (8 chu kỳ) và Traceback hoàn tất
        // Dùng vòng lặp chờ cho đến khi tín hiệu `done` chuyển lên mức 1
        @(posedge done);
        
        $display("========================================");
        $display("[INFO] Giai ma thanh cong!");
        $display("[INFO] Data In  (16-bit): %b", data_in);
        $display("[INFO] Data Out ( 8-bit): %b", data_out);
        $display("========================================");

        // Thêm một mẫu test thứ 2 (nếu muốn test liên tiếp)
        #20;
        data_in = 16'b0011110010100111;
        en = 1;
        #10;
        en = 0;

        @(posedge done);
        $display("[INFO] Mau test thu 2 hoan tat!");
        $display("[INFO] Data In  (16-bit): %b", data_in);
        $display("[INFO] Data Out ( 8-bit): %b", data_out);
        $display("========================================");

        // Kết thúc mô phỏng
        #50;
        $finish;
    end

    // Giám sát (Monitor) các thay đổi tín hiệu trong quá trình mô phỏng
    initial begin
        $monitor("Time = %0t ns | rst_n = %b | en = %b | done = %b | data_out = %b", 
                 $time, rst_n, en, done, data_out);
    end

endmodule