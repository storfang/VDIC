/******************************************************************************
* DVT CODE TEMPLATE: interface
* Created by moleszkowicz on Jan 22, 2021
* uvc_company = mo, uvc_name = alu
*******************************************************************************/

//------------------------------------------------------------------------------
//
// INTERFACE: mo_alu_if
//
//------------------------------------------------------------------------------
`timescale 1ns/1ps
// Just in case you need them
`include "uvm_macros.svh"

interface mo_alu_if(clk,rst_n);

	// Just in case you need it
	import uvm_pkg::*;
	import  mo_alu_pkg::*;
	// Clock and reset signals
	input clk;
	input rst_n;

	// Flags to enable/disable assertions and coverage
	bit checks_enable=1;
	bit coverage_enable=1;

	// TODO Declare interface signals here
	
	bit sin;
	bit sout;
	bit [31:0]    A;
   bit [31:0]    B; 
  // bit          clk;
  // bit          reset_n;
   bit [2:0]   op;
  // bit          start;
   bit         done;
   bit [31:0]  result;
   operation_t  op_set;

   assign op = op_set;


operation_t q1;
assign q1=op_set;
	//logic valid;
	//logic[7:0] data;
integer i,j,k,l,j_nxt,l_nxt,g ;
bit [54:0] out, out_nxt;
bit start;
	//You can add covergroups in interfaces
	//covergroup signal_coverage@(posedge clk);
		//add coverpoints here
	//endgroup
	// You must instantiate the covergroup to collect coverage
	//signal_coverage sc=new;

/*	// TODO You can add SV assertions in interfaces
	my_assertion:assert property (
			@(posedge clock) disable iff (reset === 1'b0 || !checks_enable)
			valid |-> (data!==8'bXXXX_XXXX)
		)
	else
		`uvm_error("ERR_TAG","Error")
*/

/*task reset_alu();
    rst_n = 1'b0;
	sin = 1'b1;
    @(negedge clk);
    @(negedge clk);
    rst_n = 1'b1;
  //  start   = 1'b0;
endtask : reset_alu*/

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
	repeat(9) mo_alu_if.send_byte(8'b11111111,0);
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

endinterface : mo_alu_if
