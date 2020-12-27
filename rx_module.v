
module rx_module (
    input rx,
    input clk,
    output [7:0] data,
    output data_valid
);

reg [2:0] state_rx = 0;
reg [7:0] rx_data = 0;
reg [12:0] clk_count = 0; 
reg rx_data_valid = 0;
reg [3:0] bit_pointer = 0;

assign data = rx_data;
assign data_valid = rx_data_valid;

parameter clk_freq = 25000000;
parameter baudrate = 921600;
parameter bit_clks = clk_freq/baudrate;
parameter half_bit = (bit_clks-1)/2;

localparam idle = 0, start_bit = 1, receive = 2, stop_bit = 3;

always @(posedge clk)
begin
    case (state_rx)
        idle: begin
            rx_data_valid <= 0;
            clk_count <= 0;
            if(rx == 1'b0)
                state_rx <= start_bit;
            else 
                state_rx <= idle;
        end
        start_bit: begin
            if(clk_count >= half_bit) begin 
                if(rx == 1'b0) begin
                    if(clk_count == half_bit+half_bit-1) begin             
                        state_rx <= receive;
                        clk_count <= 0;
                    end 
                    clk_count <= clk_count+1;              
                end
                else state_rx <= idle;
            end
            else begin
                clk_count <= clk_count+1;
                state_rx <= start_bit;
            end
        end
        receive: begin
            if(clk_count < bit_clks-1) begin   
                state_rx <= receive;
                clk_count <= clk_count + 1;     
            end   
            else begin 
                clk_count <= 0;               
                rx_data[bit_pointer] <= rx;
                if (bit_pointer < 7) begin  
                    bit_pointer <= bit_pointer + 1;
                    state_rx <= receive;
                end
                else begin
                    bit_pointer <= 0;
                    state_rx <= stop_bit;
                end
            end
        end
        stop_bit: begin
            if(clk_count < bit_clks-1) begin   
                state_rx <= stop_bit;
                clk_count <= clk_count + 1;     
            end
            else begin   
                rx_data_valid <= 1;
                state_rx <= idle;
                clk_count <= 0;   
            end
        end
        default: state_rx <= idle;
    endcase

end
endmodule 