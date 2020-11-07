
class scoreboard;
    virtual alu_bfm bfm;

    function new (virtual alu_bfm b);
        bfm = b;
    endfunction : new

bit [31:0]  result; int predicted_result; bit [3:0] predicted_flag;int flag;

task check_flags();
//always @(*) begin
//FLAGS = { Carry, Overflow, Zero, Negative }
predicted_flag[1] = (predicted_result == 0); //zero_f
predicted_flag[0] = predicted_result[31]; //negative_f
predicted_flag[3] = (((bfm.op_set == add_op) && ((predicted_result < bfm.A) || (predicted_result < bfm.B))) || ((bfm.op_set == sub_op) && (bfm.A < predicted_result))); //carry_f
predicted_flag[2] = (((bfm.op_set == add_op) && !(bfm.A[31]^bfm.B[31]) && (bfm.A[31]^predicted_result[31])) || ((bfm.op_set == sub_op) && !(bfm.A[31]^predicted_result[31]) && (bfm.B[31]^predicted_result[31]))); //overflow_f

//end
endtask : check_flags



task execute();
	
     forever begin : self_checker
     @(posedge bfm.done)
	check_flags();
      
      #1;
	//q1=queue_op.pop_back();
// a1=queue_A.pop_back(); 
 //b1=queue_B.pop_back();
      case (bfm.op_set)
        add_op: begin predicted_result = bfm.A + bfm.B; result = {bfm.out[52:45],bfm.out[41:34],bfm.out[30:23],bfm.out[19:12]}; flag = bfm.out[7:4]; end
        and_op: begin predicted_result = bfm.A & bfm.B; result = {bfm.out[52:45],bfm.out[41:34],bfm.out[30:23],bfm.out[19:12]}; flag = bfm.out[7:4]; end
        or_op: begin predicted_result = bfm.A | bfm.B; result = {bfm.out[52:45],bfm.out[41:34],bfm.out[30:23],bfm.out[19:12]}; flag = bfm.out[7:4]; end
        sub_op: begin predicted_result = bfm.B - bfm.A; result = {bfm.out[52:45],bfm.out[41:34],bfm.out[30:23],bfm.out[19:12]}; flag = bfm.out[7:4]; end
	data_error: begin predicted_result = DATA_ERROR; result = bfm.out[52:45]; end
	crc_error: begin predicted_result = CRC_ERROR; result = bfm.out[52:45]; end
	op_error: begin predicted_result = OP_ERROR; result = bfm.out[52:45]; end
      endcase // case (op_set)
	//if(op_set ==(and_op || or_op || add_op || sub_op))
	//result = {bfm.out[52:45],bfm.out[41:34],bfm.out[30:23],bfm.out[19:12]};
	//else result = bfm.out[52:45];
        if (bfm.op_set.name == (and_op||sub_op||or_op||add_op)) 
        	if ((predicted_result != result)||(predicted_flag != flag))begin $error ("FAILED: A: %0h  B: %0h  op: %s result: %0h 			predicted_result: %0h flag: %0h predicted_flag: %0h",
                 	 bfm.A, bfm.B, bfm.op_set.name(), result, predicted_result, flag, predicted_flag); end
			 
          
		//else $display("PASSED %h op: %s, f %h", result, bfm.op_set.name(), flag); 
	else 
        	if ((predicted_result != result)) begin
		$error ("FAILED: A: %0h  B: %0h  op: %s result: %0h predicted_result: %0h",
                  bfm.A, bfm.B, bfm.op_set.name(), result, predicted_result); end
          
		//else $display("PASSED %h op: %s", result, bfm.op_set.name()); 
	bfm.done = 1'b0;
        end : self_checker
    endtask : execute


endclass : scoreboard


