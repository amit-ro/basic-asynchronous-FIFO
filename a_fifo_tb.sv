/*
	testbench for the asynchronus fifo
*/
`timescale 1ps / 1ps
module a_fifo_tb();
	
	logic [7:0] din_clka_t;
	logic wr_t;
	logic rd_t;
	logic clka_t;
	logic clkb_t;
	logic rstb_clka_t;
	logic rstb_clkb_t;
	logic full_t;
	logic [7:0] dout_clkb_t;
	logic empty_t;
	int i;

	a_fifo a_fifo_DUT(.din_clka(din_clka_t),
					  .wr(wr_t),
					  .rd(rd_t),
					  .clka(clka_t),
					  .clkb(clkb_t),
					  .rstb_clkb(rstb_clkb_t),
					  .rstb_clka(rstb_clka_t),
					  .full(full_t),
					  .dout_clkb(dout_clkb_t),
					  .empty(empty_t));
	
	
	
	initial
	begin
		{wr_t, rd_t, clka_t, clkb_t, rstb_clkb_t, rstb_clka_t} = 1'b0;
		din_clka_t = 8'b0;
		
		fork
			forever
			begin
				#6.25ns
				clka_t = ~clka_t;
			end
			//#5ns
			forever
			begin
				#10ns;
				clkb_t = ~clkb_t;
			end
		join
	end
	
	initial
	begin
		#50ns;
		@ (posedge clkb_t);
		rstb_clkb_t = 1'b1;
		rstb_clka_t = 1'b1;
		
		#40ns;
		@ (posedge clka_t);
		wr_t = 1'b1;
		din_clka_t = 8'b1100_1010;
		
		@ (posedge clka_t);
		wr_t = 1'b0;
		din_clka_t = 8'b0;
		
		#60ns;
		@ (posedge clkb_t)
		rd_t = 1'b1;
		@ (posedge clkb_t)
		rd_t = 1'b0;
		
		#30ns;
		@ (posedge clka_t);
		wr_t = 1'b1;
		for (i = 0; i < 10; i++)
		begin
			@ (posedge clka_t);
			din_clka_t = din_clka_t + 1'b1;
		end
		wr_t = 1'b0;
		
		#100ns;
		@ (posedge clkb_t);
		rd_t = 1'b1;

		#400ns;
		@ (posedge clkb_t);
		rd_t = 1'b0;
		@ (posedge clka_t);
		wr_t = 1'b1;
		din_clka_t = 8'b1111_1010;
	end
endmodule
