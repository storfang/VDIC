module tester_alu(alu_bfm bfm);
   import alu_pkg::*;

   function operation_t get_op();
      bit [2:0] op_choice;
      op_choice = $random;
      case (op_choice)
        3'b000 : return and_op;
        3'b001 : return or_op;
        3'b010 : return data_error;
        3'b011 : return op_error;
        3'b100 : return add_op;
        3'b101 : return sub_op;
        3'b110 : return crc_error;
     //   3'b111 : return no_op;
      endcase // case (op_choice)
   endfunction : get_op

   function int get_data();
      bit [1:0] zero_ones;
      zero_ones = $random;
      if (zero_ones == 2'b00)
        return 32'h00000000;
      else if (zero_ones == 2'b11)
        return 32'hFFFFFFFF;
      else
        return $random;
   endfunction : get_data


   
   initial begin
      bit [31:0]        iA;
      bit [31:0]        iB;
	bit [7:0]	iCTL;
      operation_t                  op_set;
	operation_t                  iop_set;
      bit[54:0]     out;
	reg [67:0] idata;
      
      bfm.reset_alu(); #5000;
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
   end // initial begin
endmodule : tester_alu
