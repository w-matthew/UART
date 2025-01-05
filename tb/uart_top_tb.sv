module uart_top_full_tb();
    // Testbench signals
    reg        clk;
    reg        rst;
    reg        tx_start;
    reg  [7:0] tx_data;
    wire [7:0] rx_data;
    wire       rx_done;
    wire       tx_done;
    wire       uart_tx_out;

    // Instantiate top module with loopback
    uart_top dut (
        .clk(clk),
        .rst(rst),
        .uart_rx_in(uart_tx_out),  // Loopback configuration
        .uart_tx_out(uart_tx_out),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .tx_done(tx_done)
    );

    // Clock generation (125MHz)
    always #4 clk = ~clk;

    // Test stimulus
    initial begin
        // Initialize signals
        clk = 0;
        rst = 0;
        tx_start = 0;
        tx_data = 8'h00;

        // Reset sequence
        #100 rst = 1;
        #100;

        // Send letter 'A' (0x41)
        tx_data = 8'h41;
        tx_start = 1;
        #50 tx_start = 0;

        // Wait for reception
        @(posedge rx_done);
        
        // Verify received data
        if (rx_data === 8'h41)
            $display("Test PASSED: Loopback of 'A' successful");
        else
            $display("Test FAILED: Expected 8'h41, got %h", rx_data);

        // Add some delay
        #100000;

        // Send letter 'B' (0x42)
        tx_data = 8'h42;
        tx_start = 1;
        #50 tx_start = 0;

        // Wait for reception
        @(posedge rx_done);
        
        if (rx_data === 8'h42)
            $display("Test PASSED: Loopback of 'B' successful");
        else
            $display("Test FAILED: Expected 8'h42, got %h", rx_data);

        #100000;
        $finish;
    end

    // Monitor activity
    initial begin
        $monitor("Time=%0t rx_data=%h tx_done=%b rx_done=%b", 
                 $time, rx_data, tx_done, rx_done);
    end

endmodule