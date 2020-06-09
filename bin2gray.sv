`timescale 1ps / 1ps
module bin2gray #(parameter NUMBER_OF_BITS = 4)
				(input logic [NUMBER_OF_BITS - 1:0] bin_in,
				output logic [NUMBER_OF_BITS - 1:0] gray_out);
	
	assign gray_out = (bin_in>>1) ^ bin_in;
	
endmodule
