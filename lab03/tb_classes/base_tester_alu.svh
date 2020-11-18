
virtual class base_tester extends uvm_component;


    `uvm_component_utils(base_tester)

    virtual alu_bfm bfm;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
    endfunction : build_phase

    pure virtual function operation_t get_op();

    pure virtual function int get_data();

    task run_phase(uvm_phase phase);
      bit [31:0]        iA;
      bit [31:0]        iB;
	bit [7:0]	iCTL;
      operation_t                  op_set;
	operation_t                  iop_set;
      bit[54:0]     out;
	reg [67:0] idata;

        phase.raise_objection(this);

        bfm.reset_alu();#5000;

      repeat (1000) begin : random_loop
	bfm.done=0;
         bfm.op_set = get_op();
	 iop_set = bfm.op_set;
         bfm.A = get_data();
         bfm.B = get_data();
		case(iop_set)
           crc_error: begin : case_error_crc
   	      iCTL = {1'b0,3'b000,4'b0000};
   	      idata = {bfm.B,bfm.A,1'b1,3'b000};
	      iCTL[3:0] = bfm.nextCRC4_D68(idata,4'b1111);
	      bfm.send_calculation_data({iCTL,bfm.A,bfm.B});
		 bfm.recive_output(bfm.out); #1000;
           end
           op_error: begin : case_error_op
   	      iCTL = {1'b0,bfm.op_set,4'b0000};
   	      idata = {bfm.B,bfm.A,1'b1,bfm.op_set};
	      iCTL[3:0] = bfm.nextCRC4_D68(idata,4'b0000);
	      bfm.send_calculation_data({iCTL,bfm.A,bfm.B});
		 bfm.recive_output(bfm.out); #1000;
           end
           data_error: begin : case_error_data
		repeat(9) bfm.send_byte(8'b11111111,0);
		bfm.recive_output(bfm.out);
		  #1000;
           end
	default: begin : case_default
		iCTL = {1'b0,bfm.op_set,4'b0000};
		idata = {bfm.B,bfm.A,1'b1,bfm.op_set};
		iCTL[3:0] = bfm.nextCRC4_D68(idata,4'b0000);
		//$display("values: A: %0h  B: %0h  op: %s CTL: %0h",
		//                  bfm.A, bfm.B, bfm.op_set.name(), iCTL);
		bfm.send_calculation_data({iCTL,bfm.A,bfm.B});
		//#2000;
      		//   bfm.send_op(iA, iB, op_set, result);
		bfm.recive_output(bfm.out);// $display("out %0h", out);
		bfm.done=1;#2000;
	end endcase
      end : random_loop
	$display("PASSED");
      $finish;

        phase.drop_objection(this);

    endtask : run_phase


endclass : base_tester
