`timescale 1ns / 1ps

module uart_echo(
    input wire clk_p,     // Match XDC [get_ports clk_p]
    input wire clk_n,
    input wire clk_rst,
    input wire rx,
    output wire tx
);
    wire clk;

//     Buffer the differential board clock into a single-ended 125MHz clock
    IBUFDS ibufds_inst (
        .I(clk_p),
        .IB(clk_n),
        .O(clk)
    );
    
    localparam CLK_FREQ=125_000_000;
    localparam BAUD_RATE=115_200;
//    localparam CLK_PERIOD=1_000_000_000/CLK_FREQ;
    localparam CLKS_PER_BIT = CLK_FREQ/BAUD_RATE;

    wire rst = clk_rst;

    reg [7:0] tx_data;
    reg tx_start;
    wire tx_busy;
    
    wire [7:0] rx_data;
    wire rx_valid;
    wire rx_error;

    uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) dut_tx (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx), //tx line, active low, idle high
        .tx_busy(tx_busy)
    );
    
    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) dut_rx (
        .clk(clk),
        .rst(rst),
        .rx(rx), //active low, only start reading when idle and rx low
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .rx_error(rx_error)
    );

//    always @(posedge clk) begin
//        if (rst) begin
//            tx_start<=1'b0;
//            tx_data<=8'd0;
//        end else begin
//            tx_start<=1'b0;
//            if (rx_valid && !tx_busy) begin
//                tx_data<=rx_data;
//                tx_start<=1'b1;
//            end
//        end
//    end

    // Buffer registers to hold Rx data incase it may override current Tx
    reg [7:0] hold_buf;
    reg       has_pending;
    
    always @(posedge clk) begin
        if (rst) begin
            tx_start    <= 1'b0;
            tx_data     <= 8'd0;
            hold_buf    <= 8'd0;
            has_pending <= 1'b0;
        end else begin
            tx_start <= 1'b0; // Default pulse low

            // Store newly received data into buffer
            if (rx_valid) begin
                hold_buf    <= rx_data;
                has_pending <= 1'b1;
            end

            // Trigger TX when idle and data is pending
            if (has_pending && !tx_busy && !tx_start) begin
                tx_data     <= hold_buf;
                tx_start    <= 1'b1;
                has_pending <= 1'b0;
            end
        end
    end

endmodule
