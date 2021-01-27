/******************************************************************************
* DVT CODE TEMPLATE: example test
* Created by moleszkowicz on Jan 22, 2021
* uvc_company = mo, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_mo_alu_example_test
`define IFNDEF_GUARD_mo_alu_example_test

class  mo_alu_example_test extends mo_alu_base_test;

	`uvm_component_utils(mo_alu_example_test)

	function new(string name = "mo_alu_example_test", uvm_component parent);
		super.new(name, parent);
	endfunction: new

	virtual function void build_phase(uvm_phase phase);
		uvm_config_db#(uvm_object_wrapper)::set(this,
			"m_env.m_mo_alu_agent.m_sequencer.run_phase",
			"default_sequence",
			mo_alu_example_sequence::type_id::get());

       	// Create the env
		super.build_phase(phase);
	endfunction

endclass

// TODO Define the default sequence
/*class default_sequence_class extends mo_alu_base_sequence;

	// TODO Declare fields for this sequence
	

	`uvm_object_utils(default_sequence_class)

	function new(string name = "default_sequence_class");
		super.new(name);
	endfunction : new

	virtual task body();
		// TODO implement sequence body
	endtask : body

endclass : default_sequence_class
*/
`endif // IFNDEF_GUARD_mo_alu_example_test
