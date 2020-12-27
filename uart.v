module uart (
    input clk,

    input [7:0] tx_data,
    input tx_data_valid,
    output tx_serial,
    output tx_busy,
    output tx_done,

    input rx_serial,
    output [7:0] rx_data,
    output rx_data_valid
);

tx_module tx_inst1 (.clk(clk),
                    .data(tx_data),
                    .data_valid(tx_data_valid),
                    .tx(tx_serial),
                    .tx_busy(tx_busy),
                    .tx_done(tx_done)
                    );

rx_module rx_inst1 (.clk(clk), 
                    .rx(rx_serial), 
                    .data(rx_data), 
                    .data_valid(rx_data_valid)
);

endmodule 

