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
class min_max_test extends alu_base_test;
   `uvm_component_utils(min_max_test)

   task run_phase(uvm_phase phase);
      min_max_sequence min_max;
      min_max = new("min_max");

      phase.raise_objection(this);
      min_max.start(sequencer_h);
      phase.drop_objection(this);
   endtask : run_phase
      
   function new(string name, uvm_component parent);
      super.new(name,parent);
   endfunction : new

endclass


