//------------------------------------------------------------------------------
// Testbench for Sequential Logic: Flip-Flops (D, T, JK), SR Latch, and Counter
//------------------------------------------------------------------------------

`timescale 1ns/1ps

module seq_logic_tb;

    parameter WIDTH = 4;

    // Clock and reset
    reg clk, rst;
    initial clk = 0;
    always #5 clk = ~clk;  // 10ns clock period

    initial begin
        rst = 1; #12;
        rst = 0;
    end

    // D Flip-Flop
    reg  [WIDTH-1:0] d;
    wire [WIDTH-1:0] q_d;
    d_ff #(.WIDTH(WIDTH)) u_dff(.clk(clk), .rst(rst), .d(d), .q(q_d));

    // T Flip-Flop
    reg  [WIDTH-1:0] t;
    wire [WIDTH-1:0] q_t;
    t_ff #(.WIDTH(WIDTH)) u_tff(.clk(clk), .rst(rst), .t(t), .q(q_t));

    // JK Flip-Flop
    reg  [WIDTH-1:0] j, k;
    wire [WIDTH-1:0] q_jk;
    jk_ff #(.WIDTH(WIDTH)) u_jkff(.clk(clk), .rst(rst), .j(j), .k(k), .q(q_jk));

    // SR Latch
    reg  [WIDTH-1:0] s, r;
    wire [WIDTH-1:0] q_latch, q_latch_bar;
    sr_latch #(.WIDTH(WIDTH)) u_srlatch(.s(s), .r(r), .q(q_latch), .q_bar(q_latch_bar));

    // Counter
    wire [WIDTH-1:0] count;
    counter #(.WIDTH(WIDTH)) u_counter(.clk(clk), .rst(rst), .count(count));

    initial begin
        $dumpfile("seq_logic_tb.vcd");
        $dumpvars(0, seq_logic_tb);

        // Initialize inputs
        d = 4'b0001; t = 4'b0001; j = 4'b0001; k = 4'b0000; s = 4'b0000; r = 4'b0000;

        // Apply stimulus to FFs
        #20 d = 4'b0011; t = 4'b0010; j = 4'b0101; k = 4'b0010; s = 4'b1010; r = 4'b0001;
        #20 d = 4'b1111; t = 4'b0101; j = 4'b1111; k = 4'b1010; s = 4'b0101; r = 4'b1010;
        #20 d = 4'b0000; t = 4'b1111; j = 4'b0000; k = 4'b1111; s = 4'b1111; r = 4'b1111;
        #50;

        $display("Sequential logic test complete.");
        $finish;
    end
endmodule