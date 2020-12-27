module tx_module (
    input clk,
    input [7:0] data,
    input data_valid,

    output reg tx,
    output reg tx_busy,
    output reg tx_done
);

reg [2:0] state_tx = 0;
reg [7:0] tx_data = 0;
reg [12:0] clk_count = 0;
reg tx_data_valid = 0;
reg [3:0] bit_pointer = 0;

parameter clk_freq = 25000000;
parameter baudrate = 921600;
parameter bit_clks = clk_freq/baudrate;
parameter half_bit = (bit_clks-1)/2;

localparam idle = 0, start_bit = 1, transmit = 2, stop_bit = 3, new_data = 4;

always @(posedge clk) 
begin
    case (state_tx) 
        idle: begin
            tx <= 1;
            tx_busy <=0;
            tx_done <= 0;
            if(data_valid) begin
                state_tx <= start_bit;
            end
        end 
        start_bit: begin
            tx <= 0;
            tx_busy <=1;
            tx_data <= data;
            if(clk_count == bit_clks-1) begin
                state_tx <= transmit;
                clk_count <= 0;
            end
            else
                clk_count <= clk_count+1;
        end
        transmit: begin
            tx <= tx_data[bit_pointer]; 
            if(clk_count < bit_clks-1) begin   
                state_tx <= transmit;
                clk_count <= clk_count + 1;     
            end   
            else begin
                clk_count <= 0;   
                if(bit_pointer < 7) begin                                    
                    bit_pointer <= bit_pointer+1;
                    state_tx <= transmit;
                end
                else begin
                    bit_pointer <= 0;    
                    state_tx <= stop_bit;
                end
            end
        end
        stop_bit: begin
            if(clk_count == bit_clks-1) begin
                state_tx <= new_data; 
                clk_count <= 0;   
            end
            else begin
                tx <= 1;            
                clk_count <= clk_count + 1;
            end
        end
        new_data: begin
            tx_done <= 1;
            state_tx <= idle;
        end
        default : state_tx <= idle;
    endcase
end
endmodule 