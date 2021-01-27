/******************************************************************************
* DVT CODE TEMPLATE: package
* Created by moleszkowicz on Jan 22, 2021
* uvc_company = mo, uvc_name = alu
*******************************************************************************/

package mo_alu_pkg;

	typedef enum bit[2:0] {and_op  =    3'b000,
                          or_op =      3'b001,
                          add_op =     3'b100,
			  sub_op =     3'b101,
                          data_error = 3'b010,
                          op_error =   3'b011,
			  crc_error =  3'b110
                          } operation_t;

    typedef struct packed {
        bit[31:0] A;
        bit[31:0] B;
        operation_t op;
    } command_s;

localparam CRC_ERROR = 8'b10100101, //a5
	DATA_ERROR = 8'b11001001, //c9
	OP_ERROR = 8'b10010011; //93

	// UVM macros
	`include "uvm_macros.svh"
	// UVM class library compiled in a package
	import uvm_pkg::*;

	// Configuration object
	`include "mo_alu_config_obj.svh"
	// Sequence item
	`include "mo_alu_item.svh"
	// Monitor
	`include "mo_alu_monitor.svh"
	// Coverage Collector
	`include "mo_alu_coverage_collector.svh"
	// Driver
	`include "mo_alu_driver.svh"
	// Sequencer
	`include "mo_alu_sequencer.svh"
	`include "result_transaction.svh"
	`include "mo_alu_scoreboard.svh"
	// Agent
	`include "mo_alu_agent.svh"
	// Environment
	`include "mo_alu_env.svh"
	// Sequence library
	`include "mo_alu_seq_lib.svh"
	`include "mo_alu_base_test.svh"
	`include "mo_alu_example_test.svh"
	`include "mo_alu_random_test.svh"
	`include "mo_alu_min_max_test.svh"
	
	

endpackage : mo_alu_pkg
