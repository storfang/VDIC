
class scoreboard extends uvm_subscriber #(result_transaction);
/*    `uvm_component_utils(scoreboard)

    virtual alu_bfm bfm;
    uvm_tlm_analysis_fifo #(command_transaction) cmd_f;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        cmd_f = new ("cmd_f", this);
    endfunction : build_phase

bit [31:0]  result; int predicted_result; bit [3:0] predicted_flag;int flag;*/

/*task check_flags(command_transaction cmd);
command_transaction bfm;
//always @(*) begin
//FLAGS = { Carry, Overflow, Zero, Negative }
//predicted_result = t;
predicted_flag[1] = (predicted_result == 0); //zero_f
predicted_flag[0] = predicted_result[31]; //negative_f
predicted_flag[3] = (((bfm.op == add_op) && ((predicted_result < bfm.A) || (predicted_result < bfm.B))) || ((bfm.op == sub_op) && (bfm.A < predicted_result))); //carry_f
predicted_flag[2] = (((bfm.op == add_op) && !(bfm.A[31]^bfm.B[31]) && (bfm.A[31]^predicted_result[31])) || ((bfm.op == sub_op) && !(bfm.A[31]^predicted_result[31]) && (bfm.B[31]^predicted_result[31]))); //overflow_f

//end
endtask : check_flags
*/

 /*   function void predict_result(command_transaction cmd, result_transaction t);
        result_transaction predicted;

        predicted = new("predicted");

        case (cmd.op)
        	add_op: begin predicted_result = cmd.A + cmd.B; result = {t[52:45],t[41:34],t[30:23],t[19:12]}; flag = t[7:4]; end
        	and_op: begin predicted_result = cmd.A & cmd.B; result = {t[52:45],t[41:34],t[30:23],t[19:12]}; flag = t[7:4]; end
        	or_op: begin predicted_result = cmd.A | cmd.B; result = {t[52:45],t[41:34],t[30:23],t[19:12]}; flag = t[7:4]; end
        	sub_op: begin predicted_result = cmd.B - cmd.A; result = {t[52:45],t[41:34],t[30:23],t[19:12]}; flag = t[7:4]; end
		data_error: begin predicted_result = DATA_ERROR; result = t[52:45]; end
		crc_error: begin predicted_result = CRC_ERROR; result = t[52:45]; end
		op_error: begin predicted_result = OP_ERROR; result = t[52:45]; end
        endcase // case (op_set)

       // return predicted;

    endfunction : predict_result*/

	//function bit [31:0] extract_data(cmd);


//function void write(result_transaction t);
//command_transaction cmd;	
//$display("%b", t);
//result_transaction predicted;
   /*  do
            if (!cmd_f.try_get(cmd))begin
		$display("cmd %h", cmd);
                $fatal(1, "Missing command in self checker"); end
        while  (1);*/
	//$display("T %h", t);
	//check_flags(cmd);
      
    //  #1;
///////	predict_result(cmd, t);
	//q1=queue_op.pop_back();
// a1=queue_A.pop_back(); 
 //b1=queue_B.pop_back();
     /* case (cmd.op)
        add_op: begin predicted_result = cmd.A + cmd.B; result = {t[52:45],t[41:34],t[30:23],t[19:12]}; flag = t[7:4]; end
        and_op: begin predicted_result = cmd.A & cmd.B; result = {t[52:45],t[41:34],t[30:23],t[19:12]}; flag = t[7:4]; end
        or_op: begin predicted_result = cmd.A | cmd.B; result = {t[52:45],t[41:34],t[30:23],t[19:12]}; flag = t[7:4]; end
        sub_op: begin predicted_result = cmd.B - cmd.A; result = {t[52:45],t[41:34],t[30:23],t[19:12]}; flag = t[7:4]; end
	data_error: begin predicted_result = DATA_ERROR; result = t[52:45]; end
	crc_error: begin predicted_result = CRC_ERROR; result = t[52:45]; end
	op_error: begin predicted_result = OP_ERROR; result = t[52:45]; end
      endcase // case (op_set)
	//if(op_set ==(and_op || or_op || add_op || sub_op))
	//result = {t[52:45],t[41:34],t[30:23],t[19:12]};
	//else result = t[52:45];
        if (cmd.op.name == (and_op||sub_op||or_op||add_op)) 
        	if ((predicted_result != result)||(predicted_flag != flag))begin $error ("FAILED: A: %0h  B: %0h  op: %s result: %0h 			predicted_result: %0h flag: %0h predicted_flag: %0h",
                 	 cmd.A, cmd.B, cmd.op.name(), result, predicted_result, flag, predicted_flag); end
			 
          
		//else $display("PASSED %h op: %s, f %h", result, cmd.op.name, flag); 
	else 
        	if ((predicted_result != result)) begin
		$error ("FAILED: A: %0h  B: %0h  op: %s result: %0h predicted_result: %0h",
                  cmd.A, cmd.B, cmd.op.name(), result, predicted_result); end
          
		//else $display("PASSED %h op: %s", result, bfm.op_set.name()); 
	//bfm.done = 1'b0;
   */     
   // endfunction

 /*   function void write(result_transaction t);
        string data_str;
        command_transaction cmd;
        result_transaction predicted;

        do
            if (!cmd_f.try_get(cmd))
                $fatal(1, "Missing command in self checker");
        while (cmd.op == no_op);

        predicted = predict_result(cmd);

        data_str  = { cmd.convert2string(),
            " ==>  Actual " , t.convert2string(),
            "/Predicted ",predicted.convert2string()};


        if (!predicted.compare(t))
            `uvm_error("SELF CHECKER", {"FAIL: ",data_str})
        else
            `uvm_info ("SELF CHECKER", {"PASS: ", data_str}, UVM_HIGH)

    endfunction : write*/
    `uvm_component_utils(scoreboard)

    uvm_tlm_analysis_fifo #(command_transaction) cmd_f;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        cmd_f = new ("cmd_f", this);
    endfunction : build_phase

    function result_transaction predict_result(command_transaction cmd);
        result_transaction predicted;

        predicted = new("predicted");

        case (cmd.op)
            add_op: predicted.result = cmd.A + cmd.B;
            and_op: predicted.result = cmd.A & cmd.B;
            or_op: predicted.result = cmd.A | cmd.B;
            sub_op: predicted.result = cmd.B - cmd.A;
	    data_error: predicted.result = {DATA_ERROR,24'hFFFFFF};
	    crc_error: predicted.result = {CRC_ERROR,24'hFFFFFF};
	    op_error: predicted.result = {OP_ERROR,24'hFFFFFF};
        endcase // case (op_set)

        return predicted;

    endfunction : predict_result


    function void write(result_transaction t);
        string data_str;
        command_transaction cmd;
        result_transaction predicted;

       // do
            if (!cmd_f.try_get(cmd))
                $fatal(1, "Missing command in self checker");
       // while (1);

        predicted = predict_result(cmd);

        data_str  = { cmd.convert2string(),
            " ==>  Actual " , t.convert2string(),
            "/Predicted ",predicted.convert2string()};


        if (!predicted.compare(t))
            `uvm_error("SELF CHECKER", {"FAIL: ",data_str})
        else
            `uvm_info ("SELF CHECKER", {"PASS: ", data_str}, UVM_HIGH)

    endfunction : write

endclass : scoreboard


