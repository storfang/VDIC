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
class min_max_transaction extends command_transaction;
    `uvm_object_utils(min_max_transaction)

    /*function int get_value();
      bit [1:0] zero_ones;
      zero_ones = $random;
      if (zero_ones == 2'b00)
        return 32'h00000000;
      else 
        return 32'hFFFFFFFF;
    endfunction : get_value*/

	//constraint data_mm { A dist {32'h00000000:=1, 32'hFFFFFFFF:=1}; B dist {32'h00000000:=1,  32'hFFFFFFFF:=1};}
	//constraint data_mm  A ==(32'h00000000|| 32'hFFFFFFFF); B ==(32'h00000000|| 32'hFFFFFFFF);

   constraint data { A dist {32'h00000000:=1000, [32'h00000001 : 32'hFFFFFFFD]:=0, 32'hFFFFFFFE:=100, 32'hFFFFFFFF:=1000};
                     B dist {32'h00000000:=1000, [32'h00000001 : 32'hFFFFFFFD]:=0, 32'hFFFFFFFE:=100, 32'hFFFFFFFF:=1000};}
//constraint opr {op dist {[add_op:crc_error]:=1};}
   constraint opr {op dist {add_op:=1, data_error:=1, and_op:=1, sub_op:=1, or_op:=1, op_error:=1, crc_error:=1};}
    function new(string name="");
        super.new(name);
    endfunction

endclass : min_max_transaction


