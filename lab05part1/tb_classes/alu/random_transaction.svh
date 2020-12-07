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
class random_transaction extends command_transaction;
    `uvm_object_utils(random_transaction)

   constraint data { A dist {32'h00000000:=1, [32'h00000001 : 32'hFFFFFFFE]:=1, 32'hFFFFFFFF:=1};
                     B dist {32'h00000000:=1, [32'h00000001 : 32'hFFFFFFFE]:=1, 32'hFFFFFFFF:=1};} 
//	constraint op;
   constraint opr {op dist {add_op:=1, data_error:=1, and_op:=1, sub_op:=1, or_op:=1, op_error:=1, crc_error:=1};}
//constraint opr {op dist {[add_op:sub_op]:=1, or_op:=1};}
    function new(string name="");
        super.new(name);
    endfunction

endclass : random_transaction


