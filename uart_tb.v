`timescale 1ns / 1ps

module uart_tb;
    localparam CLK_FREQ=25_000_000;
    localparam BAUD_RATE=115_200;
    localparam CLK_PERIOD=1_000_000_000/CLK_FREQ;
    localparam CLKS_PER_BIT = CLK_FREQ/BAUD_RATE;

    reg clk=0;
    reg rst=1;
    
    reg [7:0] tx_data;
    reg tx_start;
    wire tx_busy;
    wire tx;
    
    wire [7:0] rx_data;
    wire rx_valid;
    wire rx_error;
    
    always #(CLK_PERIOD/2) clk = ~clk;
    
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
        .rx(tx), //active low, only start reading when idle and rx low
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .rx_error(rx_error)
    );
    
    initial begin


        //System Initialization & Reset
        tx_data = 8'h00;
        tx_start = 0;
        
        #(CLK_PERIOD * 10);
        rst = 0; // Release reset
        
        #(CLK_PERIOD * 10);
        
        tx_data=8'd67;
        tx_start=1;
        #(CLK_PERIOD); // Let tx_start register in next posedge
        tx_start = 0; 
    end
    
endmodule
