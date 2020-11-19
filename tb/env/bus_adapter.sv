`ifndef BUS_ADAPTER__SV
`define BUS_ADAPTER__SV
class bus_adapter extends uvm_reg_adapter;

	`uvm_object_utils(bus_adapter)
	
	function new(string name="bus_adapter");
		super.new(name);
	endfunction : new
	//write
	function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
		bus_transaction tr; //实例化
		tr = new("tr"); 
		tr.addr = rw.addr; //传递进来的地址送给tr的地址
		tr.op = (rw.kind == UVM_WRITE)?1:0;
		if (rw.kind == UVM_WRITE)
		tr.wr_data = rw.data; //bus_agent获取transaction类型，通过sequencer传递给driver,最好驱动到接口信号
		return tr;
	endfunction : reg2bus
	//read
	function void bus2reg(uvm_sequence_item bus_item, reg uvm_reg_bus_op rw);
		bus_transaction tr;  
		if(!$cast(tr, bus_item)) begin  //
			`uvm_fatal(get_type_name(),"Provided bus_item is not of the correct type.")
			return;
		endfunction
		rw.kind = (tr.op == 0)? UVM_READ: UVM_WRITE;
		rw.addr = tr.addr;
		rw.data = (tr.op == 0)? tr.rd_data : tr.wr_data;
		rw.status = UVM_IS_OK;
	endfunction: bus2reg
	//读写操作时，实时更新寄存器模型中的实际值和期望值
endclass: bus_adapter
`endif