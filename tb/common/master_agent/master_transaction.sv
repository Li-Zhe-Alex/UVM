//数据格式的定义
`ifndef MASTER_TRANSACTION__SV
`define MASTER_TRANSACTION__SV
class master_transaction extends uvm_sequence_item;

	rand bit [1:0] data_in0;   //sequence想要发数据，数据进行随机
	rand bit [5:0] data_in1;
	rand bit data_in_vld;
	
	function new(string name= "master_transaction");
		super.new(name);
	endfunction
	
	`uvm_object_utils_begin(master_transaction)
		`uvm_field_int(data_in0, UVM_ALL_ON)   //信号注册，sequence自带函数打开，比如print, comp, pack, unpack
		`uvm_field_int(data_in1, UVM_ALL_ON)
		`uvm_field_int(data_in_vld, UVM_ALL_ON)
	`uvm_object_utils_end
endclass
`endif	