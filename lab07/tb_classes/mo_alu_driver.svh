/******************************************************************************
* DVT CODE TEMPLATE: driver
* Created by moleszkowicz on Jan 22, 2021
* uvc_company = mo, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_mo_alu_driver
`define IFNDEF_GUARD_mo_alu_driver

//------------------------------------------------------------------------------
//
// CLASS: mo_alu_driver
//
//------------------------------------------------------------------------------

class mo_alu_driver extends uvm_driver #(mo_alu_item);

	// The virtual interface to HDL signals.
	protected virtual mo_alu_if m_mo_alu_vif;

	// Configuration object
	protected mo_alu_config_obj m_config_obj;
	
	      bit [31:0]        iA;
      bit [31:0]        iB;
	bit [7:0]	iCTL, iCTLf;
      operation_t                  op_set;
	operation_t                  iop_set;
      bit[54:0]     out;
	reg [67:0] idata;

	`uvm_component_utils(mo_alu_driver)

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		// Get the interface
		if(!uvm_config_db#(virtual mo_alu_if)::get(this, "", "m_mo_alu_vif", m_mo_alu_vif))
			`uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".m_mo_alu_vif"})

		// Get the configuration object
		if(!uvm_config_db#(mo_alu_config_obj)::get(this, "", "m_config_obj", m_config_obj))
			`uvm_fatal("NOCONFIG", {"Config object must be set for: ", get_full_name(), ".m_config_obj"})
	endfunction: build_phase

	virtual task run_phase(uvm_phase phase);
		// Driving should be triggered by an initial reset pulse
		@(negedge m_mo_alu_vif.rst_n)
			do @(posedge m_mo_alu_vif.clk);
			while(m_mo_alu_vif.rst_n!==1);

		// Start driving
		get_and_drive();
	endtask : run_phase

	virtual protected task get_and_drive();
		process main_thread; // main thread
		process rst_mon_thread; // reset monitor thread

		forever begin
			// Don't drive during reset
			while(m_mo_alu_vif.rst_n!==1) @(posedge m_mo_alu_vif.clk);

			// Get the next item from the sequencer
			seq_item_port.get_next_item(req);
			$cast(rsp, req.clone());
			rsp.set_id_info(req);

			// Drive current transaction
			fork
				// Drive the transaction
				begin
					main_thread=process::self();
					`uvm_info(get_type_name(), $sformatf("mo_alu_driver %0d start driving item :\n%s", m_config_obj.m_agent_id, rsp.sprint()), UVM_HIGH)
					drive_item(rsp);
					`uvm_info(get_type_name(), $sformatf("mo_alu_driver %0d done driving item :\n%s", m_config_obj.m_agent_id, rsp.sprint()), UVM_HIGH)

					if (rst_mon_thread) rst_mon_thread.kill();
				end
				// Monitor the reset signal
				begin
					rst_mon_thread = process::self();
					@(negedge m_mo_alu_vif.rst_n) begin
						// Interrupt current transaction at reset
						if(main_thread) main_thread.kill();
						// Do reset
						reset_signals();
						reset_driver();
					end
				end
			join_any

			// Send item_done and a response to the sequencer
			seq_item_port.item_done();
			// TODO If the current transaction was interrupted by a reset you should set a field in the rsp item to indicate this to the sequence
			seq_item_port.put_response(rsp);
		end
	endtask : get_and_drive

	virtual protected task reset_signals();
		// TODO Reset the signals to their default values
	endtask : reset_signals

	virtual protected task reset_driver();
		// TODO Reset driver specific state variables (e.g. counters, flags, buffers, queues, etc.)
	endtask : reset_driver

	virtual protected task drive_item(mo_alu_item item);
		// TODO Drive the item
		//forever begin : command_loop
		//seq_item_port.get_next_item(item);
            //command_port.get(command);
           // bfm.send_op(command.A, command.B, command.op, result);
//$display("op get:  op: %s ",item.op);
	 case(item.op)
           crc_error: begin : case_error_crc
   	      iCTL = {1'b0,3'b001,4'b0000};
   	      idata = {item.B,item.A,1'b1,3'b001};
	      iCTL[3:0] = m_mo_alu_vif.nextCRC4_D68(idata,4'b1111);
	      m_mo_alu_vif.send_calculation_data_fake2({iCTL,item.A,item.B});
		 m_mo_alu_vif.recive_output(m_mo_alu_vif.out); //#100;
		m_mo_alu_vif.done=1;
           end
           op_error: begin : case_error_op
   	      iCTL = {1'b0,item.op,4'b0000};
   	      idata = {item.B,item.A,1'b1,item.op};
	      iCTL[3:0] = m_mo_alu_vif.nextCRC4_D68(idata,4'b0000);
	      m_mo_alu_vif.send_calculation_data({iCTL,item.A,item.B});
		 m_mo_alu_vif.recive_output(m_mo_alu_vif.out); //#100;
		m_mo_alu_vif.done=1;
           end
           data_error: begin : case_error_data
		iCTL = {1'b0,item.op,4'b0000};
   	        idata = {item.B,item.A,1'b1,item.op};
	        iCTL[3:0] = m_mo_alu_vif.nextCRC4_D68(idata,4'b0000);
		m_mo_alu_vif.send_calculation_data_fake({iCTL,item.A,item.B});
		m_mo_alu_vif.recive_output(m_mo_alu_vif.out);//#100;
		m_mo_alu_vif.done=1;
		  
           end
	default: begin : case_default
		iCTL = {1'b0,item.op,4'b0000};
		idata = {item.B,item.A,1'b1,item.op};
		iCTL[3:0] = m_mo_alu_vif.nextCRC4_D68(idata,4'b0000);
		//$display("driver values: A: %0h  B: %0h  op: %s CTL: %0h",
		//                  command.A, command.B, command.op.name(), iCTL);
		m_mo_alu_vif.send_calculation_data({iCTL,item.A,item.B});
		//#2000;
      		//   bfm.send_op(iA, iB, op_set, result);
		m_mo_alu_vif.recive_output(m_mo_alu_vif.out);//#1000;// $display("out %0h", out);
		m_mo_alu_vif.done=1;
	end endcase
	//seq_item_port.item_done();
       // end : command_loop
	endtask : drive_item

endclass : mo_alu_driver

`endif // IFNDEF_GUARD_mo_alu_driver
