/*                                                                      
 Copyright 2018-2020 Nuclei System Technology, Inc.                
                                                                         
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
                                                                         
                                                                         
                                                                         
//=====================================================================
//
// Designer   : Bob Hu
//
// Description:
//  The simulation model of SRAM
//
// ====================================================================
module sirv_sim_ram 
#(parameter DP = 512,
  parameter FORCE_X2ZERO = 0,
  parameter DW = 32,
  parameter MW = 4,
  parameter AW = 32 
)
(
  input             clk, 
  input  rst_n,
  input  [DW-1  :0] din, 
  input  [AW-1  :0] addr,
  input             cs,
  input             we,
  input  [MW-1:0]   wem,
  output [DW-1:0]   dout,
  output mem_addr_ok,
  output mem_data_ok
);

    reg [DW-1:0] mem_r [0:DP-1];
    reg [AW-1:0] addr_r;
    wire [MW-1:0] wen;
    wire ren;


    reg read_data_ok;
    reg write_data_ok;
    assign mem_addr_ok = cs & rst_n;
    assign mem_data_ok = write_data_ok | read_data_ok;
    
    assign ren = cs & (~we);
    assign wen = ({MW{cs & we}} & wem);
    
//    integer j;
//    initial begin
//        for( j = 0; j < DP; j = j + 1)begin
//            mem_r[j] <= 32'hffffffff;  
//       end
//    end

    genvar i;

    always @(posedge clk)
    begin
        if(~rst_n)begin
            addr_r <= 0;
            read_data_ok <= 1'b0;
        end
        else if (ren)begin
            addr_r <= addr;
            read_data_ok <= 1'b1;
        end
        else begin
            read_data_ok <= 1'b0;
        end
    end
    
    always @(posedge clk)
    begin
        if(~rst_n)begin
            write_data_ok <= 1'b0;
        end
        else if (cs & we)begin
            write_data_ok <= 1'b1;
        end
        else begin
            write_data_ok <= 1'b0;
        end
    end
    
    generate
      for (i = 0; i < MW; i = i+1) begin :mem
        if((8*i+8) > DW ) begin: last
          always @(posedge clk) begin
            if (wen[i]) begin
               mem_r[addr][DW-1:8*i] <= din[DW-1:8*i];
            end
          end
        end
        else begin: non_last
          always @(posedge clk) begin
            if (wen[i]) begin
               mem_r[addr][8*i+7:8*i] <= din[8*i+7:8*i];
            end
          end
        end
      end
    endgenerate
//    generate
//      for (i = 0; i < MW; i = i+1) begin :mem
//        if((8*i+8) > DW ) begin: last
//          always @(posedge clk) begin
//            if(~rst_n)begin
//               mem_r[addr][DW-1:8*i] <= 0;
//            end
//            else if (wen[i]) begin
//               mem_r[addr][DW-1:8*i] <= din[DW-1:8*i];
//            end
//          end
//        end
//        else begin: non_last
//          always @(posedge clk) begin
//            if(~rst_n)begin
//               mem_r[addr][8*i+7:8*i] <= 0;
//            end
//            else if (wen[i]) begin
//               mem_r[addr][8*i+7:8*i] <= din[8*i+7:8*i];
//            end
//          end
//        end
//      end
//    endgenerate

  wire [DW-1:0] dout_pre;
  assign dout_pre = mem_r[addr_r];

  generate
   if(FORCE_X2ZERO == 1) begin: force_x_to_zero
      for (i = 0; i < DW; i = i+1) begin:force_x_gen 
          `ifndef SYNTHESIS//{
         assign dout[i] = (dout_pre[i] === 1'bx) ? 1'b0 : dout_pre[i];
          `else//}{
         assign dout[i] = dout_pre[i];
          `endif//}
      end
   end
   else begin:no_force_x_to_zero
     assign dout = dout_pre;
   end
  endgenerate

 
endmodule