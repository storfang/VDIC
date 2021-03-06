
module top;

//------------------------------------------------------------------------------
// type and variable definitions
//------------------------------------------------------------------------------

   typedef enum bit[2:0] {and_op  = 3'b000,
                          or_op = 3'b001,
                          add_op = 3'b100,
			  sub_op = 3'b101,
                          data_error = 3'b010,
                          op_error = 3'b011,
			  crc_error = 3'b110,
                          no_op = 3'b111} operation_t;
   bit [31:0]    A;
   bit [31:0]    B; 
   bit          clk;
  // bit          reset_n;
   wire [2:0]   op;
  // bit          start;
   bit         done;
   bit [31:0]  result;
   operation_t  op_set;

   assign op = op_set;


operation_t q1;
assign q1=op_set;

   bit rst_n; // synchronous reset active low
   bit sin;   // serial data input
   bit sout; 

bit [31:0]    queue_A[$];
bit [31:0]    queue_B[$];
bit [2:0]    queue_op[$];
bit [3:0] flag;
bit [3:0] predicted_flag;
bit [31:0] predicted_result;

reg [7:0] CTL;
reg pass, passes;
reg [67:0] data;

integer i,j,k,l,j_nxt,l_nxt,g ;
reg [54:0] out, out_nxt;
localparam CRC_ERROR = 8'b10100101,
	DATA_ERROR = 8'b11001001,
	OP_ERROR = 8'b10010011;

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------

   mtm_Alu DUT (.clk, .rst_n, .sin, .sout);

//------------------------------------------------------------------------------
// Coverage block
//------------------------------------------------------------------------------

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
         ignore_bins null_ops = { no_op};
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

   op_cov oc;
   zeros_or_ones_on_ops c_00_FF;

   initial begin : coverage
   
      oc = new();
      c_00_FF = new();
   
      forever begin : sample_cov
         @(negedge clk);
         oc.sample();
         c_00_FF.sample();
      end
   end : coverage

//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------

   initial begin : clk_gen
      clk = 0;
      forever begin : clk_frv
         #10;
         clk = ~clk;
      end
   end

//------------------------------------------------------------------------------
// Tester
//------------------------------------------------------------------------------

//---------------------------------
// Random data generation functions

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

//---------------------------------
   function byte get_data();
      bit [1:0] zero_ones;
      zero_ones = $random;
      if (zero_ones == 2'b00)
        return 32'h00000000;
      else if (zero_ones == 2'b11)
        return 32'hFFFFFFFF;
      else
        return $random;
   endfunction : get_data

//------------------------
// Tester main
//------------------------   

task send_byte(input [7:0] essence, input frame_type);
begin
	sin <= 1'b0;
	@(negedge clk)
	sin <= frame_type;
	@(negedge clk)
	sin = essence[7];
        @(negedge clk)
       	sin = essence[6];
       	@(negedge clk)
       	sin = essence[5];
       	@(negedge clk)
       	sin = essence[4];
       	@(negedge clk)
       	sin = essence[3];
       	@(negedge clk)
       	sin = essence[2];
       	@(negedge clk)
       	sin = essence[1];
       	@(negedge clk)
        sin = essence[0];
       	@(negedge clk)
	sin <= 1'b1;
	@(negedge clk);
	end
endtask

task send_calculation_data;
  input [71:0] bytes; //
  begin
      send_byte(bytes[31:24],0);
      send_byte(bytes[23:16],0);
      send_byte(bytes[15:8],0);
      send_byte(bytes[7:0],0);
      send_byte(bytes[63:56],0);
      send_byte(bytes[55:48],0);
      send_byte(bytes[47:40],0);
      send_byte(bytes[39:32],0);
      send_byte(bytes[71:64],1);
  end
endtask

function [3:0] nextCRC4_D68;
// polynomial: x^4 + x^1 + 1
// data width: 68
// convention: the first serial bit is D[67]

  input [67:0] Data;
  input [3:0] crc;
  reg [67:0] d;
  reg [3:0] c;
  reg [3:0] newcrc;
  begin
    d = Data;
    c = crc;

    newcrc[0] = d[66] ^ d[64] ^ d[63] ^ d[60] ^ d[56] ^ d[55] ^ d[54] ^ d[53] ^ d[51] ^ d[49] ^ d[48] ^ d[45] ^ d[41] ^ d[40] ^ d[39] ^ d[38] ^ d[36] ^ d[34] ^ d[33] ^ d[30] ^ d[26] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[19] ^ d[18] ^ d[15] ^ d[11] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[4] ^ d[3] ^ d[0] ^ c[0] ^ c[2];
    newcrc[1] = d[67] ^ d[66] ^ d[65] ^ d[63] ^ d[61] ^ d[60] ^ d[57] ^ d[53] ^ d[52] ^ d[51] ^ d[50] ^ d[48] ^ d[46] ^ d[45] ^ d[42] ^ d[38] ^ d[37] ^ d[36] ^ d[35] ^ d[33] ^ d[31] ^ d[30] ^ d[27] ^ d[23] ^ d[22] ^ d[21] ^ d[20] ^ d[18] ^ d[16] ^ d[15] ^ d[12] ^ d[8] ^ d[7] ^ d[6] ^ d[5] ^ d[3] ^ d[1] ^ d[0] ^ c[1] ^ c[2] ^ c[3];
    newcrc[2] = d[67] ^ d[66] ^ d[64] ^ d[62] ^ d[61] ^ d[58] ^ d[54] ^ d[53] ^ d[52] ^ d[51] ^ d[49] ^ d[47] ^ d[46] ^ d[43] ^ d[39] ^ d[38] ^ d[37] ^ d[36] ^ d[34] ^ d[32] ^ d[31] ^ d[28] ^ d[24] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[17] ^ d[16] ^ d[13] ^ d[9] ^ d[8] ^ d[7] ^ d[6] ^ d[4] ^ d[2] ^ d[1] ^ c[0] ^ c[2] ^ c[3];
    newcrc[3] = d[67] ^ d[65] ^ d[63] ^ d[62] ^ d[59] ^ d[55] ^ d[54] ^ d[53] ^ d[52] ^ d[50] ^ d[48] ^ d[47] ^ d[44] ^ d[40] ^ d[39] ^ d[38] ^ d[37] ^ d[35] ^ d[33] ^ d[32] ^ d[29] ^ d[25] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[18] ^ d[17] ^ d[14] ^ d[10] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[3] ^ d[2] ^ c[1] ^ c[3];
    nextCRC4_D68 = newcrc;
end
endfunction
always @(*) begin
if (l > 0 && l < 55) begin
  out_nxt[l-1] = sout;
  l_nxt = l - 1;
end
else if (l == 0) begin
  l_nxt = 56;
  end
else if (sout == 0) begin
  l_nxt = 54;
  out_nxt[54] = 0;
end
j_nxt = j + 1;
end

always @(posedge clk) begin
j = j_nxt;
out = out_nxt;
l = l_nxt;
end


   initial begin : tester
      rst_n = 1'b0;
      @(negedge clk);
      @(negedge clk);
      rst_n = 1'b1;
      //start = 1'b0;
	A=4'hFFFF; B=A; CTL=B; send_calculation_data({CTL,A,B});
	#2000;
      repeat (1000) begin : tester_main
         @(negedge clk); 
	//@(negedge done);
	//done = 1'b0;
         op_set = get_op();
 	queue_op.push_front(op_set);
         A = get_data(); 
	queue_A.push_front(A);
         B = get_data(); 
	queue_B.push_front(B);
	//queue_1.
        // start = 1'b1;
         case (op_set) // handle the start signal
           no_op: begin : case_no_op
              @(posedge clk);
              //start = 1'b0;
           end
        /*   rst_op: begin : case_rst_op
              rst_n = 1'b0;
              //start = 1'b0;
              @(negedge clk);
              rst_n = 1'b1;
           end*/
           crc_error: begin : case_error_op
   	      CTL = {1'b0,and_op,4'b0000};
   	      data = {B,A,1'b1,op_set};
	      CTL[3:0] = nextCRC4_D68(data,4'b1111);
	      send_calculation_data({CTL,A,B});
		#2000; done = 1'b1; #1000;
           end
           data_error: begin : case_error_data
   	     /* CTL = {1'b0,op_set,4'b0000};
   	      data = {B,A,1'b1,op_set};
	      CTL[3:0] = nextCRC4_D68(data,4'b0000);
	      send_calculation_data({CTL,A,B});
	      //send_calculation_data({CTL,A,B});*/
	repeat(9) send_byte(8'b11111111,0);
		#2000; done = 1'b1; #1000;
           end
           default: begin : case_default
   	      CTL = {1'b0,op_set,4'b0000};
   	      data = {B,A,1'b1,op_set};
   	      CTL[3:0] = nextCRC4_D68(data,4'b0000);
//$display("values: A: %0h  B: %0h  op: %s CTL: %0h",
  //                A, B, op_set.name(), CTL);
   	      send_calculation_data({CTL,A,B});
#2000; //compare({out[52:45],out[41:34],out[30:23],out[19:12]},A,B,CTL,pass);
//$display("result %0h", {out[52:45],out[41:34],out[30:23],out[19:12]});
	      //send_calculation_data({CTL,B,A});
             // wait(done);
             // start = 1'b0;
		done = 1'b1; #1000;
           end
         endcase // case (op_set)
         // print coverage after each loop
         // can also be used to stop the simulation when cov=100%
         // $strobe("%0t %0g",$time, $get_coverage());
      end
      $finish;
   end : tester

//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------

always @(*) begin
if (l > 0 && l < 55) begin
  out_nxt[l-1] = sout;
  l_nxt = l - 1;
end
else if (l == 0) begin
  l_nxt = 56;
  end
else if (sout == 0) begin
  l_nxt = 54;
  out_nxt[54] = 0;
end
j_nxt = j + 1;
end

always @(posedge clk) begin
j = j_nxt;
out = out_nxt;
l = l_nxt;
end

always @(*) begin
//FLAGS = { Carry, Overflow, Zero, Negative }
predicted_flag[1] = (predicted_result == 0); //zero_f
predicted_flag[0] = predicted_result[31]; //negative_f
predicted_flag[3] = (((op_set == add_op) && ((predicted_result < A) || (predicted_result < B))) || ((op_set == sub_op) && (A < predicted_result))); //carry_f
predicted_flag[2] = (((op_set == add_op) && !(A[31]^B[31]) && (A[31]^predicted_result[31])) || ((op_set == sub_op) && !(A[31]^predicted_result[31]) && (B[31]^predicted_result[31]))); //overflow_f

end

   always @(posedge done) begin : scoreboard
      int predicted_result; int a1; int b1; int q1;
      #1;
	q1=queue_op.pop_back();
 a1=queue_A.pop_back(); 
 b1=queue_B.pop_back();
      case (q1)
        add_op: begin predicted_result = a1 + b1; result = {out[52:45],out[41:34],out[30:23],out[19:12]}; flag = out[7:4]; end
        and_op: begin predicted_result = a1 & b1; result = {out[52:45],out[41:34],out[30:23],out[19:12]}; flag = out[7:4]; end
        or_op: begin predicted_result = a1 | b1; result = {out[52:45],out[41:34],out[30:23],out[19:12]}; flag = out[7:4]; end
        sub_op: begin predicted_result = b1 - a1; result = {out[52:45],out[41:34],out[30:23],out[19:12]}; flag = out[7:4]; end
	data_error: begin predicted_result = DATA_ERROR; result = out[52:45]; end
	crc_error: begin predicted_result = CRC_ERROR; result = out[52:45]; end
	op_error: begin predicted_result = OP_ERROR; result = out[52:45]; end
      endcase // case (op_set)
	//if(op_set ==(and_op || or_op || add_op || sub_op))
	//result = {out[52:45],out[41:34],out[30:23],out[19:12]};
	//else result = out[52:45];
        if (q1.name == (and_op||sub_op||or_op||add_op)) begin
        	if ((predicted_result == result)&&(predicted_flag == flag)) 
			$display("PASSED %h op: %s, f %h", result, q1.name(), flag); 
          
		else $error ("FAILED: A: %0h  B: %0h  op: %s result: %0h predicted_result: %0h flag: %0h predicted_flag: %0h",
                 	 A, B, q1.name(), result, predicted_result, flag, predicted_flag); end
	else begin
        	if ((predicted_result == result))
		$display("PASSED %h op: %s", result, q1.name());
          
		else $error ("FAILED: A: %0h  B: %0h  op: %s result: %0h predicted_result: %0h",
                  A, B, q1.name(), result, predicted_result); end
	done = 1'b0;
   end : scoreboard
   
endmodule : top
