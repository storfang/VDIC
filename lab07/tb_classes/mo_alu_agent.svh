/******************************************************************************
* DVT CODE TEMPLATE: agent
* Created by moleszkowicz on Jan 22, 2021
* uvc_company = mo, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_mo_alu_agent
`define IFNDEF_GUARD_mo_alu_agent

//------------------------------------------------------------------------------
//
// CLASS: mo_alu_agent
//
//------------------------------------------------------------------------------

class mo_alu_agent extends uvm_agent;

	// Configuration object
	protected mo_alu_config_obj m_config_obj;

	mo_alu_driver m_driver;
	mo_alu_sequencer m_sequencer;
	mo_alu_monitor m_monitor;
	mo_alu_monitor_result m_monitor_result;
	mo_alu_coverage_collector m_coverage_collector;
	mo_alu_scoreboard m_mo_alu_scoreboard;

	// TODO Add fields here
	

	`uvm_component_utils(mo_alu_agent)

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		// Get the configuration object
		if(!uvm_config_db#(mo_alu_config_obj)::get(this, "", "m_config_obj", m_config_obj))
			`uvm_fatal("NOCONFIG", {"Config object must be set for: ", get_full_name(), ".m_config_obj"})

		// Propagate the configuration object to monitor
		uvm_config_db#(mo_alu_config_obj)::set(this, "m_monitor", "m_config_obj", m_config_obj);
		uvm_config_db#(mo_alu_config_obj)::set(this, "m_monitor_result", "m_config_obj", m_config_obj);
		// Create the monitor
		m_monitor = mo_alu_monitor::type_id::create("m_monitor", this);
		m_monitor_result = mo_alu_monitor_result::type_id::create("m_monitor_result", this);

		if(m_config_obj.m_coverage_enable) begin
			m_coverage_collector = mo_alu_coverage_collector::type_id::create("m_coverage_collector", this);
		end
		if(m_config_obj.m_scoreboard_enable) begin
			m_mo_alu_scoreboard = mo_alu_scoreboard::type_id::create("m_mo_alu_scoreboard", this);
		end

		if(m_config_obj.m_is_active == UVM_ACTIVE) begin
			// Propagate the configuration object to driver
			uvm_config_db#(mo_alu_config_obj)::set(this, "m_driver", "m_config_obj", m_config_obj);
			// Create the driver
			m_driver = mo_alu_driver::type_id::create("m_driver", this);

			// Create the sequencer
			m_sequencer = mo_alu_sequencer::type_id::create("m_sequencer", this);
		end
	endfunction : build_phase

	virtual function void connect_phase(uvm_phase phase);
		if(m_config_obj.m_coverage_enable) begin
			m_monitor.m_collected_item_port.connect(m_coverage_collector.m_monitor_port);
		end
		
		if(m_config_obj.m_scoreboard_enable) begin
			m_monitor_result.m_collected_item_port_result.connect(m_mo_alu_scoreboard.item_collected_export);
			m_monitor.m_collected_item_port.connect(m_mo_alu_scoreboard.cmd_f.analysis_export);
        	//result_monitor_h.ap.connect(m_mo_alu_scoreboard.analysis_export);
		end

		if(m_config_obj.m_is_active == UVM_ACTIVE) begin
			m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
		end
	endfunction : connect_phase

endclass : mo_alu_agent

`endif // IFNDEF_GUARD_mo_alu_agent
