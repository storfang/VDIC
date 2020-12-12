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
class driver extends uvm_component;
    `uvm_component_utils(driver)

    virtual alu_bfm bfm;
    uvm_get_port #(command_transaction) command_port;

   function void build_phase(uvm_phase phase);
   
      alu_agent_config alu_agent_config_h;
	  
      if(!uvm_config_db #(alu_agent_config)::get(this, "","config", alu_agent_config_h))
        `uvm_fatal("DRIVER", "Failed to get config");
		
      bfm = alu_agent_config_h.bfm;
	  
      command_port = new("command_port",this);
	  
   endfunction : build_phase

    task run_phase(uvm_phase phase);
        command_transaction command;
        int result;
      bit [31:0]        iA;
      bit [31:0]        iB;
	bit [7:0]	iCTL, iCTLf;
      operation_t                  op_set;
	operation_t                  iop_set;
      bit[54:0]     out;
	reg [67:0] idata;

        forever begin : command_loop
            command_port.get(command);
           // bfm.send_op(command.A, command.B, command.op, result);
//$display("op get:  op: %s ",command.op.name());
	 case(command.op)
           crc_error: begin : case_error_crc
   	      iCTL = {1'b0,3'b001,4'b0000};
   	      idata = {command.B,command.A,1'b1,3'b001};
	      iCTL[3:0] = bfm.nextCRC4_D68(idata,4'b1111);
	      bfm.send_calculation_data_fake2({iCTL,command.A,command.B});
		 bfm.recive_output(bfm.out); //#100;
		bfm.done=1;
           end
           op_error: begin : case_error_op
   	      iCTL = {1'b0,command.op,4'b0000};
   	      idata = {command.B,command.A,1'b1,command.op};
	      iCTL[3:0] = bfm.nextCRC4_D68(idata,4'b0000);
	      bfm.send_calculation_data({iCTL,command.A,command.B});
		 bfm.recive_output(bfm.out); //#100;
		bfm.done=1;
           end
           data_error: begin : case_error_data
		iCTL = {1'b0,command.op,4'b0000};
   	        idata = {command.B,command.A,1'b1,command.op};
	        iCTL[3:0] = bfm.nextCRC4_D68(idata,4'b0000);
		bfm.send_calculation_data_fake({iCTL,command.A,command.B});
		bfm.recive_output(bfm.out);//#100;
		bfm.done=1;
		  
           end
	default: begin : case_default
		iCTL = {1'b0,command.op,4'b0000};
		idata = {command.B,command.A,1'b1,command.op};
		iCTL[3:0] = bfm.nextCRC4_D68(idata,4'b0000);
		//$display("driver values: A: %0h  B: %0h  op: %s CTL: %0h",
		//                  command.A, command.B, command.op.name(), iCTL);
		bfm.send_calculation_data({iCTL,command.A,command.B});
		//#2000;
      		//   bfm.send_op(iA, iB, op_set, result);
		bfm.recive_output(bfm.out);//#1000;// $display("out %0h", out);
		bfm.done=1;
	end endcase

        end : command_loop
    endtask : run_phase

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

endclass : driver

