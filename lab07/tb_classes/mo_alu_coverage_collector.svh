/******************************************************************************
* DVT CODE TEMPLATE: coverage collector
* Created by moleszkowicz on Jan 22, 2021
* uvc_company = mo, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_mo_alu_coverage_collector
`define IFNDEF_GUARD_mo_alu_coverage_collector

//------------------------------------------------------------------------------
//
// CLASS: mo_alu_coverage_collector
//
//------------------------------------------------------------------------------

class mo_alu_coverage_collector extends uvm_component;

	// Configuration object
	protected mo_alu_config_obj m_config_obj;

	// Item collected from the monitor
	protected mo_alu_item m_collected_item;
	
	protected bit                  [31:0] A;
	protected bit                  [31:0] B;
	protected operation_t                op_set;

	// Using suffix to handle more ports
	`uvm_analysis_imp_decl(_collected_item)

	// Connection to the monitor
	uvm_analysis_imp_collected_item#(mo_alu_item, mo_alu_coverage_collector) m_monitor_port;

	// TODO: More items and connections can be added if needed

	`uvm_component_utils(mo_alu_coverage_collector)

	/*covergroup item_cg;
		option.per_instance = 1;
		// TODO add coverpoints here
		
	endgroup : item_cg
	*/
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
	

	/*function new(string name, uvm_component parent);
		super.new(name, parent);
		item_cg=new;
		item_cg.set_inst_name({get_full_name(), ".item_cg"});
	endfunction : new*/
	
	function new (string name, uvm_component parent);
        super.new(name, parent);
        op_cov               = new();
        zeros_or_ones_on_ops = new();
    endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		m_monitor_port = new("m_monitor_port",this);

		// Get the configuration object
		if(!uvm_config_db#(mo_alu_config_obj)::get(this, "", "m_config_obj", m_config_obj))
			`uvm_fatal("NOCONFIG", {"Config object must be set for: ", get_full_name(), ".m_config_obj"})
	endfunction : build_phase

	function void write_collected_item(mo_alu_item item);
		m_collected_item = item;
		//item_cg.sample();
		A      = item.A;
        B      = item.B;
        op_set = item.op;
        op_cov.sample();
        zeros_or_ones_on_ops.sample();
	endfunction : write_collected_item

endclass : mo_alu_coverage_collector

`endif // IFNDEF_GUARD_mo_alu_coverage_collector
