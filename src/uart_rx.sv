`timescale 1ns / 1ps
`default_nettype none

module uart_rx(
    input wire clk,          // System clock (125MHz)
    input wire rst,          // Active low reset
    //input wire rx_start,     // Start transmission
    input wire rx_data,      // Data to transmit
    output reg rx_done,      // Transmission complete pulse
    output reg rx_active,    // Transmission in progress
    output reg [7:0] rx_line // Serial output line
);

    // state machine states
    localparam IDLE = 2'b00;
    localparam START_BIT = 2'b01;
    localparam DATA_BITS = 2'b10;
    localparam STOP_BIT = 2'b11;

    // For 9600 baud at 125MHz clock:
    // 125000000 / 9600 = 13021 cycles per bit
    localparam CLKS_PER_BIT = 13021;
    localparam OVERSAMPLE_CLK_PER_BIT = 16 * CLKS_PER_BIT;
    localparam CLKS_PER_BIT_HALF = CLKS_PER_BIT / 2;

    // Internal registers
    reg [1:0] state;
    reg [2:0] bit_counter;   // Counts 0 to 7 (8 bits)
    reg [13:0] clk_counter;  // Counts clock cycles for baud rate
                             // 17 = log2(OVERSAMPLE_CLK_PER_BIT)
    reg [7:0] data_reg;      // Holds the data (bit) being transmitted

    always @(posedge clk) begin
        if (!rst) begin
            state <= IDLE;
            bit_counter <= 0;
            clk_counter <= 0;
            data_reg <= 0;
            
            rx_done <= 0;
            rx_active <= 0;
            rx_line <= 8'b1;
        end
        else begin
            case (state)
                IDLE: begin
                    rx_done <= 0;
                    bit_counter <= 0;
                    clk_counter <= 0;

                    if (rx_data == 1'b0) begin
                        state <= START_BIT;
                        rx_active <= 1'b1;
                    end
                end

                START_BIT: begin
                    if (clk_counter < CLKS_PER_BIT_HALF - 1) begin
                        clk_counter <= clk_counter + 1;
                    end
                    else begin
                        if (rx_data == 1'b0) begin
                            clk_counter <= 0;
                            state <= DATA_BITS;
                        end
                        else begin
                            state <= IDLE;
                            rx_active <= 0;
                        end
                    end
                end

                DATA_BITS: begin
                    if (clk_counter < CLKS_PER_BIT - 1) begin
                        clk_counter <= clk_counter + 1;
                    end
                    else begin
                        clk_counter <= 0;
                        data_reg <= {rx_data, data_reg[7:1]};

                        if (bit_counter < 7) begin
                            bit_counter <= bit_counter + 1;
                        end
                        else begin
                            state = STOP_BIT;
                        end
                    end
                end

                STOP_BIT: begin
                    if (clk_counter < CLKS_PER_BIT - 1) begin
                        clk_counter <= clk_counter + 1;
                    end
                    else begin
                        if (rx_data == 1'b1) begin
                            rx_done <= 1'b1;
                            rx_line <= data_reg;
                        end
                        state <= IDLE;
                        rx_active <= 1'b0;
                    end
                end
                
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule