module SPI_Din #(
    parameter DATA_WIDTH = 16
)(
    input  wire                  clk,
    input  wire                  rst_n,

    // SPI interface (directly from SPI_Dout)
    input  wire                  spi_clk,    // clk_out from SPI_Dout
    input  wire                  spi_din,    // dout    from SPI_Dout
    input  wire                  busy,       // busy    from SPI_Dout

    // Parallel output
    output reg  [DATA_WIDTH-1:0] data_out,
    output reg                   dout_valid  // pulses high for 1 clk when data_out is ready
);

    // ---- Edge detector on spi_clk (sample on rising edge) ----
    reg spi_clk_d1, spi_clk_d2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            spi_clk_d1 <= 1'b0;
            spi_clk_d2 <= 1'b0;
        end else begin
            spi_clk_d1 <= spi_clk;
            spi_clk_d2 <= spi_clk_d1;
        end
    end

    wire spi_clk_rise = spi_clk_d1 && !spi_clk_d2;

    // ---- Edge detector on busy (detect falling edge = transfer done) ----
    reg busy_d1, busy_d2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy_d1 <= 1'b0;
            busy_d2 <= 1'b0;
        end else begin
            busy_d1 <= busy;
            busy_d2 <= busy_d1;
        end
    end

    wire busy_fall = !busy_d1 && busy_d2;

    // ---- Shift register: sample spi_din on every rising edge of spi_clk ----
    reg [DATA_WIDTH-1:0] shift_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            shift_reg <= {DATA_WIDTH{1'b0}};
        else if (spi_clk_rise)
            shift_reg <= {shift_reg[DATA_WIDTH-2:0], spi_din};
    end

    // ---- Output register: latch when busy falls ----
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out   <= {DATA_WIDTH{1'b0}};
            dout_valid <= 1'b0;
        end else begin
            dout_valid <= 1'b0;  // default: deassert after one cycle
            if (busy_fall) begin
                data_out   <= shift_reg;
                dout_valid <= 1'b1;
            end
        end
    end

endmodule
