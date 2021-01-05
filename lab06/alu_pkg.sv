/*
   Copyright 2013 Ray Salemi

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/
`timescale 1ns/1ps
package alu_pkg;
   import uvm_pkg::*;
`include "uvm_macros.svh"
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

`include "sequence_item.svh"//
typedef uvm_sequencer #(sequence_item) sequencer;

//`include "command_transaction.svh"
//`include "random_transaction.svh"
//`include "add_transaction.svh"
//`include "min_max_transaction.svh"
`include "result_transaction.svh"
`include "random_sequence.svh"//
`include "minmax_sequence.svh"//

`include "coverage_alu.svh"//
//`include "tester.svh"
//`include "base_tester_alu.svh"
//`include "random_tester_alu.svh"

//`include "add_tester.svh" 
//`include "min_max_tester.svh"
//`include "tester_alu.svh"
`include "scoreboard_alu.svh"//
//`include "testbench_alu.svh"
`include "driver.svh"
`include "command_monitor.svh"//
`include "result_monitor.svh"// 

`include "env.svh"//
`include "alu_base_test.svh"//
`include "random_test.svh"//
//`include "add_test.svh"
`include "min_max_test.svh"//

endpackage : alu_pkg
   
