`timescale 1 ns/1 ns
module tb1();
	logic clk,rst;
	logic [31:0] instruction[0:65536];
	logic [31:0] memory[0:65536];
	logic [31:0] register[0:31];
	logic [31:0]aluout;
	datapath uut0(register,clk,rst,instruction,memory,aluout);
	
	initial begin
		#50 clk=0;
		repeat(600)
			#50 clk=~clk;
		$stop;
	end
	initial begin
		#10 rst=1;
		#60 rst=0;
	end
	
endmodule
