`timescale 1ns/1ps

// D Flip-Flop with synchronous reset
module d_ff #(
    parameter WIDTH = 1
)(
    input  wire clk,
    input  wire rst,     // synchronous reset
    input  wire [WIDTH-1:0] d,
    output reg  [WIDTH-1:0] q
);
    always @(posedge clk) begin
        if (rst)
            q <= {WIDTH{1'b0}};
        else
            q <= d;
    end
endmodule


// T Flip-Flop with synchronous reset
module t_ff #(
    parameter WIDTH = 1
)(
    input  wire clk,
    input  wire rst,
    input  wire [WIDTH-1:0] t,
    output reg  [WIDTH-1:0] q
);
    always @(posedge clk) begin
        if (rst)
            q <= {WIDTH{1'b0}};
        else
            q <= q ^ t;  // toggle
    end
endmodule


// JK Flip-Flop with synchronous reset
module jk_ff #(
    parameter WIDTH = 1
)(
    input  wire clk,
    input  wire rst,
    input  wire [WIDTH-1:0] j,
    input  wire [WIDTH-1:0] k,
    output reg  [WIDTH-1:0] q
);
    always @(posedge clk) begin
        if (rst)
            q <= {WIDTH{1'b0}};
        else
            q <= (j & ~q) | (~k & q);  // JK characteristic
    end
endmodule


// SR Latch (Set-Reset Latch)
module sr_latch #(
    parameter WIDTH = 1
)(
    input  wire [WIDTH-1:0] s,
    input  wire [WIDTH-1:0] r,
    output reg  [WIDTH-1:0] q,
    output wire [WIDTH-1:0] q_bar
);
    assign q_bar = ~q;

    always @(*) begin
        case ({s, r})
            {WIDTH{2'b00}}: q = q;        // hold
            {WIDTH{2'b01}}: q = {WIDTH{1'b0}}; // reset
            {WIDTH{2'b10}}: q = {WIDTH{1'b1}}; // set
            {WIDTH{2'b11}}: q = {WIDTH{1'bx}}; // invalid
        endcase
    end
endmodule
