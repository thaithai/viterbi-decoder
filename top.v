module top(
    input wire clk, rst_n,
    input wire en,                  // Tín hiệu enable / bắt đầu giải mã
    input wire [15:0] data_in,      // Dữ liệu ngõ vào 16-bit
    output wire [7:0] data_out,     // Chuỗi bit sau khi giải mã hoàn tất
    output wire done                // Cờ báo kết thúc quá trình giải mã
);
    // Tín hiệu nội bộ kết nối các module
    wire [1:0] data_in_2bit;
    wire en_comp;
    wire comp_done;
    
    wire path1, path2, path3, path4;
    wire [1:0] min_state;
    
    wire en_mem;
    wire [2:0] cnt_write;
    wire [3:0] path_bit_to_trb;
    wire mem_done;
    
    wire en_trb;
    wire [2:0] trb_cnt;              // Địa chỉ đọc (cnt_read) xuất từ traceback
    wire trb_done;

    // 1. Khối Controller
    controller u_controller (
        .clk(clk),
        .rst_n(rst_n),
        .start(en),
        .data_in(data_in),
        .comp_done(comp_done),
        .en(en),
        .done(trb_done),
        .data_in_2bit(data_in_2bit),
        .en_comp(en_comp),
        .en_mem(en_mem),
        .en_trb(en_trb)
    );

    // 2. Khối Tính toán ACS (comp)
    comp u_comp (
        .clk(clk),
        .rst_n(rst_n),
        .data_in_2bit(data_in_2bit),
        .en_comp(en_comp),
        .path1(path1),
        .path2(path2),
        .path3(path3),
        .path4(path4),
        .min_state(min_state),
        .comp_done(comp_done),
        .cnt_write(cnt_write),
        .en_write(en_mem)
    );

    // 3. Khối Bộ nhớ đường đi (mem_path)
    mem_path u_mem_path (
        .clk(clk),
        .rst_n(rst_n),
        .en_write(en_mem),
        .en_read(en_trb),
        .cnt_write(cnt_write),
        .cnt_read(trb_cnt),          // Địa chỉ đọc trỏ bởi traceback (cnt)
        .path_in1(path1),
        .path_in2(path2),
        .path_in3(path3),
        .path_in4(path4),
        .path_bit(path_bit_to_trb),
        .mem_done(mem_done)
    );

    // 4. Khối Truy vết ngược (traceback)
    traceback u_traceback (
        .clk(clk),
        .rst_n(rst_n),
        .en_trb(en_trb),
        .min_state(min_state),
        .path_bit(path_bit_to_trb),
        .cnt(trb_cnt),               // Cung cấp cnt_read ra ngoài cho mem_path
        .data_out(data_out),
        .done(trb_done)
    );
    assign done = trb_done;

endmodule