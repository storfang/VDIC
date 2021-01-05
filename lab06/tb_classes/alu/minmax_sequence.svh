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
class min_max_sequence extends uvm_sequence #(sequence_item);
    `uvm_object_utils(min_max_sequence)

    sequence_item command;

    function new(string name = "min_max_sequence");
        super.new(name);
    endfunction : new

    task body();
        `uvm_info("SEQ_MAXMULT", "", UVM_MEDIUM)
//      command = sequence_item::type_id::create("command");
//      start_item(command);
//      command.op = mul_op;
//      command.A = 8'hFF;
//      command.B = 8'hFF;
//      finish_item(command);
 //       `uvm_do_with(command, {op == sub_op; A == 32'hFF; B == 8'hFF;})
`uvm_create(command)
`uvm_send(command)
repeat(12000)begin
	`uvm_rand_send_with(command, { command.A dist {32'h00000000:=2000, [32'h00000001 : 32'hFFFFFFFD]:=0, 32'hFFFFFFFE:=10, 32'hFFFFFFFF:=2000};
 command.B dist {32'h00000000:=2000, [32'h00000001 : 32'hFFFFFFFD]:=0, 32'hFFFFFFFE:=10, 32'hFFFFFFFF:=2000}; })
end
#300;
    endtask : body

endclass : min_max_sequence
