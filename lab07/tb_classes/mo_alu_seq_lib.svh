/******************************************************************************
* DVT CODE TEMPLATE: sequence library
* Created by moleszkowicz on Jan 22, 2021
* uvc_company = mo, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_mo_alu_seq_lib
`define IFNDEF_GUARD_mo_alu_seq_lib

//------------------------------------------------------------------------------
//
// CLASS: mo_alu_base_sequence
//
//------------------------------------------------------------------------------

virtual class mo_alu_base_sequence extends uvm_sequence#(mo_alu_item);
	
	`uvm_declare_p_sequencer(mo_alu_sequencer)

	function new(string name="mo_alu_base_sequence");
		super.new(name);
	endfunction : new

	virtual task pre_body();
		//uvm_phase starting_phase = get_starting_phase();
		if (starting_phase!=null) begin
			`uvm_info(get_type_name(),
				$sformatf("%s pre_body() raising %s objection",
					get_sequence_path(),
					starting_phase.get_name()), UVM_MEDIUM)
			starting_phase.raise_objection(this);
		end
	endtask : pre_body

	virtual task post_body();
		//uvm_phase starting_phase = get_starting_phase();
		if (starting_phase!=null) begin
			`uvm_info(get_type_name(),
				$sformatf("%s post_body() dropping %s objection",
					get_sequence_path(),
					starting_phase.get_name()), UVM_MEDIUM)
			starting_phase.drop_objection(this);
		end
	endtask : post_body

endclass : mo_alu_base_sequence

//------------------------------------------------------------------------------
//
// CLASS: mo_alu_example_sequence
//
//------------------------------------------------------------------------------

class mo_alu_example_sequence extends mo_alu_base_sequence;

	// Add local random fields and constraints here

	`uvm_object_utils(mo_alu_example_sequence)

	function new(string name="mo_alu_example_sequence");
		super.new(name);
	endfunction : new

	virtual task body();
		`uvm_do_with(req,
			{ /* TODO add constraints here*/ } )
		get_response(rsp);
	endtask : body

endclass : mo_alu_example_sequence

class min_max_sequence extends mo_alu_base_sequence;
    `uvm_object_utils(min_max_sequence)

    mo_alu_item command;

    function new(string name = "min_max_sequence");
        super.new(name);
    endfunction : new

    task body();
        `uvm_info("SEQ_MAXMULT", "", UVM_MEDIUM)
//      command = sequence_item::type_id::create("command");
//      start_item(command);
//      command.op = mul_op;
//      command.A = 8'hFF;
//      command.B = 8'hFF;
//      finish_item(command);
 //       `uvm_do_with(command, {op == sub_op; A == 32'hFF; B == 8'hFF;})
`uvm_create(command)
`uvm_send(command)
repeat(20000)begin
	`uvm_rand_send_with(command, { command.A dist {32'h00000000:=2000, [32'h00000001 : 32'hFFFFFFFD]:=0, 32'hFFFFFFFE:=100, 32'hFFFFFFFF:=2000};
 command.B dist {32'h00000000:=2000, [32'h00000001 : 32'hFFFFFFFD]:=0, 32'hFFFFFFFE:=100, 32'hFFFFFFFF:=2000}; })
		#300;
get_response(rsp);
end
#300;

    endtask : body

endclass : min_max_sequence

class random_sequence extends mo_alu_base_sequence;
    `uvm_object_utils(random_sequence)

    mo_alu_item command;

    function new(string name = "random_sequence");
        super.new(name);
    endfunction : new

    task body();
        `uvm_info("SEQ_RANDOM","",UVM_MEDIUM)
        
//       command = sequence_item::type_id::create("command");
        `uvm_create(command);
        
        repeat (20000) begin : random_loop
         //start_item(command);
         //assert(command.randomize());
         //finish_item(command);
           `uvm_rand_send(command)
           #300;
          get_response(rsp);
        end : random_loop
        
    endtask : body

endclass : random_sequence

`endif // IFNDEF_GUARD_mo_alu_seq_lib
