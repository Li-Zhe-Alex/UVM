`ifndef REG_MODEL__SV
`define REG_MODEL__SV
//两个寄存器，configure负责配置，stat负责回读实时状态
class reg_cfg extends uvm_reg;
	rand uvm_reg_field reserved; //两个域段
	rand uvm_reg_field cfg;
	virtual function void build(); //创建
		reserved = uvm_reg_field::type_id::create("reserved");
		cfg = uvm_reg_field::type_id::create("cfg");
		reserved.configure(this, 15, 1, "RO", 0, 15'h0, 1, 1, 0); //配置
		cfg.configure(this, 1, 0, "RW", 0, 1'h0, 1, 1, 0);
	endfunction
	`uvm_object_utils(reg_cfg)
	function new(input string name = "reg_cfg");
		super.new(name, 16, UVM_NO_COVERAGE);
	endfunction
endclass

class reg_stat extends uvm_reg; //包含4个域段
	rand uvm_reg_field reserved;
	rand uvm_object_utils stat2;
	rand uvm_object_utils stat1;
	rand uvm_object_utils stat0;
	virtual function void build();
		reserved = uvm_object_field::type_id::create("reserved");
		stat2 = uvm_object_field::type_id::create("stat2");
		stat1 = uvm_object_field::type_id::create("stat1");
		stat0 = uvm_object_field::type_id::create("stat0");
		reserved.configure(this, 13, 3, "RO", 0, 13'h0, 1, 1, 0);
		stat2.configure(this, 1, 2, "RO", 0, 1'h0, 1, 1, 0);
		stat1.configure(this, 1, 1, "RO", 0, 1'h0, 1, 1, 0);
		stat0.configure(this, 1, 0, "RO", 0, 1'h0, 1, 1, 0);
	endfunction
	`uvm_object_utils(reg_stat)
	function new(input string name = "reg_stat");
		super.new(name, 16, UVM_NO_COVERAGE);
	endfunction
endclass

class reg_model extends uvm_reg_block;
	rand reg_cfg cfg;  //声明句饼
	rand reg_stat stat;
	virtual function void build();
		default_map = create_map("default_map", 0, 2, UVM_BIG_ENDIAN, 0); //创建，2代表2个byte=16bits
		
		cfg = reg_cfg::type_id::create("cfg"); //创建实例化
		cfg.configure(this, null, "cfg"); //配置一下，第三个参数代表后门路径
		cfg.build();  //创建
		default_map.add_reg(cfg, 'h9, "RW"); //把这个寄存器加进去，第二个参数代表地址，第三个代表类型（读写）。
		
		stat = reg_stat::type_id::create("stat");
		stat.configure(this, null, "stat");
		stat.build();
		default_map.add_reg(stat, 'h8, "RO"); //readonly
	endfunction
	
	`uvm_object_utils(reg_model)
	
	function new(input string name = "reg_model");
		super.new(name, UVM_NO_COVERAGE);
	endfunction
endclass
`endif