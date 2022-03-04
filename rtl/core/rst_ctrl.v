 /*                                                                      
 Copyright 2020 Blue Liang, liangkangnan@163.com
                                                                         
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

`include "include.v"

// 澶嶄綅鎺у埗妯″潡
module rst_ctrl(

    input wire clk,

    input wire rst_ext_i,
    input wire rst_jtag_i,

    output wire core_rst_n_o,
    output wire jtag_rst_n_o

    );

    wire ext_rst_r;

    gen_ticks_sync #(
        .DP(2),
        .DW(1)
    ) ext_rst_sync(
        .rst_n(rst_ext_i),
        .clk(clk),
        .din(1'b1),
        .dout(ext_rst_r)
    );

    reg[`JTAG_RESET_FF_LEVELS-1:0] jtag_rst_r;

    always @ (posedge clk) begin
        if (!rst_ext_i) begin
            jtag_rst_r[`JTAG_RESET_FF_LEVELS-1:0] <= {`JTAG_RESET_FF_LEVELS{1'b1}};
        end if (rst_jtag_i) begin
            jtag_rst_r[`JTAG_RESET_FF_LEVELS-1:0] <= {`JTAG_RESET_FF_LEVELS{1'b0}};
        end else begin
            jtag_rst_r[`JTAG_RESET_FF_LEVELS-1:0] <= {jtag_rst_r[`JTAG_RESET_FF_LEVELS-2:0], 1'b1};
        end
    end

    assign core_rst_n_o = ext_rst_r & jtag_rst_r[`JTAG_RESET_FF_LEVELS-1];
    assign jtag_rst_n_o = ext_rst_r;

endmodule

// 将输入打DP拍后输出
module gen_ticks_sync #(
    parameter DP = 2,
    parameter DW = 32)(

    input wire rst_n,
    input wire clk,

    input wire[DW-1:0] din,
    output wire[DW-1:0] dout

    );

    wire[DW-1:0] sync_dat[DP-1:0];

    genvar i;

    generate 
        for (i = 0; i < DP; i = i + 1) begin: ticks_sync
            if (i == 0) begin: dp_is_0
                gen_rst_0_dff #(DW) rst_0_dff(clk, rst_n, din, sync_dat[0]);
            end else begin: dp_is_not_0
                gen_rst_0_dff #(DW) rst_0_dff(clk, rst_n, sync_dat[i-1], sync_dat[i]);
            end
        end
    endgenerate

    assign dout = sync_dat[DP-1];
  
endmodule

// 复位后输出为0的触发器
module gen_rst_0_dff #(
    parameter DW = 32)(

    input wire clk,
    input wire rst_n,

    input wire[DW-1:0] din,
    output wire[DW-1:0] qout

    );

    reg[DW-1:0] qout_r;

//    always @ (posedge clk or negedge rst_n) begin
    always @ (posedge clk) begin
        if (!rst_n) begin
            qout_r <= {DW{1'b0}};
        end else begin                  
            qout_r <= din;
        end
    end

    assign qout = qout_r;

endmodule