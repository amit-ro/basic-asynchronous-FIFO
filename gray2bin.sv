`timescale 1ps / 1ps
module gray2bin #(parameter NUMBER_OF_BITS = 4)
				(input logic [NUMBER_OF_BITS - 1:0] gray_in,
				output logic [NUMBER_OF_BITS - 1:0] bin_out);
	genvar i;
	generate
		for (i = 0; i < NUMBER_OF_BITS; i = i+1)
		begin
			assign bin_out[i] = ^gray_in[NUMBER_OF_BITS - 1:i];
		end
	endgenerate
endmodule
