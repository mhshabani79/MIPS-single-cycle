`timescale 1 ns/1 ns
module inst_mem(inst,addr,instruction);
	input [31:0]addr;
	output logic[31:0]inst;
	output logic [31:0]instruction[0:65536];
	
	initial begin
	$readmemb ("instruction.txt",instruction);
	end

	always @(addr) begin
	#5
		inst=instruction[addr>>2];
	end
endmodule
//////////////////////////////
module ALU(z,c,a,b,alusel);
	input [31:0]a,b;
	input [2:0]alusel;
	output logic [31:0]c;
	output z;
	always @(a,b,alusel) begin
		#4
		case(alusel)
			3'b000:c=a+b;
			3'b001:c=a-b;
			3'b010:c=a&b;
			3'b011:c=a|b;
			3'b100:c=(a<b)? 1:0;
		endcase
	end
	assign z=(c==0)?1:0;
endmodule
//////////////////////////////
module PC(parout,parin,clk,rst);
	output logic[31:0]parout;
	input [31:0]parin;
	input clk,rst;
	always @(posedge clk,posedge rst) begin
		#3
		if(rst==1) parout<=32'b0;
		else
		parout<=parin;
	end
endmodule
///////////////////////////////
module MUX(c,a,b,sel);
	output [31:0]c;
	input [31:0]a,b;
	input sel;
	assign #2 c=(sel==1)?b:a;
endmodule
///////////////////////////////
module MUX1(c,a,b,sel);
	output c;
	input a,b;
	input sel;
	assign #2 c=(sel==1)?b:a;
endmodule
///////////////////////////////
module MUX5(c,a,b,sel);
	output [4:0]c;
	input [4:0]a,b;
	input sel;
	assign #2 c=(sel==1)?b:a;
endmodule
///////////////////////////////
module data_mem(clk,readdata,addr,writedata,memread,memwrite,memory);
	input [31:0]addr,writedata;
	input memread,memwrite,clk;
	output logic[31:0]readdata;
	output logic [31:0]memory[0:65536];
	
	initial begin
	$readmemb("memory.txt",memory);
	end

	always @(addr,memread,memwrite) begin
		#5
		if(memread) 
			readdata=memory[addr[17:2]];
		else readdata=32'b0;
	end
	always@(posedge clk) begin
		 #5
		if (memwrite)
			memory[addr[17:2]] = writedata;
	end
endmodule
//////////////////////////////
module reg_file(register,readdata1,readdata2,readreg1,readreg2,writereg,writedata,regwrite,clk);
	input [31:0]writedata;
	input [4:0]readreg1,readreg2,writereg;
	input regwrite,clk;
	output logic[31:0]readdata1,readdata2;
	output logic [31:0]register[0:31];
	
	initial begin
   		register[0]=32'b0;
  	end

	always @(readreg1,readreg2) begin
		#5
			readdata1=register[readreg1];
			readdata2=register[readreg2];
	end

	always @(posedge clk) begin
		#4
		if(regwrite)
			register[writereg]<=writedata;
		else
			register[writereg]<=register[writereg];
	end
endmodule
//////////////////////////////////
module sum(c,a,b);
	output logic[31:0]c;
	input [31:0]a,b;
	
	always @(a,b) begin
		#3
		c=a+b;
	end
endmodule
///////////////////////////////////
module alu_control(alusel,func,aluop);
	input [5:0]func;
	input [1:0]aluop;
	output logic[2:0]alusel;

	always @(aluop,func) begin
		#1
		if(aluop==2'b01) begin
			case(func)
				6'b100000:alusel=3'b000; //add
				6'b100001:alusel=3'b001; //sub	
				6'b100100:alusel=3'b010; //and
				6'b100101:alusel=3'b011; //or
				6'b101010:alusel=3'b100; //slt
			endcase
		end
		else if(aluop==2'b00) alusel=3'b000; //add //jr, addi
		else if(aluop==2'b11) alusel=3'b100; //slt //slti
		else if(aluop==2'b10) alusel=3'b001; //sub  //branches
		else alusel=3'b000;
	end
endmodule
////////////////////
module control(aluop,regdst,regwrite,alusrc,memread,memwrite,memtoreg,branch,notbranch,jsel,r31sel,pc4sel,addrsel,opc);
	input [5:0]opc;
	output logic[1:0] aluop;
	output logic regdst,regwrite,alusrc,memread,memwrite,memtoreg,branch,notbranch,jsel,r31sel,pc4sel,addrsel;

	always @(opc) begin
		#1
		aluop=0; regdst=0; regwrite=0; alusrc=0;  memread=0; memwrite=0; memtoreg=0; branch=0; notbranch=0; jsel=0; r31sel=0; pc4sel=0; addrsel=0;
		case(opc)
			6'b000000:begin aluop=2'b01; regdst=1; regwrite=1; end			//rt
			6'b001000:begin alusrc=1; aluop=2'b00; regwrite=1; end			//addi
			6'b001010:begin alusrc=1; aluop=2'b11; regwrite=1; end			//slti
			6'b100011:begin alusrc=1; memread=1; memtoreg=1; regwrite=1; end	//lw
			6'b101011:begin alusrc=1; memwrite=1; end				//sw
			6'b000100:begin aluop=2'b10; branch=1; end				//beq				
			//6'b000101:begin aluop=2'b10; branch=1; notbranch=1; end			//bne
			6'b000010:begin jsel=1; end						//j
			6'b000011:begin jsel=1; r31sel=1; pc4sel=1; regwrite=1; end		//jal
			6'b000001:begin addrsel=1; jsel=1; end					//jr
		endcase
	end
endmodule
/////////////////////	
module datapath(register,clk,rst,instruction,memory);
	
	input clk,rst;
	output logic [31:0]instruction[0:65536];
	output logic [31:0]memory[0:65536];
	output logic [31:0]register[0:31];

	wire [31:0]pcout,pcin,aluout,readdata1,readdata,writedata1,sumout1,sumout2,shl2,b0,ext,g2,f2,a2,b2,inst,readdata2;
	wire [4:0]e2,writereg;
	wire [2:0]alusel;
	wire [1:0]aluop;
	wire z,notz,andout,d2,regdst,regwrite,alusrc,memread,memwrite,memtoreg,branch,notbranch,jsel,r31sel,pc4sel,addrsel;



	PC p(pcout,pcin,clk,rst);
	inst_mem im(inst,pcout,instruction);
	ALU al(z,aluout,readdata1,g2,alusel);
	data_mem dm(clk,readdata,aluout,readdata2,memread,memwrite,memory);
	reg_file rf(register,readdata1,readdata2,inst[25:21],inst[20:16],writereg,writedata1,regwrite,clk);
	alu_control alcr(alusel,inst[5:0],aluop);
	control cr(aluop,regdst,regwrite,alusrc,memread,memwrite,memtoreg,branch,notbranch,jsel,r31sel,pc4sel,addrsel,inst[31:26]);
	sum s1(sumout1,32'h00000004,pcout);
	sum s2(sumout2,sumout1,shl2);
	
	MUX m1(pcin,a2,b2,jsel);
	MUX m2(b2,b0,readdata1,addrsel);
	MUX m3(a2,sumout1,sumout2,andout);
	MUX1 m4(d2,z,notz,notbranch);
	MUX5 m5(e2,inst[20:16],inst[15:11],regdst);
	MUX5 m6(writereg,e2,5'b11111,r31sel);
	MUX m7(f2,aluout,readdata,memtoreg);
	MUX m8(writedata1,f2,sumout1,pc4sel);
	MUX m9(g2,readdata2,ext,alusrc);
	
	not n1(notz,z);
	and a1(andout,d2,branch);
	assign ext[15:0]=inst[15:0];
	assign ext[31:16]={16{inst[15]}};
	assign shl2={ext[29:0],2'b00};
	assign b0={pcout[31:28],inst[25:0],1'b0,1'b0};

endmodule

