
module top_uart (
    input clk,
    input [31:0] i_sys_data,
    input sys_tx_data_valid,
 
    output [31:0] o_sys_data,
    output sys_rx_data_valid,
    output word_busy
);

wire uart_tx_busy;
wire uart_tx_done;
wire [7:0] sys_to_uart_data;
wire [7:0] uart_to_sys_data;
wire tx_data_valid;
wire rx_data_valid;
wire serial_line;
wire maj_line;

uart uart_inst (.clk(clk), 
                .tx_data(sys_to_uart_data), 
                .tx_data_valid(tx_data_valid),
                .rx_data(uart_to_sys_data),
                .rx_serial(maj_line),
                .tx_serial(serial_line),
                .tx_busy(uart_tx_busy),
                .tx_done(uart_tx_done),
                .rx_data_valid(rx_data_valid)
                );

system_buffer buf_inst( .clk(clk), 
                        .tx_sys_data(i_sys_data), //32 bit system input data
                        .sys_tx_data_valid(sys_tx_data_valid), //system input data valid
                        .sys_data(o_sys_data), // 32 bit system output data
                        .sys_rx_data_valid(sys_rx_data_valid), //system output data valid
                        .uart_tx_busy(uart_tx_busy),
                        .uart_tx_done(uart_tx_done), //
                        .tx_data(sys_to_uart_data),
                        .tx_data_valid(tx_data_valid),
								.rx_data_valid(rx_data_valid),
                        .word_busy(word_busy),
								.rx_data(uart_to_sys_data)
                      );

RXMajority3Filter inst1 (.clk(clk), .rxIN(serial_line), .rxOUT(maj_line));

endmodule

module RXMajority3Filter
(
	input clk,
	input rxIN,
	output wire rxOUT
);

reg [2:0] rxLock = 3'b111;

assign rxOUT = (rxLock[0] & rxLock[1]) | (rxLock[0] & rxLock[2]) | (rxLock[1] & rxLock[2]);

always @(posedge clk) begin
	rxLock <= {rxIN, rxLock[2:1]};
end

endmodule