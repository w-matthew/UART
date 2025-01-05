module uart_top(
    input  wire       clk,          // System clock (125MHz)
    input  wire       rst,          // Reset (active low)
    input  wire       uart_rx_in,   // UART RX input from USB/Serial
    output wire       uart_tx_out,  // UART TX output to USB/Serial
    input  wire       tx_start,     // Button to start transmission
    input  wire [7:0] tx_data,      // Data to transmit
    output wire [7:0] rx_data,      // Last received data
    output wire       rx_done,      // Pulse when byte received
    output wire       tx_done       // Pulse when transmission done
);

    // Internal wires
    wire tx_active;

    // Instantiate UART TX
    uart_tx tx_inst (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_done(tx_done),
        .tx_active(tx_active),
        .tx_line(uart_tx_out)
    );

    // Instantiate UART RX
    uart_rx rx_inst (
        .clk(clk),
        .rst(rst),
        .rx_data(uart_rx_in),
        .rx_done(rx_done),
        .rx_active(), // Not used externally
        .rx_line(rx_data)
    );

endmodule