/*
	basic gray code counter module
*/
`timescale 1ps / 1ps
module gray_counter #(parameter NUMBER_OF_BITS = 4, parameter RESET_VAL_G = {NUMBER_OF_BITS{1'b0}})
					(input logic clk,
					 input logic rstb,
					 input logic count_en,
					 output logic [NUMBER_OF_BITS - 1: 0] g_count);

	// variable decleration
	logic [NUMBER_OF_BITS-1:0] inc_mux;
	logic [NUMBER_OF_BITS-1:0] data_in;
	logic [NUMBER_OF_BITS-1:0] b_count;
	
	gray2bin #(.NUMBER_OF_BITS(NUMBER_OF_BITS)) bin_count (.gray_in(g_count), .bin_out(b_count));
	
	assign inc_mux = count_en ? b_count + 1'b1 : b_count;
	
	bin2gray #(.NUMBER_OF_BITS(NUMBER_OF_BITS)) g_in (.bin_in(inc_mux), .gray_out(data_in));
	
	always_ff @ (posedge clk or negedge rstb)
	begin
		if (~rstb)
			g_count <= RESET_VAL_G;
		else
			g_count <= data_in;
	end
endmodule
					
		

