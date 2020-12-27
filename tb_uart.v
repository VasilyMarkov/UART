`timescale 1 ns / 1 ns

module tb_uart ();
reg clk;

reg [31:0] i_sys_data;
reg sys_tx_data_valid;

wire [31:0] o_sys_data;
wire sys_rx_data_valid;
wire word_busy;

reg [31:0] sys_32bit_data;
reg [1:0] cnt_correct_words = 0;

top_uart top_inst (.clk(clk), 
              .i_sys_data(i_sys_data), 
              .sys_tx_data_valid(sys_tx_data_valid), 
              .o_sys_data(o_sys_data), 
              .sys_rx_data_valid(sys_rx_data_valid), 
              .word_busy(word_busy)
              );
//Принимаем скорость тактирования 25МГц и бодрейт 921600
parameter clk_period = 40; //40ns period
parameter bit_period = 1120; //40*26

always
    #20 clk <= !clk;

initial 
begin
    clk <= 0;
    i_sys_data <= 0;
    sys_tx_data_valid <= 0;
end    

always @(posedge clk) 
begin
    sys_32bit_data <= o_sys_data;
end

always @(posedge clk) //Сравнение данных между входом и выходом буфера
begin
  if(sys_rx_data_valid) begin
    if(sys_32bit_data == i_sys_data) 
      cnt_correct_words<=cnt_correct_words+1;
    else 
    cnt_correct_words<=0;
  end
end

always @(cnt_correct_words) //Если три совпадения, значит работа uart правильная
begin
  if(cnt_correct_words == 3) begin
    $display("Correct uart work at time %t", $time);
    $finish;
  end
end 

task send_data;
  input [31:0] input_data;
begin
  sys_tx_data_valid <= 1;
  i_sys_data <= input_data;
  #80;
  sys_tx_data_valid <= 0;

end
endtask

initial //Отправка 3-х слов размером 32 бита
begin
  #bit_period
  send_data(32'h66666666);
  wait (sys_rx_data_valid);
  repeat (100) begin
  @(posedge clk);
  end
  send_data(32'h77777777);
  @(posedge clk);
  wait (sys_rx_data_valid);
  repeat (100) begin
  @(posedge clk);
  end
  send_data(32'hFFFFFFFF);

end

endmodule