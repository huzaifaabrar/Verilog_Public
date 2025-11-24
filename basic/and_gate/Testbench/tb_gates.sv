//------------------------------------------------------------------------------
// Testbench: gates_tb
// Description:
// This testbench verifies all basic logic gate modules (AND, OR, NAND, NOR,
// XOR, XNOR, NOT, BUF). It includes:
// - Waveform dump generation (VCD)
// - Parameterizable vector width
// - Self-checking assertions using an automated check() task
// The testbench applies several input vectors and checks all expected outputs
// against the DUT responses.
//------------------------------------------------------------------------------

`timescale 1ns/1ps

module gates_tb;

    // Parameters
    parameter WIDTH = 4;

    // Test signals
    reg  [WIDTH-1:0] a;
    reg  [WIDTH-1:0] b;
    wire [WIDTH-1:0] y_and,
                     y_or,
                     y_nand,
                     y_nor,
                     y_xor,
                     y_xnor,
                     y_not,
                     y_buf;

    // DUT instantiation
    and_gate  #(.WIDTH(WIDTH)) u_and  (.a(a), .b(b), .y(y_and));
    or_gate   #(.WIDTH(WIDTH)) u_or   (.a(a), .b(b), .y(y_or));
    nand_gate #(.WIDTH(WIDTH)) u_nand (.a(a), .b(b), .y(y_nand));
    nor_gate  #(.WIDTH(WIDTH)) u_nor  (.a(a), .b(b), .y(y_nor));
    xor_gate  #(.WIDTH(WIDTH)) u_xor  (.a(a), .b(b), .y(y_xor));
    xnor_gate #(.WIDTH(WIDTH)) u_xnor (.a(a), .b(b), .y(y_xnor));
    not_gate  #(.WIDTH(WIDTH)) u_not  (.a(a),         .y(y_not));
    buf_gate  #(.WIDTH(WIDTH)) u_buf  (.a(a),         .y(y_buf));

    initial begin
        // Enable waveform dump
        $dumpfile("gates_tb.vcd");
        $dumpvars(0, gates_tb);

        $display("Starting Gate Testbench...");

        // Apply test vectors
        // Self-checking assertions
        task check;
            input [WIDTH-1:0] exp_and,
                              exp_or,
                              exp_nand,
                              exp_nor,
                              exp_xor,
                              exp_xnor,
                              exp_not,
                              exp_buf;
        begin
            if (y_and  !== exp_and)  $display("ASSERT FAIL AND:  expected=%b  got=%b", exp_and, y_and);
            if (y_or   !== exp_or)   $display("ASSERT FAIL OR:   expected=%b  got=%b", exp_or, y_or);
            if (y_nand !== exp_nand) $display("ASSERT FAIL NAND: expected=%b  got=%b", exp_nand, y_nand);
            if (y_nor  !== exp_nor)  $display("ASSERT FAIL NOR:  expected=%b  got=%b", exp_nor, y_nor);
            if (y_xor  !== exp_xor)  $display("ASSERT FAIL XOR:  expected=%b  got=%b", exp_xor, y_xor);
            if (y_xnor !== exp_xnor) $display("ASSERT FAIL XNOR: expected=%b  got=%b", exp_xnor, y_xnor);
            if (y_not  !== exp_not)  $display("ASSERT FAIL NOT:  expected=%b  got=%b", exp_not, y_not);
            if (y_buf  !== exp_buf)  $display("ASSERT FAIL BUF:  expected=%b  got=%b", exp_buf, y_buf);
        end
        endtask

        // Apply test vectors with checking
        a = 4'b0000; b = 4'b1111; #10; check(a & b, a | b, ~(a & b), ~(a | b), a ^ b, ~(a ^ b), ~a, a);
        a = 4'b1010; b = 4'b0101; #10; check(a & b, a | b, ~(a & b), ~(a | b), a ^ b, ~(a ^ b), ~a, a);
        a = 4'b1111; b = 4'b1111; #10; check(a & b, a | b, ~(a & b), ~(a | b), a ^ b, ~(a ^ b), ~a, a);
        a = 4'b0011; b = 4'b1100; #10; check(a & b, a | b, ~(a & b), ~(a | b), a ^ b, ~(a ^ b), ~a, a);

        // End simulation
        $display("Simulation complete.");
        $finish;
    end

endmodule
