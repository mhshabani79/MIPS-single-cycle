# MIPS-single-cycle
this is the verilog-HDL implementation of MIPS32. the processor designed in single cycle mode.  
Project has 2 part:  
**1. Processor:**  
The main verilog code of processor is in [Modules.sv](/Modules.sv) file.  
**2. Test program:**  
a simple test program designed. the binary instructions of test program are in [instruction.txt](/instruction.txt). also the memory file of that program is in [memory.txt](/memory.txt). for case of knowing every binary instruction, we decode every instruction to its Assembly on [Assembly to Bin.txt](/docs/Assembly%20to%20Bin.txt) file.  
## Data path Design
below the RTL design of processpr, attached.
![datapath](/docs/DataPath.jpg)

## Controller Design
**the controlling Signals(wire) state on each instruction:** 
![controller signals](https://user-images.githubusercontent.com/83987665/209701526-62c852a8-b419-483d-af56-e7b92a82c841.png)  
**the ALU function table:** 
![alu function table](https://user-images.githubusercontent.com/83987665/209701697-800b7321-d5e4-4ef2-bfff-4ad8ad288750.png)  
