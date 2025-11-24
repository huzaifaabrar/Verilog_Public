// basic gates - vectorizable implementations
// File: gates.v
// Contains implementations for common logic gates with parameterizable width.

`timescale 1ns/1ps

// AND gate (bitwise)
module and_gate #(
    parameter WIDTH = 1
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output wire [WIDTH-1:0] y
);
    assign y = a & b;
endmodule

// OR gate (bitwise)
module or_gate #(
    parameter WIDTH = 1
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output wire [WIDTH-1:0] y
);
    assign y = a | b;
endmodule

// NAND gate (bitwise)
module nand_gate #(
    parameter WIDTH = 1
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output wire [WIDTH-1:0] y
);
    assign y = ~(a & b);
endmodule

// NOR gate (bitwise)
module nor_gate #(
    parameter WIDTH = 1
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output wire [WIDTH-1:0] y
);
    assign y = ~(a | b);
endmodule

// XOR gate (bitwise)
module xor_gate #(
    parameter WIDTH = 1
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output wire [WIDTH-1:0] y
);
    assign y = a ^ b;
endmodule

// XNOR gate (bitwise)
module xnor_gate #(
    parameter WIDTH = 1
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output wire [WIDTH-1:0] y
);
    assign y = ~(a ^ b); // or: assign y = a ~^ b;
endmodule

// NOT (inverter) - bitwise
module not_gate #(
    parameter WIDTH = 1
)(
    input  wire [WIDTH-1:0] a,
    output wire [WIDTH-1:0] y
);
    assign y = ~a;
endmodule

// BUF (buffer) - passthrough
module buf_gate #(
    parameter WIDTH = 1
)(
    input  wire [WIDTH-1:0] a,
    output wire [WIDTH-1:0] y
);
    assign y = a;
endmodule