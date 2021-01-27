/******************************************************************************
* DVT CODE TEMPLATE: testbench top module
* Created by moleszkowicz on Jan 22, 2021
* uvc_company = mo, uvc_name = alu
*******************************************************************************/
`timescale 1ns/1ps
module alu_tb_top;

	// Import the UVM package
	import uvm_pkg::*;

	// Import the UVC that we have implemented
	import mo_alu_pkg::*;

	// TODO Import all the needed packages
	

	// Clock and reset signals
	bit clk;
	bit rst_n;

	// The interface
	mo_alu_if vif(clk,rst_n);

	// TODO add other interfaces if needed

	// TODO instantiate the DUT
	mtm_Alu dut(
		clk,
		rst_n,
		vif.sin,
		vif.sout
	);

	initial begin
		// Propagate the interface to all the components that need it
		uvm_config_db#(virtual mo_alu_if)::set(uvm_root::get(), "*", "m_mo_alu_vif", vif);
		// Start the test
		run_test();
	end

	// Generate clock
	always
		#5 clk=~clk;

	// Generate reset
	initial begin
		rst_n <= 1'b1;
		clk <= 1'b1;
		#21 rst_n <= 1'b0;
		#51 rst_n <= 1'b1;
	end
endmodule
