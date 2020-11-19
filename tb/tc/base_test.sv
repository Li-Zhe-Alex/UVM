`ifndef BASE_TEST__SV
`define BASE_TEST__SV

class tran_sequence extends uvm_sequence#(master_transaction);//transaction产生激励，在case中，和agent同层，然后给master_agent的sequencer,再driver,再DUT
	master_transaction m_trans;
	function new(string name="tran_sequence");
		super.new(name);
	endfunction
	
	virtual task body();
		if(starting_phase !=null)
			starting_phase.raise_objection(this);
		repeat(10) begin
			`uvm_do(m_trans)//10个master_transaction，uvm_do包含uvm_create(相当于new)和uvm_send
			`uvm_info("tran_sequence", "send one transaction", UVM_NONE)
		end
		#1000;
		if(starting_phase !=null)
			starting_phase.drop_objection(this)
	endtask
	
	`uvm_object_utils(tran_sequence)
endclass

class base_test extends uvm_test;
	tran_env env;
	function new(string name= "base_test", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);
	extern virtual function void report_phase(uvm_phase phase);
	`uvm_component_utils(base_test)
endclass

function void base_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	env = tran_env::type_id::create("env", this);
	uvm_config_db#(uvm_object_wrapper)::set(this,"env.mst_agt.sqr.main_phase","default_sequence",tran_sequence::type_id::get());
	//自动启动tran_sequence，发给mst_agt.sqr
	//多个sequence时使用虚拟sequence来控制启动前后
endfunction

task base_test::main_phase(uvm_phase phase); //前门后门的读写寄存器
	uvm_status_e status;
	uvm_reg_data_t value;
	#100;
	//前门读写，前门相当于模拟总线接口时序
	env.regrm.cfg.read(status, value, UVM_FRONTDOOR);
	`uvm_info("@@@cfg",$sformatf("###000 cfg value is %0h",value), UVM_NONE)
	env.regrm.cfg.write(status, 16'h1, UVM_FRONTDOOR);
	env.regrm.cfg.read(status, value, UVM_FRONTDOOR);
	`uvm_info("@@@cfg",$sformatf("###111 cfg value is %0h",value), UVM_NONE)
	//后门读写，通过dpa,vpa获取对应路径的信号
	env.regrm.cfg.read(status, value, UVM_BACKDOOR); //模仿寄存器行为
	`uvm_info("@@@cfg",$sformatf("###222 cfg value is %0h",value), UVM_NONE)
	env.regrm.cfg.write(status, 16'h0, UVM_BACKDOOR);
	env.regrm.cfg.read(status, value, UVM_BACKDOOR);
	`uvm_info("@@@cfg",$sformatf("###333 cfg value is %0h",value), UVM_NONE)
	//第二种方法后门读写：忽略寄存器类型
	env.regrm.cfg.poke(status, 16'h1); //写
	env.regrm.cfg.peek(status, value); //读
	`uvm_info("@@@cfg",$sformatf("###444 cfg value is %0h",value), UVM_NONE)
	env.regrm.stat.poke(status, 16'h2);
	env.regrm.stat.peek(status, value);
	`uvm_info("@@@stat",$sformatf("###000 stat value is %0h",value), UVM_NONE)
endtask

function void base_test::report_phase(uvm_phase phase);
	uvm_report_server server;
	int err_num;
	super.report_phase(phase);
	`uvm_info(get_type_name(), "report_phase is executed", UVM_NONE)
	server = get_report_server();
	err_num = server.get_severity_count(UVM_ERROR); //获取UVM_ERROR的数量
	if(err_num !=0) begin
		$display("TEST CASE FAILED");
	end
	else begin
		$display("TEST CASE PASSED");
	end
endfunction
`endif
	