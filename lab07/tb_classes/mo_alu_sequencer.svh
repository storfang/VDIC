/******************************************************************************
* DVT CODE TEMPLATE: sequencer
* Created by moleszkowicz on Jan 22, 2021
* uvc_company = mo, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_mo_alu_sequencer
`define IFNDEF_GUARD_mo_alu_sequencer

//------------------------------------------------------------------------------
//
// CLASS: mo_alu_sequencer
//
//------------------------------------------------------------------------------

class mo_alu_sequencer extends uvm_sequencer #(mo_alu_item);
	
	`uvm_component_utils(mo_alu_sequencer)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

endclass : mo_alu_sequencer

`endif // IFNDEF_GUARD_mo_alu_sequencer
