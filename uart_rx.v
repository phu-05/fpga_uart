`timescale 1ns / 1ps
// lets say clock freq= 25_000_000, and baudrate = 115200
// so clks_per_bit=217

// $clog2(x) return the ceiling of base 2 log of decimal x, 
// so basically how many bits to store from 0 to x

module uart_rx #(
    parameter CLKS_PER_BIT=217 //how many internal clock for one bit
)(
    input wire clk,
    input wire rst,
    input wire rx, //active low, only start reading when idle and rx low

    output reg[7:0] rx_data,
    output reg rx_valid, 
    output reg rx_error
);

localparam HALF_CLKS_PER_BIT=CLKS_PER_BIT/2;

localparam IDLE = 2'd0;
localparam START = 2'd1;
localparam DATA = 2'd2;
localparam STOP = 2'd3;

reg [1:0] state = IDLE;
reg [2:0] bit_idx = 3'd0; //sending 8bit, need to keep track what number of bit has sent
reg [$clog2(CLKS_PER_BIT)-1:0] clk_cnt=0; 
reg [7:0] data = 8'b0;

//since fpga and pc hose use different clock, use 2-flipflop-sync to prevent metastability
reg rx_sync0 =1'b1;
reg rx_sync1 =1'b1;
always @(posedge clk) begin
    rx_sync0<=rx;
    rx_sync1<=rx_sync0;
end

always @(posedge clk) begin
    if (rst) begin
        state<=IDLE;
        bit_idx<=3'd0;
        clk_cnt<=0;
        rx_valid<=1'b0;
        rx_error<=1'b0;
    end else begin
        rx_valid<=1'b0;
        rx_error<=1'b0;
        case (state)
            IDLE: begin 
                if (rx_sync1==1'b0) begin
                    state<=START;
                    clk_cnt<=0;
                end
            end

            //instead of waiting for the end of START BIT, 
            //we transition at half START BIT so that we can read at mid point next data
            START: begin
                if (clk_cnt==HALF_CLKS_PER_BIT-1) begin  
                    if (rx_sync1==1'b0) begin 
                        state<=DATA;
                        bit_idx<=3'd0;
                        clk_cnt<=0;
                        data<=8'b0;
                    end else begin
                        state<=IDLE;//a glitch, not actual START BIT
                    end
                end else begin
                    clk_cnt<=clk_cnt+1;
                end
            end

            DATA: begin 
                if (clk_cnt==CLKS_PER_BIT-1) begin
                    clk_cnt<=0;
                    data[bit_idx]<=rx_sync1;
                    if (bit_idx==3'd7) begin
                        state<=STOP;
                    end else begin 
                        bit_idx<=bit_idx+1;
                    end
                end else begin
                    clk_cnt<=clk_cnt+1;
                end
            end

            STOP: begin
                if (clk_cnt==CLKS_PER_BIT-1) begin
                    clk_cnt<=0;
                    if (rx_sync1==1'b1) //expect mid point of stop bit is high
                    begin
                        rx_data<=data;
                        rx_valid<=1'b1; //signal high valid for 1 clock
                    end else begin
                        rx_error<=1'b1;
                    end
                    state<=IDLE;
                end else begin
                    clk_cnt<=clk_cnt+1;
                end
            end

            default: state<=IDLE;
        endcase
    end
end


endmodule
