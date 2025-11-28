//------------------------------------------------------------------------------
// Testbenches for Half Adder, Full Adder, MUX, DEMUX, Comparator
//------------------------------------------------------------------------------

`timescale 1ns/1ps

// Half Adder & Full Adder Testbench
module adder_tb;
    parameter WIDTH = 4;

    reg  [WIDTH-1:0] a, b, cin;
    wire [WIDTH-1:0] sum_half, carry_half;
    wire [WIDTH-1:0] sum_full, carry_full;

    half_adder #(.WIDTH(WIDTH)) u_half(.a(a), .b(b), .sum(sum_half), .carry(carry_half));
    full_adder #(.WIDTH(WIDTH)) u_full(.a(a), .b(b), .cin(cin), .sum(sum_full), .carry(carry_full));

    initial begin
        $dumpfile("adder_tb.vcd");
        $dumpvars(0, adder_tb);

        // Test vectors
        a = 4'b0000; b = 4'b0000; cin = 4'b0000; #10;
        a = 4'b1010; b = 4'b0101; cin = 4'b0011; #10;
        a = 4'b1111; b = 4'b1111; cin = 4'b1111; #10;
        a = 4'b0011; b = 4'b1100; cin = 4'b0101; #10;

        $display("Adder test complete.");
        $finish;
    end
endmodule

// 2:1 MUX Testbench
module mux_tb;
    parameter WIDTH = 4;
    reg  [WIDTH-1:0] d0, d1;
    reg  sel;
    wire [WIDTH-1:0] y;

    mux2to1 #(.WIDTH(WIDTH)) u_mux(.d0(d0), .d1(d1), .sel(sel), .y(y));

    initial begin
        $dumpfile("mux_tb.vcd");
        $dumpvars(0, mux_tb);

        d0 = 4'b0000; d1 = 4'b1111; sel = 0; #10;
        sel = 1; #10;
        d0 = 4'b1010; d1 = 4'b0101; sel = 0; #10;
        sel = 1; #10;

        $display("MUX test complete.");
        $finish;
    end
endmodule

// 1:2 DEMUX Testbench
module demux_tb;
    parameter WIDTH = 4;
    reg  [WIDTH-1:0] d;
    reg  sel;
    wire [WIDTH-1:0] y0, y1;

    demux1to2 #(.WIDTH(WIDTH)) u_demux(.d(d), .sel(sel), .y0(y0), .y1(y1));

    initial begin
        $dumpfile("demux_tb.vcd");
        $dumpvars(0, demux_tb);

        d = 4'b1100; sel = 0; #10;
        sel = 1; #10;
        d = 4'b1010; sel = 0; #10;
        sel = 1; #10;

        $display("DEMUX test complete.");
        $finish;
    end
endmodule

// 4-bit Comparator Testbench
module comparator_tb;
    reg  [3:0] a, b;
    wire eq, gt, lt;

    comparator4 u_cmp(.a(a), .b(b), .eq(eq), .gt(gt), .lt(lt));

    initial begin
        $dumpfile("comparator_tb.vcd");
        $dumpvars(0, comparator_tb);

        a = 4'b0000; b = 4'b0000; #10;
        a = 4'b1010; b = 4'b0101; #10;
        a = 4'b1111; b = 4'b1111; #10;
        a = 4'b0011; b = 4'b1100; #10;

        $display("Comparator test complete.");
        $finish;
    end
endmodule