/*
	module for the asynchronus FIFO, the fifo is used for synchronizing between two clock doamin 
	where data is being sent constantly.
	the fifo consists of internal memory that is written by the sender and then can be read by the reciver.
	the depth of the fifo can be calculated according to the clock doamins frequency and by the data rate.
	full calculation can be found in the readme file.
*/
`timescale 1ps / 1ps
module a_fifo # (parameter FIFO_DEPTH = 16, parameter ADDRESS_LEN = 4)
			 (input logic [7:0] din_clka,
			  input logic wr,
			  input logic rd,
			  input logic clka,
			  input logic clkb,
			  input logic rstb_clkb,
			  input logic rstb_clka,
			  output logic full,
			  output logic [7:0] dout_clkb,
			  output logic empty);

	// inner variables
	logic wr_en;
	logic rd_en;
	logic [ADDRESS_LEN-1:0] comp_rd_ptr;
	logic [ADDRESS_LEN-1:0] comp_wr_ptr;
	logic [ADDRESS_LEN-1:0] q2_sync_clka;
	logic [ADDRESS_LEN-1:0] q2_sync_clkb;
	logic [ADDRESS_LEN-1:0] wr_g_count_clka;
	logic [ADDRESS_LEN-1:0] rd_g_count_clkb;
	logic [ADDRESS_LEN-1:0] dec_in;
	logic [FIFO_DEPTH-1:0] dec_out; 
	logic [7:0] fifo_vec [FIFO_DEPTH - 1:0];
	logic [ADDRESS_LEN-1:0] mux_sel;
	
	// FIFO logic
	
	//////////////////
	// clk a domain //
	//////////////////
	
	assign wr_en = (wr & (~full)); // write enable assignment
	
	// wr ptr - implemented by a gray conter
	gray_counter wr_ptr(.clk(clka), .rstb(rstb_clka), .count_en(wr_en), .g_count(wr_g_count_clka));

	// converting the writepointer to bin for the decoder
	gray2bin dec_in_bin(.gray_in (wr_g_count_clka), .bin_out(dec_in));
	
	// address decoding - the decoder is implemented via this line, there is no need for more complex logic.
	assign dec_out = (wr_en) ? (1'b1 << dec_in) : {ADDRESS_LEN{1'b0}};
	
	// sync data from 'b' domain to 'a' domain
	dff_sync #(.WIDTH(ADDRESS_LEN)) sync_domain_b_to_a(.clk(clka), .resetb(rstb_clka), .d(rd_g_count_clkb), .q(q2_sync_clka));
			
	// check if fifo is full
	gray2bin check_if_full (.gray_in(q2_sync_clka), .bin_out (comp_rd_ptr));
	assign full = ((dec_in + 1'b1) == comp_rd_ptr);
	
	// fifo cells
	genvar i;
	generate
		for (i = 0; i < FIFO_DEPTH; i = i + 1)
		begin
			always_ff @ (posedge clka or negedge rstb_clka)
			begin
				if (~rstb_clka)
					fifo_vec[i] <= 8'b0;
				else if (dec_out[i])
					fifo_vec[i] <= din_clka;
			end
		end
	endgenerate
	
	//////////////////
	// clk b domain //
	//////////////////
	
	assign rd_en = rd & (~empty); // read enable assignment
	
	//rd ptr - implemented by a gray conter                               
	gray_counter #(.RESET_VAL_G(4'b1000)) rd_ptr(.clk(clkb), .rstb(rstb_clkb), .count_en(rd_en), .g_count(rd_g_count_clkb));

	// sync data from 'a' domain to 'b' domain
	dff_sync #(.WIDTH(ADDRESS_LEN)) sync_domain_a_to_b(.clk(clkb), .resetb(rstb_clkb), .d(wr_g_count_clka), .q(q2_sync_clkb));
	
	// check if fifo is empty
	gray2bin check_if_empty (.gray_in(q2_sync_clkb), .bin_out(comp_wr_ptr));
	assign empty = ((mux_sel + 1'b1) == comp_wr_ptr);

	// mux select
	gray2bin mux_sel_bin(.gray_in(rd_g_count_clkb), .bin_out(mux_sel));
			
	// output mux
	assign dout_clkb = fifo_vec[mux_sel];
endmodule
