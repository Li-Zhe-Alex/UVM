`ifndef SLAVER_INTERFAC__SV
`define SLAVER_INTERFAC__SV
class slaver_monitor extends uvm_monitor;

	virtual slaver_interface.MON vif;  //声明虚拟接口
	uvm_analysis_port #(slaver_transaction) ap;  //声明虚拟port
	
	function new(string name, uvm_component parent);
		super.new(new,parent);
	endfunction
	
	virtual function void build_phase(uvm_phase phase);   //实例化
		super.build_phase(phase);
		`uvm_info("slaver_monitor","build_phase is called", UVM_LOW);
		if(!uvm_config_db#(virtual slaver_interface)::get(this, "", "vif", vif))
			`uvm_fatal("slaver_monitor","virtual interface must be set for vif!!!")
		ap=new("ap",this);
	endfunction
	
	virtual task main_phase(uvm_phase phase);
		slaver_transaction tr;
		wait(vif.rst_n);  //等待复位完成
		@vif.cb;
		while(1)begin
			tr=new("tr");
			tr.data_out = vif.cb.data_out; //将这个信号传递给transaction的信号
			tr.data_out_vld = vif.cb.data_out_vld;
			if(vif.cb.data_out_vld == 1) ap.write(tr);
			@vif.cb; //当=1时，先把tr写进ap端口。随后传递给scoreboard，等待一个clock
		end
	endtask
	
	`uvm_component_utils(slaver_monitor)
endclass
`endif
	