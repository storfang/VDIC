/******************************************************************************
* DVT CODE TEMPLATE: sequence item
* Created by moleszkowicz on Jan 22, 2021
* uvc_company = mo, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_mo_alu_item
`define IFNDEF_GUARD_mo_alu_item

//------------------------------------------------------------------------------
//
// CLASS: mo_alu_item
//
//------------------------------------------------------------------------------

class  mo_alu_item extends uvm_sequence_item;

	// This bit should be set when you want all the fields to be
	// constrained to some default values or ranges at randomization
	rand bit default_values;

	// TODO Declare fields here
	   rand bit [31:0]    A;
   rand bit [31:0]    B; 

  // bit          reset_n;
   rand bit [2:0]   op;

   rand operation_t  op_set;

 //  assign op = op_set;
	bit [31:0]  result;

	rand int m_data;

	// TODO it is a good practice to define a c_default_values_*
	// constraint for each field in which you constrain the field to some
	// default value or range. You can disable these constraints using
	// set_constraint_mode() before you call the randomize() function
	constraint c_default_values_data {
		op inside {[0:6]};
	}

	`uvm_object_utils_begin(mo_alu_item)
		`uvm_field_int(A, UVM_DEFAULT)
		`uvm_field_int(B, UVM_DEFAULT)
		`uvm_field_int(op, UVM_DEFAULT)
		`uvm_field_enum(operation_t, op_set, UVM_DEFAULT)
		`uvm_field_int(result, UVM_DEFAULT)
	`uvm_object_utils_end

	function new (string name = "mo_alu_item");
		super.new(name);
	endfunction : new

	// HINT UVM field macros don't work with unions and structs, you may have to override mo_alu_item.do_copy().
	virtual function void do_copy(uvm_object rhs);
		super.do_copy(rhs);
	endfunction : do_copy

	// HINT UVM field macros don't work with unions and structs, you may have to override mo_alu_item.do_pack().
	virtual function void do_pack(uvm_packer packer);
		super.do_pack(packer);
	endfunction : do_pack

	// HINT UVM field macros don't work with unions and structs, you may have to override mo_alu_item.do_unpack().
	virtual function void do_unpack(uvm_packer packer);
		super.do_unpack(packer);
	endfunction : do_unpack

	// HINT UVM field macros don't work with unions and structs, you may have to override mo_alu_item.do_print().
	virtual function void do_print(uvm_printer printer);
		super.do_print(printer);
	endfunction : do_print

endclass :  mo_alu_item

`endif // IFNDEF_GUARD_mo_alu_item
