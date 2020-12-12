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
class coverage extends uvm_subscriber #(command_transaction);

    `uvm_component_utils(coverage)

  //  virtual alu_bfm bfm;

protected bit                  [31:0] A;
protected bit                  [31:0] B;
protected operation_t                op_set;

   covergroup op_cov;

      option.name = "cg_op_cov";

      coverpoint op_set {
         // #A1 test all operations
         bins A1_single_cycle[] = {[and_op : sub_op]};
        // bins A1_multi_cycle = {mul_op};

         // #A2 test all operations after errors
         bins A2_err_opn[] = ([data_error : crc_error] => [and_op : sub_op]);

         // #A3 test errors after all operations
         bins A3_opn_err[] = ([add_op:sub_op] => [data_error : crc_error]);

         // #A4 multiply after single-cycle operation
       //  bins A4_sngl_mul[] = ([add_op:xor_op],no_op => mul_op);

         // #A5 single-cycle operation after multiply
       //  bins A5_mul_sngl[] = (mul_op => [add_op:xor_op], no_op);

         // #A6 two operations in row
      //   bins A6_twoops[] = ([add_op:mul_op] [* 2]);

         // bins manymult = (mul_op [* 3:5]);
      }

   endgroup

   covergroup zeros_or_ones_on_ops;

      option.name = "cg_zeros_or_ones_on_ops";

      all_ops : coverpoint op_set {
        // ignore_bins null_ops = { no_op};
      }

      a_leg: coverpoint A {
         bins zeros = {'h00000000};
         bins others= {['h00000001:'hFFFFFFFE]};
         bins ones  = {'hFFFFFFFF};
      }

      b_leg: coverpoint B {
         bins zeros = {'h00000000};
         bins others= {['h00000001:'hFFFFFFFE]};
         bins ones  = {'hFFFFFFFF};
      }

      B_op_00_FF:  cross a_leg, b_leg, all_ops {

         // #B1 simulate all zero input for all the operations

         bins B1_add_00 = binsof (all_ops) intersect {add_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins B1_and_00 = binsof (all_ops) intersect {and_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins B1_or_00 = binsof (all_ops) intersect {or_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins B1_sub_00 = binsof (all_ops) intersect {sub_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         // #B2 simulate all one input for all the operations

         bins B2_add_FF = binsof (all_ops) intersect {add_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins B2_and_FF = binsof (all_ops) intersect {and_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins B2_or_FF = binsof (all_ops) intersect {or_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins B2_sub_FF = binsof (all_ops) intersect {sub_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

        // bins B2_mul_max = binsof (all_ops) intersect {mul_op} &&
         //               (binsof (a_leg.ones) && binsof (b_leg.ones));

         ignore_bins others_only =
                                  binsof(a_leg.others) && binsof(b_leg.others);

      }

   endgroup

    function new (string name, uvm_component parent);
        super.new(name, parent);
        op_cov               = new();
        zeros_or_ones_on_ops = new();
    endfunction : new


    function void write(command_transaction t);
        A      = t.A;
        B      = t.B;
        op_set = t.op;
        op_cov.sample();
        zeros_or_ones_on_ops.sample();
    endfunction : write



endclass : coverage





