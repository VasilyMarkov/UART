module system_buffer (
    input clk, 
    //RX
    input [7:0] rx_data,
    input rx_data_valid,
    output reg [31:0] sys_data,
    output reg sys_rx_data_valid, 
    //TX
    input [31:0] tx_sys_data,
    input sys_tx_data_valid,
    input uart_tx_busy,
    input uart_tx_done,
    output reg [7:0] tx_data,
    output reg tx_data_valid,
    output reg word_busy
);

reg [2:0] rx_cnt_byte = 0;

always @(posedge clk) 
begin
    if (rx_data_valid) begin		
        case (rx_cnt_byte)
            0: begin
                sys_data[31:24] <= rx_data;
                sys_rx_data_valid <=0;
            end    
            1: begin
                sys_data[23:16] <= rx_data;  
            end    
            2: begin
                sys_data[15:8] <= rx_data;  
            end    
            3: begin
                sys_data[7:0] <= rx_data;                
            end
        endcase  
        rx_cnt_byte <= rx_cnt_byte + 1;
    end 
    else begin
        sys_rx_data_valid <=0;
        if(rx_cnt_byte == 4) begin
             sys_rx_data_valid <=1;
             rx_cnt_byte <= 0; 
        end
    end
end

reg [31:0] tx_word;
reg [1:0] tx_cnt = 0;
reg tx_busy = 0;
reg data_ready = 0;

always @(posedge clk) 
begin
    tx_data_valid <= 0;
    if(sys_tx_data_valid) begin 
        tx_word <= tx_sys_data;
        word_busy <= 1;
        data_ready <= 1;
    end
    if(uart_tx_done) tx_busy <= 0;
    if(data_ready) begin
        if(!tx_busy) begin 
            tx_data_valid <= 1;  
            tx_busy <= 1;
            case (tx_cnt)
                0: tx_data <= tx_word[31:24];
                1: tx_data <= tx_word[23:16];
                2: tx_data <= tx_word[15:8];
                3: begin
                    tx_data <= tx_word[7:0];
                    word_busy <= 0;
                    data_ready <= 0;
                end
            endcase
            tx_cnt <= tx_cnt + 1;
        end 
    end     

end

endmodule 