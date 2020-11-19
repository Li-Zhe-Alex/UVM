`ifndef MASTER_DRIVER__SV
`define MASTER_DRIVER__SV
class master_agent extends uvm_agent;
	master_driver drv;
	master_sequencer sqr; //先声明
	
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction
	
	virtual function void build_pahse(uvm_phase phase);
		super.build_phase(phase);
		if(is_active == UVM_ACTIVE) begin
			drv = master_driver::type_id::create("drv", this);
			sqr = master_sequencer::type_id::create("sqr",this); //在build_phase创建
		end
	endfunction
	
	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase); //在connect_phase中进行port口连接
		if(is_active == UVM_ACTIVE) begin
			drv.seq_item_port.connect(sqr.seq_item_export);  //把driver和sequencer的端口连接
		end
	endfunction
	
	`uvm_component_utils(master_agent)
	
endclass
`endif