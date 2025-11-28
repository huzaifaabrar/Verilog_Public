// Parameterizable Full Adder
module full_adder #(
        parameter WIDTH = 1
    )(
        input wire [WIDTH-1:0] a,
        input wire [WIDTH-1:0] b,
        input wire [WIDTH-1:0] cin,
        output wire [WIDTH-1:0] sum,
        output wire [WIDTH-1:0] carry
    );
        assign sum = a ^ b ^ cin;
        assign carry = (a & b) | (b & cin) | (a & cin);
endmodule


// 2:1 Multiplexer (parameterizable width)
module mux2to1 #(
        parameter WIDTH = 1
    )(
        input wire [WIDTH-1:0] d0,
        input wire [WIDTH-1:0] d1,
        input wire sel,
        output wire [WIDTH-1:0] y
    );
        assign y = sel ? d1 : d0;
endmodule


// 1:2 Demultiplexer (parameterizable width)
module demux1to2 #(
        parameter WIDTH = 1
    )(
        input wire [WIDTH-1:0] d,
        input wire sel,
        output wire [WIDTH-1:0] y0,
        output wire [WIDTH-1:0] y1
    );
        assign y0 = sel ? {WIDTH{1'b0}} : d;
        assign y1 = sel ? d : {WIDTH{1'b0}};
endmodule


// 4-bit Comparator (equal, greater, less outputs)
module comparator4(
        input wire [3:0] a,
        input wire [3:0] b,
        output wire eq,
        output wire gt,
        output wire lt
    );
        assign eq = (a == b);
        assign gt = (a > b);
        assign lt = (a < b);
endmodule