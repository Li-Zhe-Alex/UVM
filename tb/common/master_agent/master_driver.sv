`ifndef MASTER_DRIVER__SV
`define MASTER_DRIVER__SV
class master_driver extends uvm_driver#(master_transaction); //带了括号里的类

	virtual master_interface.DRV vif;   //声明虚拟接口
	uvm_analysis_port #(master_transaction) ap; //声明端口ap
	
	funtion new(string name,uvm_component, parent);
		super.new(name, parent);
	endfunction
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase); //通过config机制获取虚接口
		if(!uvm_config_db#(virtual master_interface)::get(this, "", "vif", vif))
			`uvm_fatal("master_driver", "virtual interface must be set for vif!!!")
		ap = new("ap", this);
	endfunction
	
	virtual task main_phase(uvm_phase phase);
		vif.cb.data_in0 <= 0; //初始化
		vif.cb.data_in1 <= 0;
		vif.cb.data_in_vld <= 0;
		wait(vif.rst_n == 1);
		@vif.cb;	//等待复位完成
		while(1)begin
			seq_item_port.get_next_item(req); //不断从sequencer请求req数据
			ap.write(req); //将数据写入端口ap，最终传递给reference model
			vif.cb.data_in0 <= req.data_in0; //将数据传递给虚接口的信号
			vif.cb.data_in1 <= req.data_in1;
			vif.cb.data_in_vld <= req.data_in_vld;
			@vif.cb;  //打一拍，清零
			vif.cb.data_in0 <= 0;
			vif.cb.data_in1 <= 0;
			vif.cb.data_in_vld <= 0;
			seq_item_port.item_done(); //请求结束
		end
	endtask
	//相当于产生一个transaction激励，然后发生到对应接口
	`uvm_component_utils(master_driver)  //注册
endclass
`endif