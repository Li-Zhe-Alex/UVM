`ifndef SLAVER_INTERFAC__SV
`define SLAVER_INTERFAC__SV
interface slaver_interface(input clk, input rst_n);
	logic [7:0] data_out;
	logic data_out_vld;  //定义DUT的输出管脚
	
	clocking cb@(posedge clk); //定义时钟块
		input data_out;
		input data_out_vld;    //方向是input,从DUT接收
	endclocking
	
	modport MON(clocking cb, input rst_n); //插口，把时钟块和复位包含进去
endinterface
`endif