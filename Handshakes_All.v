// -----------------------------------------------------------------------------
// Copyright (c) 2014-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : 1598491517@qq.com
// File   : Handshakes_All.v
// Create : 2022-06-09 15:37:03
// Revise : 2022-06-11 15:00:34
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------

module Handshakes_All #
(
	parameter	WORD_WIDTH = 32

)
(
	input	wire						clk,
	input	wire						rst_n,
	input	wire						up_valid,
	input	wire	[WORD_WIDTH-1:0]	up_data,
	input	wire						down_ready,
	output	wire						down_valid,
	output	wire	[WORD_WIDTH-1:0]	down_data,
	output	wire						up_ready,

	output wire							my_accept,
	output wire							my_transmit
);
wire					load_reg_en,sel_reg_en; 
wire 					enable_a,enable_b;
reg 					load_b;//1 means reg a ready,0 means reg b ready
reg						sel_b;//1 means reg a full,0 means reg b full
reg 					buf_valid_a,buf_valid_b;
reg	[WORD_WIDTH-1:0]	buf_data_a,buf_data_b;

assign up_ready = (~buf_valid_a)|(~buf_valid_b);
assign down_valid = (buf_valid_a)|(buf_valid_b);

assign load_reg_en = up_valid & up_ready; // 前半部分建立握手成功，存储一次数据到rega或者regb
always @(posedge clk)begin
	if (!rst_n)begin
		load_b <= 1'b0; //复位至a就绪
	end
	else if(load_reg_en) begin
		load_b <= ~load_b; //存储成功一次，两个寄存器就切换就绪状态一次
	end
end			

assign enable_a = (~load_b) & up_valid & up_ready;
assign enable_b = (load_b) & up_valid & up_ready;//表示a或者b就绪，可以把数据存入a或者b

// always@(posedge clk)begin
// 	if (!rst_n)begin
// 		buf_valid_a <= 'd0;
// 		buf_valid_b <= 'd0;
// 	end
// 	else if(enable_a) begin
// 		buf_valid_a <= 1'b1;
// 		buf_valid_b <= buf_valid_b;
// 	end
// 	else if(enable_b) begin
// 		buf_valid_a <= buf_valid_a;
// 		buf_valid_b <= 1'b1;
// 	end
// 	else begin
// 		buf_valid_a <= buf_valid_a;
// 		buf_valid_b <= buf_valid_b;
// 	end
// end

always@(posedge clk)begin
	if (!rst_n)begin
		buf_data_a <= 'd0;
		buf_data_b <= 'd0;
	end
	else if(enable_a) begin
		buf_data_a <= up_data;
		buf_data_b <= buf_data_b;
	end
	else if(enable_b) begin
		buf_data_b <= up_data;
		buf_data_a <= buf_data_a;
	end
	else begin
		buf_data_a <= buf_data_a;
		buf_data_b <= buf_data_b;
	end
end


assign sel_reg_en = down_valid & down_ready;// 后半部分建立握手成功，rega或者regb的数据被读出

always @(posedge clk)begin
	if (!rst_n)begin
		sel_b <= 1'b0; //复位至a就绪
	end
	else if(sel_reg_en) begin
		sel_b <= ~sel_b; //存储成功一次，两个寄存器就切换就绪状态一次
	end
end		

assign sel_a_over = (~sel_b) & down_valid & down_ready;
assign sel_b_over = (sel_b) & down_valid & down_ready;//表示完成了一次从a或者b读出数据，此信号用于寄存器a或者b的valid还原

always@(posedge clk)begin
	if (!rst_n)begin
		buf_valid_a <= 'd0;
		buf_valid_b <= 'd0;
	end
	else begin
		buf_valid_a <= enable_a?1'b1:(sel_a_over?1'b0:buf_valid_a);
		buf_valid_b <= enable_b?1'b1:(sel_b_over?1'b0:buf_valid_b);
	end
end

assign down_data = sel_b?buf_data_b:buf_data_a;

assign my_accept = load_reg_en;
assign my_transmit = sel_reg_en;
endmodule