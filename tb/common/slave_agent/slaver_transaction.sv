//数据格式的定义
`ifndef SLAVER_TRANSACTION__SV
`define SLAVER_TRANSACTION__SV
class slaver_transaction extends uvm_sequence_item;

	rand bit [7:0] data_out;   //sequence想要收的数据，定义信号，进行随机
	rand bit data_out_vld;
	
	function new(string name= "slaver_transaction");
		super.new(name);
	endfunction
	
	`uvm_object_utils_begin(slaver_transaction)
		`uvm_field_int(data_out, UVM_ALL_ON)   //信号注册，sequence自带函数打开，比如print, comp, pack, unpack
		`uvm_field_int(data_out_vld, UVM_ALL_ON)
	`uvm_object_utils_end
endclass
`endif	