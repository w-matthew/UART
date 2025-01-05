`timescale 1ns / 1ps
`default_nettype none

module uart_rx_tb();
    // Inputs as reg
    reg clk;
    reg rst;
    reg rx_data;

    // Outputs as wires
    wire rx_done;
    wire rx_active;
    wire [7:0] rx_line;

    // Instantiate UART RX
    uart_rx dut (
        .clk(clk),
        .rst(rst),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .rx_active(rx_active),
        .rx_line(rx_line)
    );

    // Clock generation (125MHz)
    always #4 clk = ~clk;  // 8ns period

    // For 9600 baud, bit period is 13021 clock cycles
    localparam CLKS_PER_BIT = 13021;
    
    // Task to send one byte
    task send_byte;
        input [7:0] data;
        integer i;
        begin
            // Start bit (low)
            rx_data = 1'b0;
            repeat(CLKS_PER_BIT) @(posedge clk);
            
            // Data bits, LSB first
            for (i = 0; i < 8; i = i + 1) begin
                rx_data = data[i];
                repeat(CLKS_PER_BIT) @(posedge clk);
            end
            
            // Stop bit (high)
            rx_data = 1'b1;
            repeat(CLKS_PER_BIT) @(posedge clk);
        end
    endtask

    // Test stimulus
    initial begin
        // Initialize signals
        clk = 0;
        rst = 0;     // Active low reset asserted
        rx_data = 1; // Idle high
        
        // Wait 100ns and release reset
        #100;
        rst = 1;
        #100;

        // Send letter 'a' (0x61 = 01100001)
        $display("Sending 'a' (01100001)");
        send_byte(8'h61);
        
        // Wait to see rx_done
        wait(rx_done);
        
        // Add some delay to see the result
        repeat(1000) @(posedge clk);
        
        // Check if received correctly
        if (rx_line == 8'h61)
            $display("Test PASSED: Received 'a' correctly");
        else
            $display("Test FAILED: Received 0x%h instead of 0x61", rx_line);
        
        // End simulation
        $finish;
    end

    // Monitor changes
    initial begin
        $monitor("Time=%0t rst=%b rx_data=%b rx_active=%b rx_done=%b rx_line=%h",
                 $time, rst, rx_data, rx_active, rx_done, rx_line);
    end

endmodule