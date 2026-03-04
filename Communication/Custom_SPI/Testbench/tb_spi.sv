//------------------------------------------------------------------------------
// Testbench: SPI_Dout → SPI_Din loopback
//
// Verifies:
//   1. SPI_Dout serialises parallel data (MSB first) on clk_out
//   2. SPI_Din deserialises it back to parallel and asserts dout_valid
//   3. Multiple back-to-back transfers
//   4. busy handshake works correctly
//------------------------------------------------------------------------------

`timescale 1ns/1ps

module tb_spi;

    parameter DATA_WIDTH = 16;
    parameter DIV_FACTOR = 2;

    // ---- Clock & reset ----
    reg clk;
    reg rst_n;

    initial clk = 0;
    always #5 clk = ~clk;  // 100 MHz

    // ---- Stimulus signals ----
    reg  [DATA_WIDTH-1:0] tx_data;
    reg                    din_valid;

    // ---- SPI bus wires ----
    wire                   spi_clk;
    wire                   spi_dout;
    wire                   busy;

    // ---- Receiver outputs ----
    wire [DATA_WIDTH-1:0]  rx_data;
    wire                   dout_valid;

    // ---- DUT instantiation ----
    SPI_Dout #(
        .DATA_WIDTH (DATA_WIDTH),
        .DIV_FACTOR (DIV_FACTOR)
    ) u_tx (
        .clk       (clk),
        .rst_n     (rst_n),
        .data_in   (tx_data),
        .din_valid (din_valid),
        .busy      (busy),
        .dout      (spi_dout),
        .clk_out   (spi_clk)
    );

    SPI_Din #(
        .DATA_WIDTH (DATA_WIDTH)
    ) u_rx (
        .clk        (clk),
        .rst_n      (rst_n),
        .spi_clk    (spi_clk),
        .spi_din    (spi_dout),
        .busy       (busy),
        .data_out   (rx_data),
        .dout_valid (dout_valid)
    );

    // ---- Error tracking ----
    integer errors   = 0;
    integer test_num = 0;

    // ---- Task: send one word and verify reception ----
    task send_and_check(input [DATA_WIDTH-1:0] word);
        begin
            test_num = test_num + 1;

            // Wait until transmitter is idle
            @(posedge clk);
            while (busy) @(posedge clk);

            // Load data
            tx_data   = word;
            din_valid = 1'b1;
            @(posedge clk);
            din_valid = 1'b0;

            // Wait for busy to assert
            @(posedge clk);
            while (!busy) @(posedge clk);

            // Wait for transmission to complete (busy falls)
            while (busy) @(posedge clk);

            // Wait for dout_valid pulse from receiver
            @(posedge clk);
            while (!dout_valid) @(posedge clk);

            // Check received data
            if (rx_data === word)
                $display("PASS  Test %0d : TX=0x%04h  RX=0x%04h", test_num, word, rx_data);
            else begin
                $display("FAIL  Test %0d : TX=0x%04h  RX=0x%04h", test_num, word, rx_data);
                errors = errors + 1;
            end
        end
    endtask

    // ---- Main stimulus ----
    initial begin
        $dumpfile("spi_tb.vcd");
        $dumpvars(0, tb_spi);

        // Reset
        rst_n     = 1'b0;
        din_valid = 1'b0;
        tx_data   = '0;
        repeat (4) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        $display("\n===== SPI Loopback Tests =====\n");

        // Test 1: all ones
        send_and_check(16'hFFFF);

        // Test 2: all zeros
        send_and_check(16'h0000);

        // Test 3: alternating pattern
        send_and_check(16'hAAAA);

        // Test 4: inverse alternating
        send_and_check(16'h5555);

        // Test 5: walking one
        send_and_check(16'h0001);

        // Test 6: walking one high
        send_and_check(16'h8000);

        // Test 7: arbitrary data
        send_and_check(16'hDEAD);

        // Test 8: another arbitrary
        send_and_check(16'hBEEF);

        // Test 9: mixed
        send_and_check(16'h1234);

        // Test 10: another mixed
        send_and_check(16'hCAFE);

        // ---- Summary ----
        $display("\n==============================");
        if (errors == 0)
            $display("ALL %0d TESTS PASSED", test_num);
        else
            $display("COMPLETED WITH %0d ERROR(S) out of %0d tests", errors, test_num);
        $display("==============================\n");

        $finish;
    end

    // ---- Timeout watchdog ----
    initial begin
        #500000;
        $display("ERROR: Simulation timed out!");
        $finish;
    end

endmodule
