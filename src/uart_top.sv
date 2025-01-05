module uart_top(
    input wire clk,          // 125MHz system clock
    input wire rst,          // Reset button/signal
    input wire tx_start,     // Button/signal to start transmission
    input wire [7:0] tx_data, // Data to transmit
    output wire tx_done,     // Transmission complete signal
    output wire tx_active,   // Transmission in progress signal
    output wire tx_line      // UART TX line to USB/Serial port
);

    // Instantiate UART TX
    uart_tx transmitter (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_done(tx_done),
        .tx_active(tx_active),
        .tx_line(tx_line)
    );

endmodule