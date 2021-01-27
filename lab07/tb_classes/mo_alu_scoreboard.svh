/******************************************************************************
* DVT CODE TEMPLATE: scoreboard
* Created by moleszkowicz on Jan 25, 2021
* uvc_company = mo, uvc_name = alu uvc_if = mo_alu_if
*******************************************************************************/

`ifndef IFNDEF_GUARD_mo_alu_scoreboard
`define IFNDEF_GUARD_mo_alu_scoreboard

//------------------------------------------------------------------------------
//
// CLASS: mo_alu_scoreboard
//
//------------------------------------------------------------------------------

/*class mo_alu_scoreboard extends uvm_scoreboard;

	// Configuration object
	protected mo_alu_config_obj m_config_obj;

	// TLM analysis FIFOs that fetch data from the monitor
	uvm_tlm_analysis_fifo #(mo_alu_item) m_in_fifo;
	uvm_tlm_analysis_fifo #(mo_alu_item) m_out_fifo;

	// Reset TLM FIFO (since this is a transaction level component the reset should be fetched via a TLM analysis FIFO)
	// The reset event can also be fetched in other ways
	uvm_tlm_analysis_fifo #(bit) m_reset_fifo;

	

	mo_alu_item scoreboard[$];

	`uvm_component_utils(mo_alu_scoreboard)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	virtual task scoreboard_match();
		mo_alu_item in_item;
		mo_alu_item out_item;
		mo_alu_item expected_out_item;
		fork
			// Input
			begin
				forever begin
					// Fetch item from the input interface
					m_in_fifo.get(in_item);
					// Apply reference model to get the expected output
					scoreboard.push_back(reference_model(in_item));
				end
			end
			// Output
			begin
				forever begin
					// Fetch item from the output interface
					m_out_fifo.get(out_item);
					// Compare the expected output with the actual output
					// NOTE: pop_front might not be the best way to get the expected output from the scoreboard queue.
					// You may want to use your own matching method or the predefined array locator methods.
					expected_out_item = scoreboard.pop_front();
					if(!compare_items(expected_out_item,out_item))
						`uvm_error("SB_ERR","Items don't match") // TODO add your own error message
				end
			end
		join
	endtask : scoreboard_match

	// Function that resets the entire scoreboard class to its initial state
	function void reset_scoreboard();
		scoreboard.delete();
		m_in_fifo.flush();
		m_out_fifo.flush();
		// TODO Reset other parameters to their initial state
	endfunction : reset_scoreboard

   virtual function mo_alu_item reference_model(mo_alu_item in_item);
      // TODO Implement reference model
   endfunction : reference_model

	virtual function bit compare_items(mo_alu_item item1, mo_alu_item item2);
		// TODO Implement comparison function
	endfunction : compare_items

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		m_in_fifo = new("m_in_fifo", this);
		m_out_fifo = new("m_out_fifo", this);

		// Get the configuration object
		if(!uvm_config_db#(mo_alu_config_obj)::get(this, "", "m_config_obj", m_config_obj))
			`uvm_fatal("NOCONFIG", {"Config object must be set for: ", get_full_name(), ".m_config_obj"})
	endfunction : build_phase

	virtual task run_phase(uvm_phase phase);
		process main;// Used by the reset handling mechanism
		bit reset_is_active;
		super.run_phase(phase);
		m_reset_fifo.get(reset_is_active);
		forever begin
			fork
				// Main thread
				begin
					main=process::self();
					scoreboard_match();
				end
				// Reset
				begin
					m_reset_fifo.get(reset_is_active);
					main.kill();
				end
			join_any
		end
	endtask : run_phase

endclass : mo_alu_scoreboard
*/

class mo_alu_scoreboard extends uvm_scoreboard ;

    `uvm_component_utils(mo_alu_scoreboard)

    protected mo_alu_config_obj m_config_obj;
    uvm_tlm_analysis_fifo #(mo_alu_item) cmd_f;
	//uvm_tlm_analysis_fifo #(mo_alu_item) m_in_fifo;
	uvm_analysis_imp#(mo_alu_item, mo_alu_scoreboard) item_collected_export;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        cmd_f = new ("cmd_f", this);
	   // m_in_fifo = new("m_in_fifo",this);
	    item_collected_export = new("item_collected_export",this);
	    if(!uvm_config_db#(mo_alu_config_obj)::get(this, "", "m_config_obj", m_config_obj))
			`uvm_fatal("NOCONFIG", {"Config object must be set for: ", get_full_name(), ".m_config_obj"})
    endfunction : build_phase

    function result_transaction predict_result(mo_alu_item cmd);
        result_transaction predicted;

        predicted = new("predicted");

        case (cmd.op)
            add_op: predicted.result = cmd.A + cmd.B;
            and_op: predicted.result = cmd.A & cmd.B;
            or_op: predicted.result = cmd.A | cmd.B;
            sub_op: predicted.result = cmd.B - cmd.A;
	    data_error: predicted.result = {DATA_ERROR,24'hFFFFFF};
	    crc_error: predicted.result = {CRC_ERROR,24'hFFFFFF};
	    op_error: predicted.result = {OP_ERROR,24'hFFFFFF};
        endcase // case (op_set)

        return predicted;

    endfunction : predict_result
    
 /*   virtual task void run_phase(uvm_phase phase);
    	forever begin
					// Fetch item from the output interface
					m_in_fifo.get(out_item);
					// Compare the expected output with the actual output
					// NOTE: pop_front might not be the best way to get the expected output from the scoreboard queue.
					// You may want to use your own matching method or the predefined array locator methods.
					//expected_out_item = scoreboard.pop_front();
					//if(!compare_items(expected_out_item,out_item))
					//	`uvm_error("SB_ERR","Items don't match") // TODO add your own error message
				end
	endtask : run_phase*/

    function void write(mo_alu_item t);
        string data_str;
        mo_alu_item cmd; 
        result_transaction predicted;
	    int result;
       // do
            if (!cmd_f.try_get(cmd))
               $fatal(1, "Missing command in self checker");
       // while (1);

        predicted = predict_result(cmd);
        result = t.result;

        data_str  = { cmd.convert2string(),
            " ==>  Actual " , t.convert2string(),
            "/Predicted ",predicted.convert2string()};


        //if (!predicted.compare(t))
        if(predicted.result != result)
            `uvm_error("SELF CHECKER", {"FAIL: ",data_str})
        else
            `uvm_info ("SELF CHECKER", {"PASS: ", data_str}, UVM_MEDIUM)

    endfunction : write

endclass : mo_alu_scoreboard

`endif // IFNDEF_GUARD_mo_alu_scoreboard
