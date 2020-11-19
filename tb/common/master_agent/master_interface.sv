`ifndef MASTER_INTERFAC__SV
`define MASTER_INTERFAC__SV
interface master_interface(input clk, input rst_n);
	logic [1:0] data_in0;
	logic [5:0] data_in1;
	logic data_in_vld;  //定义DUT的输入管脚
	
	clocking cb@(posedge clk); //定义时钟块
		output data_in0;
		output data_in1;
		output data_in_vld;    //方向是output,输出给DUT
	endclocking
	
	modport DRV(clocking cb, input rst_n); //插口，把时钟块和复位包含进去
endinterface
`endif