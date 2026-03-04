module SPI_Dout #(
    parameter DATA_WIDTH  = 16,
    parameter DIV_FACTOR  = 2   // clk_out freq = clk freq / (2 * DIV_FACTOR)
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire [DATA_WIDTH-1:0] data_in,
    input  wire                  din_valid,  // pulse high for 1 clk cycle when data_in is ready

    output reg                   busy,       // high while transmitting
    output reg                   dout,       // serial data out (MSB first)
    output reg                   clk_out     // SPI clock — only toggles during transmission
);

    // ---- Clock divider ----
    localparam CNT_WIDTH = (DIV_FACTOR == 1) ? 1 : $clog2(DIV_FACTOR);
    reg [CNT_WIDTH-1:0] clk_count;
    wire                clk_tick;  // pulses once per half-period of clk_out

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            clk_count <= 0;
        else if (!busy)
            clk_count <= 0;
        else if (clk_count == DIV_FACTOR - 1)
            clk_count <= 0;
        else
            clk_count <= clk_count + 1;
    end

    assign clk_tick = busy && (clk_count == DIV_FACTOR - 1);

    // ---- clk_out generation (only toggles while busy) ----
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            clk_out <= 1'b0;
        else if (!busy)
            clk_out <= 1'b0;          // idle low
        else if (clk_tick)
            clk_out <= ~clk_out;
    end

    // ---- Bit counter ----
    localparam BIT_CNT_WIDTH = $clog2(DATA_WIDTH);
    reg [BIT_CNT_WIDTH-1:0] bit_cnt;

    // ---- Shift register ----
    reg [DATA_WIDTH-1:0] shift_reg;

    // ---- FSM: IDLE → TRANSMIT → done ----
    localparam IDLE     = 1'b0,
               TRANSMIT = 1'b1;
    reg state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            busy      <= 1'b0;
            shift_reg <= {DATA_WIDTH{1'b0}};
            bit_cnt   <= 0;
            dout      <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    dout <= 1'b0;
                    if (din_valid) begin
                        shift_reg <= data_in;
                        bit_cnt   <= 0;
                        busy      <= 1'b1;
                        dout      <= data_in[DATA_WIDTH-1]; // drive MSB immediately
                        state     <= TRANSMIT;
                    end
                end

                TRANSMIT: begin
                    // Shift on the falling edge of clk_out (rising clk_tick while clk_out==1)
                    if (clk_tick && clk_out) begin
                        if (bit_cnt == DATA_WIDTH - 1) begin
                            // All bits sent
                            busy  <= 1'b0;
                            dout  <= 1'b0;
                            state <= IDLE;
                        end else begin
                            shift_reg <= {shift_reg[DATA_WIDTH-2:0], 1'b0};
                            dout      <= shift_reg[DATA_WIDTH-2]; // next MSB
                            bit_cnt   <= bit_cnt + 1;
                        end
                    end
                end
            endcase
        end
    end

endmodule
