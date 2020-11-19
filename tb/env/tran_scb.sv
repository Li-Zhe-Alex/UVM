`ifndef TRAN_SCB__SV
`define TRAN_SCB__SV
class tran_scb extends uvm_scoreboard;
	uvm_blocking_get_port #(slaver_transaction) act_port;  //monitor的输出
	uvm_blocking_get_port #(slaver_transaction) exp_port;  //rm的输出
	slaver_transaction exp_tr[$]; //定义队列
	extern function new(string name, uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);
	`uvm_component_utils(tran_scb)
endclass

function tran_scb::new(string name, uvm_component parent);
	super.new(name, parent);
endfunction

function void tran_scb::build_phase(uvm_phase phase);
	super.build_phase(phase);
	act_port = new("act_port", this);
	exp_port = new("exp_port", this);
endfunction

task tran_scb::main_phase(uvm_phase phase);
	slaver_transaction get_exp_tr;
	slaver_transaction get_act_tr;
	slaver_transaction tmp_exp_tr;  //定义transaction的ID
	fork
		while(1)begin
			exp_port.get(get_exp_tr); //获取期望的数据
			exp_tr.push_back(get_exp_tr);  //把期望的数据push到队列当中并保存。通常rm比dut处理比较快
		end
		while(1)begin
			act_port.get(get_act_tr);  //获取实际的数据
			if(exp_tr.size()>0)begin
				tmp_exp_tr = new();
				tmp_exp_tr = exp_tr.pop_front(); //从队列中取数据
				if(tmp_exp_tr.compare(get_act_tr))begin  //比较
					`uvm_info("my_scb","pass !!! exp is eq act!!!",UVM_NONE);
				end
				else begin
					`uvm_error("my_scb", "exp is not eq act!!!");
					$display("the expect pkt is\n");
					tmp_exp_tr.print();
					$display("the actual pkt is\n");
					get_act_tr.print();
				end
			end
			else begin //没有得到期望的数据
				`uvm_info("my_scoreboard","Received from DUT, while Expect Queue is empty");
				$display("the unexpected pkt is\n");
				get_act_tr.print();
			end
		end
	join
endtask
`endif
				