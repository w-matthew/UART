`timescale 1ns / 1ps
`default_nettype none

module uart_tx_tb();
    // Inputs as reg
    reg clk;
    reg rst;
    reg tx_start;
    reg [7:0] tx_data;

    // Outputs as wires
    wire tx_done;
    wire tx_active;
    wire tx_line;

    // Instantiate UART TX
    uart_tx dut (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_done(tx_done),
        .tx_active(tx_active),
        .tx_line(tx_line)
    );

    // Clock generation (125MHz)
    always #4 clk = ~clk;  // 8ns period

    // Test stimulus
    initial begin
        // Initialize signals
        clk = 0;
        rst = 0;     // Active low reset asserted
        tx_start = 0;
        tx_data = 8'h00;

        // Wait a few clock cycles
        #100;
        
        // Release reset
        rst = 1;
        #100;

        // Send "katia"
        // 'k' = 01101011
        $display("Sending 'k' (01101011)");
        tx_data = 8'b01101011;
        tx_start = 1;
        #50;
        tx_start = 0;
        wait(tx_done);
        #100000;  // Wait between characters

        // 'a' = 01100001
        $display("Sending 'a' (01100001)");
        tx_data = 8'b01100001;
        tx_start = 1;
        #50;
        tx_start = 0;
        wait(tx_done);
        #100000;

        // 't' = 01110100
        $display("Sending 't' (01110100)");
        tx_data = 8'b01110100;
        tx_start = 1;
        #50;
        tx_start = 0;
        wait(tx_done);
        #100000;

        // 'i' = 01101001
        $display("Sending 'i' (01101001)");
        tx_data = 8'b01101001;
        tx_start = 1;
        #50;
        tx_start = 0;
        wait(tx_done);
        #100000;

        // 'a' = 01100001
        $display("Sending 'a' (01100001)");
        tx_data = 8'b01100001;
        tx_start = 1;
        #50;
        tx_start = 0;
        wait(tx_done);
        #200000;  // Extra wait at end

        // End simulation
        $display("Test completed - sent 'katia'");
        $finish;
    end

    // Monitor changes
    initial begin
        $monitor("Time=%0t rst=%b tx_start=%b tx_data=%b tx_active=%b tx_line=%b tx_done=%b",
                 $time, rst, tx_start, tx_data, tx_active, tx_line, tx_done);
    end

endmodule