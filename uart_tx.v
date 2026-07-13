`timescale 1ns / 1ps
// lets say clock freq= 25_000_000, and baudrate = 115200
// so clks_per_bit=217
// $clog2(x) return the ceiling of base 2 log of decimal x, 
// so basically how many bits to store from 0 to x

module uart_tx #(
    parameter CLKS_PER_BIT=217 //how many internal clock for one bit
)(
    input wire clk,
    input wire rst,
    input wire tx_start,
    input wire [7:0] tx_data,

    output reg tx, //tx line, active low, idle high
    output reg tx_busy
);

localparam IDLE = 2'd0;
localparam START = 2'd1;
localparam DATA = 2'd2;
localparam STOP = 2'd3;

reg [1:0] state = IDLE;
reg [2:0] bit_idx = 3'd0; //sending 8bit, need to keep track what number of bit has sent
reg [$clog2(CLKS_PER_BIT):0] clk_cnt=0; 
reg [7:0] data = 8'b0;

always @(posedge clk) begin
    if (rst) begin
        state<=IDLE;
        bit_idx<=3'd0;
        clk_cnt<=0;
        tx<= 1'b1;
        tx_busy<=1'b0;
    end else begin
        case (state)

            IDLE: begin
                tx<= 1'b1;
                if (tx_start) begin
                    tx_busy<=1'b1;
                    state<=START;
                    bit_idx<=3'd0;
                    clk_cnt<=0;
                    data<=tx_data;
                end else begin
                    tx_busy<=1'b0;
                end
            end
        
            START: begin
                tx<=1'b0;
                if (clk_cnt==CLKS_PER_BIT-1) begin
                    state<=DATA;
                    bit_idx<=3'd0;
                    clk_cnt<=0;
                end else begin
                    clk_cnt<=clk_cnt+1'b1;
                end
            end
        
            DATA: begin
                tx<=data[bit_idx];
                if (clk_cnt==CLKS_PER_BIT-1) begin
                    clk_cnt<=0;
                    if (bit_idx==3'd7) begin
                        state<=STOP;
                    end else begin
                        bit_idx<=bit_idx+1'b1;
                    end
                end else begin 
                    clk_cnt<=clk_cnt+1;
                end
            end
        
            STOP: begin
                tx<=1'b1;
                if (clk_cnt==CLKS_PER_BIT-1) begin
                    state<=IDLE;
                    bit_idx<=3'd0;
                    clk_cnt<=0;
                    tx_busy<=1'b0;
                end else begin
                    clk_cnt<=clk_cnt+1'b1;
                end
            end

            default: state<=IDLE;
        endcase
    end
end


endmodule