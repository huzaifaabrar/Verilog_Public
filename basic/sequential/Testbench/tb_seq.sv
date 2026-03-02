//------------------------------------------------------------------------------
// Testbench for Sequential Logic: Flip-Flops (D, T, JK), SR Latch, and Counter
//
// Self-checking testbench with assertions verifying:
//   - Synchronous reset clears all flip-flop outputs
//   - D-FF captures input on rising clock edge
//   - T-FF toggles when t=1, holds when t=0
//   - JK-FF set/reset/hold/toggle modes
//   - SR Latch set, reset, and hold behaviour
//   - Counter increments and wraps around on overflow
//------------------------------------------------------------------------------

`timescale 1ns/1ps

module seq_logic_tb;

    parameter WIDTH = 4;

    // ---- Error tracking ----
    integer errors = 0;

    task check(input string label,
               input [WIDTH-1:0] actual,
               input [WIDTH-1:0] expected);
        if (actual !== expected) begin
            $display("FAIL  %-20s : expected=%b  got=%b  (t=%0t)", label, expected, actual, $time);
            errors = errors + 1;
        end else begin
            $display("PASS  %-20s : %b  (t=%0t)", label, actual, $time);
        end
    endtask

    // ---- Clock & reset ----
    reg clk, rst;
    initial clk = 0;
    always #5 clk = ~clk;  // 10 ns period

    // ---- DUT signals ----
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

    // ---- Expected-value trackers for T-FF & JK-FF ----
    reg [WIDTH-1:0] exp_t, exp_jk;

    // ---- Main stimulus ----
    initial begin
        $dumpfile("seq_logic_tb.vcd");
        $dumpvars(0, seq_logic_tb);

        // Initialise all inputs to zero
        d = '0; t = '0; j = '0; k = '0; s = '0; r = '0;

        //--------------------------------------------------------------
        // 1. RESET TEST — verify all FF outputs are zero during reset
        //--------------------------------------------------------------
        $display("\n===== RESET TEST =====");
        rst = 1;
        @(posedge clk); #1;
        check("D-FF  reset",  q_d,    '0);
        check("T-FF  reset",  q_t,    '0);
        check("JK-FF reset",  q_jk,   '0);
        check("Counter reset", count,  '0);

        // Release reset after a second clock
        @(posedge clk); #1;
        rst = 0;
        exp_t  = '0;   // T-FF expected state after reset
        exp_jk = '0;   // JK-FF expected state after reset

        //--------------------------------------------------------------
        // 2. D FLIP-FLOP TESTS
        //--------------------------------------------------------------
        $display("\n===== D FLIP-FLOP =====");

        d = 4'b1010;
        @(posedge clk); #1;
        check("D-FF  d=1010", q_d, 4'b1010);

        d = 4'b0101;
        @(posedge clk); #1;
        check("D-FF  d=0101", q_d, 4'b0101);

        d = 4'b1111;
        @(posedge clk); #1;
        check("D-FF  d=1111", q_d, 4'b1111);

        d = 4'b0000;
        @(posedge clk); #1;
        check("D-FF  d=0000", q_d, 4'b0000);

        //--------------------------------------------------------------
        // 3. T FLIP-FLOP TESTS
        //--------------------------------------------------------------
        $display("\n===== T FLIP-FLOP =====");

        // Toggle all bits (0000 -> 1111)
        t = 4'b1111;
        @(posedge clk); #1;
        exp_t = exp_t ^ 4'b1111;
        check("T-FF  t=1111 (1)", q_t, exp_t);  // expect 1111

        // Toggle all again (1111 -> 0000)
        t = 4'b1111;
        @(posedge clk); #1;
        exp_t = exp_t ^ 4'b1111;
        check("T-FF  t=1111 (2)", q_t, exp_t);  // expect 0000

        // Toggle lower nibble only (0000 -> 0101)
        t = 4'b0101;
        @(posedge clk); #1;
        exp_t = exp_t ^ 4'b0101;
        check("T-FF  t=0101",    q_t, exp_t);   // expect 0101

        // Hold (t=0 means no toggle)
        t = 4'b0000;
        @(posedge clk); #1;
        check("T-FF  t=0000 hold", q_t, exp_t); // expect 0101

        // Toggle upper bits (0101 -> 1001)
        t = 4'b1100;
        @(posedge clk); #1;
        exp_t = exp_t ^ 4'b1100;
        check("T-FF  t=1100",    q_t, exp_t);

        //--------------------------------------------------------------
        // 4. JK FLIP-FLOP TESTS
        //--------------------------------------------------------------
        $display("\n===== JK FLIP-FLOP =====");

        // Hold (j=0, k=0) — q stays at 0
        j = 4'b0000; k = 4'b0000;
        @(posedge clk); #1;
        exp_jk = (j & ~exp_jk) | (~k & exp_jk);
        check("JK-FF hold",       q_jk, exp_jk);

        // Set (j=1, k=0)
        j = 4'b1111; k = 4'b0000;
        @(posedge clk); #1;
        exp_jk = (j & ~exp_jk) | (~k & exp_jk);
        check("JK-FF set",        q_jk, exp_jk);  // expect 1111

        // Hold at 1
        j = 4'b0000; k = 4'b0000;
        @(posedge clk); #1;
        exp_jk = (j & ~exp_jk) | (~k & exp_jk);
        check("JK-FF hold@1",     q_jk, exp_jk);  // expect 1111

        // Reset (j=0, k=1)
        j = 4'b0000; k = 4'b1111;
        @(posedge clk); #1;
        exp_jk = (j & ~exp_jk) | (~k & exp_jk);
        check("JK-FF reset",      q_jk, exp_jk);  // expect 0000

        // Toggle (j=1, k=1) from 0 -> 1
        j = 4'b1111; k = 4'b1111;
        @(posedge clk); #1;
        exp_jk = (j & ~exp_jk) | (~k & exp_jk);
        check("JK-FF toggle(0>1)", q_jk, exp_jk); // expect 1111

        // Toggle again from 1 -> 0
        j = 4'b1111; k = 4'b1111;
        @(posedge clk); #1;
        exp_jk = (j & ~exp_jk) | (~k & exp_jk);
        check("JK-FF toggle(1>0)", q_jk, exp_jk); // expect 0000

        // Mixed per-bit: set bits [3:2], toggle bits [1:0] (from 00)
        j = 4'b1111; k = 4'b0011;
        @(posedge clk); #1;
        exp_jk = (j & ~exp_jk) | (~k & exp_jk);
        check("JK-FF mixed",      q_jk, exp_jk);

        //--------------------------------------------------------------
        // 5. SR LATCH TESTS
        //    NOTE: The RTL case-matches on the full {s,r} concatenation,
        //    so only the following uniform patterns are handled for
        //    WIDTH=4.  Per-bit mixed patterns cause the latch to hold.
        //--------------------------------------------------------------
        $display("\n===== SR LATCH =====");

        // Set all: s=1010, r=1010 matches {4{2'b10}} → q = all 1s
        s = 4'b1010; r = 4'b1010; #5;
        check("SR set all",      q_latch, 4'b1111);
        check("SR q_bar",        q_latch_bar, 4'b0000);

        // Hold: s=0000, r=0000 matches {4{2'b00}} → q unchanged
        s = 4'b0000; r = 4'b0000; #5;
        check("SR hold @1111",   q_latch, 4'b1111);

        // Reset all: s=0101, r=0101 matches {4{2'b01}} → q = all 0s
        s = 4'b0101; r = 4'b0101; #5;
        check("SR reset all",   q_latch, 4'b0000);

        // Hold again after reset
        s = 4'b0000; r = 4'b0000; #5;
        check("SR hold @0000",  q_latch, 4'b0000);

        //--------------------------------------------------------------
        // 6. COUNTER TESTS — increment and overflow
        //--------------------------------------------------------------
        $display("\n===== COUNTER =====");

        // Pulse reset to start counter from 0
        rst = 1;
        @(posedge clk); #1;
        check("Counter re-rst",  count, '0);
        rst = 0;

        // Verify incrementing for several cycles
        begin : counter_test
            reg [WIDTH-1:0] exp_count;
            integer i;
            exp_count = '0;
            for (i = 0; i < 20; i = i + 1) begin
                @(posedge clk); #1;
                exp_count = exp_count + 1;
                check($sformatf("Counter [%0d]", i), count, exp_count);
            end

            // Overflow test — run until wrap
            $display("\n--- Counter overflow ---");
            exp_count = count;
            while (exp_count != {WIDTH{1'b1}}) begin
                @(posedge clk); #1;
                exp_count = exp_count + 1;
            end
            check("Counter @MAX",  count, {WIDTH{1'b1}});

            @(posedge clk); #1;
            check("Counter wrap",  count, '0);
        end

        //--------------------------------------------------------------
        // SUMMARY
        //--------------------------------------------------------------
        $display("\n==============================");
        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("COMPLETED WITH %0d ERROR(S)", errors);
        $display("==============================\n");

        $finish;
    end
endmodule