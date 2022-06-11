// -----------------------------------------------------------------------------
// Copyright (c) 2014-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : 1598491517@qq.com
// File   : tb_Skid_buffer.v
// Create : 2022-06-11 14:41:17
// Revise : 2022-06-11 15:24:56
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------

`timescale 1 ns/ 1 ps 


module tb_Skid_buffer();

reg clk;
reg rst_n;
reg up_valid;
reg [7:0] up_data;
reg down_ready;
wire my_down_valid;
wire [7:0] my_down_data;
wire my_up_ready;

wire ref_down_valid;
wire [7:0] ref_down_data;
wire ref_up_ready;

wire ref_accept; //accept status signal that indicates whenever input data is accepted by the skid buffer
wire ref_transmit;//transmit status signal that indicates whenever output data is transmitted by the skid buffer
wire my_accept;
wire my_transmit;
reg [3:0] cnt;

initial begin
	clk = 1'b0;
	rst_n = 1'b0;
	up_valid = 1'b0;
	up_data = 'd0;
	down_ready = 1'b0;
	#35
	rst_n = 1'b1;
	down_ready = 1'b0;

	#20
	down_ready = 1'b1;

	#20
	down_ready = 1'b0;

	#20
	down_ready = 1'b1;

	#20
	down_ready = 1'b0;

	#20
	down_ready = 1'b1;

	#20
	down_ready = 1'b0;

	#20
	down_ready = 1'b1;

	#20
	down_ready = 1'b0;

	#20
	down_ready = 1'b1;

	#20
	down_ready = 1'b0;

	#20
	down_ready = 1'b1;

	#20
	down_ready = 1'b0;

	#20
	down_ready = 1'b1;

	#20
	down_ready = 1'b0;

	#20
	down_ready = 1'b1;
end

always @(posedge clk)begin
	if(!rst_n)begin
		up_data <= 'd0;
		up_valid <= 1'b1;
		cnt <= 12;
	end
	else if(ref_accept && my_accept && (cnt != 0))begin
		up_data <= 'd0;
		up_valid <= 1'b0;
		cnt <= cnt - 1;
	end
	else if (up_valid == 1'b0 |(cnt == 0) )begin
		up_data <= {$random}%256;
		up_valid <= 1'b1;
		cnt <= cnt;
	end
end

always #10 clk = ~clk;

	skid_buffer #(
			.DATA_WIDTH(8)
		) inst_skid_buffer (
			.i_clock        (clk),
			.i_aresetn      (rst_n),
			.i_clear        (!rst_n),
			.i_data         (up_data),
			.i_input_valid  (up_valid),
			.i_output_ready (down_ready),
			.o_data         (ref_down_data),
			.o_output_valid (ref_down_valid),
			.o_input_ready  (ref_up_ready),
			.o_accept       (ref_accept),
			.o_transmit     (ref_transmit)
		);

	Handshakes_All #(
			.WORD_WIDTH(8)
		) inst_Handshakes_All (
			.clk         (clk),
			.rst_n       (rst_n),
			.up_valid    (up_valid),
			.up_data     (up_data),
			.down_ready  (down_ready),
			.down_valid  (my_valid),
			.down_data   (my_data),
			.up_ready    (my_up_ready),
			.my_accept   (my_accept),
			.my_transmit (my_transmit)
		);


endmodule