`timescale 1ns / 1ps
`default_nettype none

module uart_tx(
    input wire clk,          // System clock (125MHz)
    input wire rst,          // Active low reset
    input wire tx_start,     // Start transmission
    input wire [7:0] tx_data, // Data to transmit
    output reg tx_done,      // Transmission complete pulse
    output reg tx_active,    // Transmission in progress
    output reg tx_line       // Serial output line
);

    // State machine states
    localparam IDLE = 2'b00;
    localparam START_BIT = 2'b01;
    localparam DATA_BITS = 2'b10;
    localparam STOP_BIT = 2'b11;

    // For 9600 baud at 125MHz clock:
    // 125000000 / 9600 = 13021 cycles per bit
    localparam CLKS_PER_BIT = 13021;

    // Internal registers
    reg [1:0] state;
    reg [2:0] bit_counter;   // Counts 0 to 7 (8 bits)
    reg [13:0] clk_counter;  // Counts clock cycles for baud rate
    reg [7:0] data_reg;      // Holds the data being transmitted

    // State machine
    always @(posedge clk) begin
        if (!rst) begin
            state <= IDLE;
            tx_line <= 1'b1;     // Idle line is high
            tx_active <= 1'b0;
            tx_done <= 1'b0;
            bit_counter <= 0;
            clk_counter <= 0;
            data_reg <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    tx_line <= 1'b1;        // Idle line is high
                    tx_done <= 1'b0;        // Clear done flag
                    bit_counter <= 0;
                    clk_counter <= 0;
                    
                    if (tx_start) begin
                        state <= START_BIT;
                        tx_active <= 1'b1;
                        data_reg <= tx_data; // Sample data
                    end
                    else begin
                        tx_active <= 1'b0;
                    end
                end

                START_BIT: begin
                    tx_line <= 1'b0;        // Start bit is low
                    
                    if (clk_counter < CLKS_PER_BIT - 1) begin
                        clk_counter <= clk_counter + 1;
                    end
                    else begin
                        clk_counter <= 0;
                        state <= DATA_BITS;
                    end
                end

                DATA_BITS: begin
                    tx_line <= data_reg[bit_counter];  // LSB first
                    
                    if (clk_counter < CLKS_PER_BIT - 1) begin
                        clk_counter <= clk_counter + 1;
                    end
                    else begin
                        clk_counter <= 0;
                        
                        if (bit_counter < 7) begin
                            bit_counter <= bit_counter + 1;
                        end
                        else begin
                            state <= STOP_BIT;
                        end
                    end
                end

                STOP_BIT: begin
                    tx_line <= 1'b1;    // Stop bit is high
                    
                    if (clk_counter < CLKS_PER_BIT - 1) begin
                        clk_counter <= clk_counter + 1;
                    end
                    else begin
                        tx_done <= 1'b1;
                        tx_active <= 1'b0;
                        state <= IDLE;
                    end
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule