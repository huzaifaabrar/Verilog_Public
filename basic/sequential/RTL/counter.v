`timescale 1ns/1ps

// Simple Synchronous Counter
module counter #(
    parameter WIDTH = 4
)(
    input  wire clk,
    input  wire rst,
    output reg [WIDTH-1:0] count
);
    always @(posedge clk) begin
        if (rst)
            count <= {WIDTH{1'b0}};
        else
            count <= count + 1;
    end
endmodule
