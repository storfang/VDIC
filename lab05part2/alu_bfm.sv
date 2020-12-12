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
interface alu_bfm;
import uvm_pkg::*;
`include "uvm_macros.svh"
import alu_pkg::*;

   bit [31:0]    A;
   bit [31:0]    B; 
   bit          clk;
  // bit          reset_n;
   bit [2:0]   op;
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

//bit [31:0]    queue_A[$];
//bit [31:0]    queue_B[$];
//bit [2:0]    queue_op[$];
//bit [3:0] flag;
//bit [3:0] predicted_flag;
//bit [31:0] predicted_result;

reg [7:0] CTL;
//reg pass, passes;
//reg [67:0] data;

int i,j,k,l,j_nxt,l_nxt,g ;
bit [54:0] out, out_nxt;
bit start;

initial begin
    clk = 0;
    forever begin
        #10;
        clk = ~clk;
    end
end


task reset_alu();
    rst_n = 1'b0;
	sin = 1'b1;
    @(negedge clk);
    @(negedge clk);
    rst_n = 1'b1;
  //  start   = 1'b0;
endtask : reset_alu
/*
task send_op(input byte iA, input byte iB, input operation_t iop, output shortint alu_result);

    op_set = iop;

    if (iop == rst_op) begin
        @(posedge clk);
        reset_n = 1'b0;
        start   = 1'b0;
        @(posedge clk);
        #1;
        reset_n = 1'b1;
    end else begin
        @(negedge clk);
        A       = iA;
        B       = iB;
        start   = 1'b1;
        if (iop == no_op) begin
            @(posedge clk);
            #1;
            start = 1'b0;
        end else begin
            do
                @(negedge clk);
            while (done == 0);
            start = 1'b0;
        end
    end // else: !if(iop == rst_op)

endtask : send_op
*/
task send_byte(input [7:0] essence, input frame_type);
begin
	@(negedge clk);
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
	//@(negedge clk);
	end
endtask

task send_calculation_data;
  input [71:0] bytes; //
  begin
	B={bytes[31:24],bytes[23:16],bytes[15:8],bytes[7:0]};
	A={bytes[63:56],bytes[55:48],bytes[47:40],bytes[39:32]};
	op_set=bytes[70:68];// $display("op %b",op);
	start=1;#30; start=0;
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

task send_calculation_data_fake;
  input [71:0] bytes; //
  begin
	B={bytes[31:24],bytes[23:16],bytes[15:8],bytes[7:0]};
	A={bytes[63:56],bytes[55:48],bytes[47:40],bytes[39:32]};
	op_set=bytes[70:68];// $display("op %b",op);
	start=1;#30; start=0;
	repeat(9) send_byte(8'b11111111,0);
      /*send_byte(bytes[31:24],0);
      send_byte(bytes[23:16],0);
      send_byte(bytes[15:8],0);
      send_byte(bytes[7:0],0);
      send_byte(bytes[63:56],0);
      send_byte(bytes[55:48],0);
      send_byte(bytes[47:40],0);
      send_byte(bytes[39:32],0);
      send_byte(bytes[71:64],1);*/

  end
endtask

task send_calculation_data_fake2;
  input [71:0] bytes; //
  begin
	B={bytes[31:24],bytes[23:16],bytes[15:8],bytes[7:0]};
	A={bytes[63:56],bytes[55:48],bytes[47:40],bytes[39:32]};
	op_set=crc_error;// $display("op %b",op);
	start=1;#30; start=0;
	//repeat(9) bfm.send_byte(8'b11111111,0);
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


task recive_output(output [54:0] out);
l=0;l_nxt=0;j=0;j_nxt=0;
repeat(55) begin

// begin
if (l > 0 && l < 55) begin
  out_nxt[l-1] = sout;
  l_nxt = l - 1;
end
else if (l == 0) begin
  l_nxt = 56;
done = 1'b0;
  end
else if (sout == 0) begin
  l_nxt = 54;
  out_nxt[54] = 0;
end
j_nxt = j + 1;
//end

@(posedge clk) begin
j = j_nxt;
out = out_nxt;
l = l_nxt;
end
end

endtask
	
	/*task capture_output(output [54:0] out);
	begin
		//wait_for_sof;
		while(sout==0);
		@(negedge clk);
		repeat (55)
		begin
//$display("");
		
			out <= {out[53:0], sout};
			@(negedge clk);
		end
	end
	endtask*/

command_monitor command_monitor_h;


function operation_t op2enum();
    operation_t opi;
    if( ! $cast(opi,op) )
        $fatal(1, "Illegal operation on op bus");
    return opi;
endfunction : op2enum
/*function operation_t op2enum();
    case(op)
        3'b000 : return and_op;
        3'b001 : return or_op;
        3'b100 : return and_op;
        3'b101 : return sub_op;
        3'b100 : return data_error;
	3'b011 : return op_error;
	3'b110 : return crc_error;
        default : $fatal(1, "Illegal operation on op bus");
    endcase // case (op)
endfunction : op2enum
*/
/*always @(posedge clk) begin : op_monitor
    static bit in_command = 0;
   // command_s command;
    if (start) begin : start_high
      //  if (!in_command) begin : new_command
          //  command.A  = A;
           // command.B  = B;
          //  command.op = op2enum();
//$display("bfm values: A: %0h  B: %0h  op: %s ",A, command.B, command.op.name());
            command_monitor_h.write_to_monitor(A, B, op2enum());
           // in_command = (command.op);
       // end : new_command
    end : start_high
   // else // start low
   // in_command            = 0;
end : op_monitor
*/

always @(posedge clk) begin : op_monitor
    static bit in_command = 0;
    command_transaction command;
    if (start) begin : start_high
        if (!in_command) begin : new_command
            command_monitor_h.write_to_monitor(A, B, op2enum());
            in_command = (op2enum() != (3'b111));
        end : new_command
    end : start_high
    else // start low
    in_command            = 0;
end : op_monitor

/*always @(negedge rst_n) begin : rst_monitor
    command_s command;
    command.op = rst_op;
    if (command_monitor_h != null) //guard against VCS time 0 negedge
        command_monitor_h.write_to_monitor(command);
end : rst_monitor
*/
result_monitor result_monitor_h;

initial begin : result_monitor_thread
reset_alu();
    forever begin
        @(posedge done) ;begin
        //if (done)
	result = {out[52:45],out[41:34],out[30:23],out[19:12]};
            result_monitor_h.write_to_monitor(result); end
    end
end : result_monitor_thread
endinterface : alu_bfm


