/******************************************************************************
* DVT CODE TEMPLATE: monitor
* Created by moleszkowicz on Jan 22, 2021
* uvc_company = mo, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_mo_alu_monitor
`define IFNDEF_GUARD_mo_alu_monitor

//------------------------------------------------------------------------------
//
// CLASS: mo_alu_monitor
//
//------------------------------------------------------------------------------

class mo_alu_monitor extends uvm_monitor;

	// The virtual interface to HDL signals.
	protected virtual mo_alu_if m_mo_alu_vif;

	// Configuration object
	protected mo_alu_config_obj m_config_obj;

	// Collected item
	protected mo_alu_item m_collected_item;

	// Collected item is broadcast on this port
	uvm_analysis_port #(mo_alu_item) m_collected_item_port;

	`uvm_component_utils(mo_alu_monitor)

	function new (string name, uvm_component parent);
		super.new(name, parent);

		// Allocate collected_item.
		m_collected_item = mo_alu_item::type_id::create("m_collected_item", this);

		// Allocate collected_item_port.
		m_collected_item_port = new("m_collected_item_port", this);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		// Get the interface
		if(!uvm_config_db#(virtual mo_alu_if)::get(this, "", "m_mo_alu_vif", m_mo_alu_vif))
			`uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".m_mo_alu_vif"})

		// Get the configuration object
		if(!uvm_config_db#(mo_alu_config_obj)::get(this, "", "m_config_obj", m_config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".m_config_obj"})
	endfunction: build_phase

	virtual task run_phase(uvm_phase phase);
		process main_thread; // main thread
		process rst_mon_thread; // reset monitor thread

		// Start monitoring only after an initial reset pulse
		@(negedge m_mo_alu_vif.rst_n)
			do @(posedge m_mo_alu_vif.clk);
			while(m_mo_alu_vif.rst_n!==1);

		// Start monitoring
		forever begin
			fork
				// Start the monitoring thread
				begin
					main_thread=process::self();
					collect_items();
				end
				// Monitor the reset signal
				begin
					rst_mon_thread = process::self();
					@(negedge m_mo_alu_vif.rst_n) begin
						// Interrupt current item at reset
						if(main_thread) main_thread.kill();
						// Do reset
						reset_monitor();
					end
				end
			join_any

			if (rst_mon_thread) rst_mon_thread.kill();
		end
	endtask : run_phase

	virtual protected task collect_items();
		forever begin
			// TODO Fill this place with the logic for collecting the data
			// ...
			@(posedge m_mo_alu_vif.done)
			m_collected_item.A = m_mo_alu_vif.A;
			m_collected_item.B = m_mo_alu_vif.B;
			m_collected_item.op = m_mo_alu_vif.op;
			//wait(0);
			`uvm_info(get_full_name(), $sformatf("Item collected :\n%s", m_collected_item.sprint()), UVM_MEDIUM)

			m_collected_item_port.write(m_collected_item);

			if (m_config_obj.m_checks_enable)
				perform_item_checks();
		end
	endtask : collect_items

	virtual protected function void perform_item_checks();
		// TODO Perform item checks here
	endfunction : perform_item_checks

	virtual protected function void reset_monitor();
		// TODO Reset monitor specific state variables (e.g. counters, flags, buffers, queues, etc.)
	endfunction : reset_monitor

endclass : mo_alu_monitor

class mo_alu_monitor_result extends mo_alu_monitor;

	// The virtual interface to HDL signals.
	protected virtual mo_alu_if m_mo_alu_vif;

	// Configuration object
	protected mo_alu_config_obj m_config_obj;

	// Collected item
	protected mo_alu_item m_collected_item_result;

	// Collected item is broadcast on this port
	uvm_analysis_port #(mo_alu_item) m_collected_item_port_result;

	`uvm_component_utils(mo_alu_monitor_result)

	function new (string name, uvm_component parent);
		super.new(name, parent);

		// Allocate collected_item.
		m_collected_item_result = mo_alu_item::type_id::create("m_collected_item_result", this);

		// Allocate collected_item_port.
		m_collected_item_port_result = new("m_collected_item_port_result", this);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		// Get the interface
		if(!uvm_config_db#(virtual mo_alu_if)::get(this, "", "m_mo_alu_vif", m_mo_alu_vif))
			`uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".m_mo_alu_vif"})

		// Get the configuration object
		if(!uvm_config_db#(mo_alu_config_obj)::get(this, "", "m_config_obj", m_config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".m_config_obj"})
	endfunction: build_phase

	virtual task run_phase(uvm_phase phase);
		process main_thread; // main thread
		process rst_mon_thread; // reset monitor thread

		// Start monitoring only after an initial reset pulse
		@(negedge m_mo_alu_vif.rst_n)
			do @(posedge m_mo_alu_vif.clk);
			while(m_mo_alu_vif.rst_n!==1);

		// Start monitoring
		forever begin
			fork
				// Start the monitoring thread
				begin
					main_thread=process::self();
					collect_items();
				end
				// Monitor the reset signal
				begin
					rst_mon_thread = process::self();
					@(negedge m_mo_alu_vif.rst_n) begin
						// Interrupt current item at reset
						if(main_thread) main_thread.kill();
						// Do reset
						reset_monitor();
					end
				end
			join_any

			if (rst_mon_thread) rst_mon_thread.kill();
		end
	endtask : run_phase

	virtual protected task collect_items();
		@(posedge m_mo_alu_vif.done)
		forever begin
			// TODO Fill this place with the logic for collecting the data
			// ...
			@(posedge m_mo_alu_vif.done)
			#10;
			//@(posedge m_mo_alu_vif.done)
			//@(posedge m_mo_alu_vif.done)
			//m_collected_item.A = m_mo_alu_vif.A;
			//m_collected_item.B = m_mo_alu_vif.B;
			//.op = m_mo_alu_vif.op;
			//m_collected_item_result.A = m_collected_item.A;
			//m_collected_item_result.B = m_collected_item.B;
			//m_collected_item_result.op = m_mo_alu_vif.op;
			m_collected_item_result.result = {m_mo_alu_vif.out[52:45],m_mo_alu_vif.out[41:34],m_mo_alu_vif.out[30:23],m_mo_alu_vif.out[19:12]};
			//wait(0);
			`uvm_info(get_full_name(), $sformatf("Item_result collected :\n%s", m_collected_item_result.sprint()), UVM_MEDIUM)

			m_collected_item_port_result.write(m_collected_item_result);

			if (m_config_obj.m_checks_enable)
				perform_item_checks();
		end
	endtask : collect_items

	virtual protected function void perform_item_checks();
		// TODO Perform item checks here
	endfunction : perform_item_checks

	virtual protected function void reset_monitor();
		// TODO Reset monitor specific state variables (e.g. counters, flags, buffers, queues, etc.)
	endfunction : reset_monitor

endclass : mo_alu_monitor_result
`endif // IFNDEF_GUARD_mo_alu_monitor
