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
module top;
   alu_bfm    bfm();
   tester_alu     tester_i    (bfm);
   coverage_alu   coverage_i  (bfm);
   scoreboard_alu scoreboard_i(bfm);
   
   mtm_Alu DUT (.clk(bfm.clk), .rst_n(bfm.rst_n),.sin(bfm.sin), .sout(bfm.sout));
endmodule : top

     
   
