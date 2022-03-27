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

// CSR寄存器模块
module csr_reg(

    input wire clk,
    input wire rst_n,

    // form ex
    input wire we_i,                            // ex模块写寄存器标志
    input wire[`CsrMemAddrWIDTH - 1 :0]  raddr_i,        // ex模块读寄存器地址
    input wire[`CsrMemAddrWIDTH - 1 :0]  waddr_i,        // ex模块写寄存器地址
    input wire[`DATA_WIDTH - 1:0]     data_i,             // ex模块写寄存器数据
    // to ex
    output reg [`DATA_WIDTH - 1:0] data_o,              // ex模块读寄存器数据
    
    // from clint
    input wire clint_we_i,                  // clint模块写寄存器标志
    input wire[`MemAddrWIDTH - 1 :0] clint_waddr_i,  // clint模块写寄存器地址
    input wire[`DATA_WIDTH - 1:0] clint_data_i,       // clint模块写寄存器数据

    // to clint
    output wire[`DATA_WIDTH - 1:0] clint_csr_mtvec,   // mtvec
    output wire[`DATA_WIDTH - 1:0] clint_csr_mepc,    // mepc
    output wire[`DATA_WIDTH - 1:0] clint_csr_mstatus  // mstatus

    );

    //定时计数器
    reg[2*`DATA_WIDTH - 1:0] cycle;
    //异常入口地址
    reg[`DATA_WIDTH - 1:0] mtvec;
    //异常出错原因
    reg[`DATA_WIDTH - 1:0] mcause;
   //异常之前的地址
    reg[`DATA_WIDTH - 1:0] mepc;
    //中断屏蔽
    reg[`DATA_WIDTH - 1:0] mie;
    //状态寄存器 管理中断使能 
    reg[`DATA_WIDTH - 1:0] mstatus;
    //临时保存寄存器
    reg[`DATA_WIDTH - 1:0] mscratch;

    assign clint_csr_mtvec = mtvec;
    assign clint_csr_mepc = mepc;
    assign clint_csr_mstatus = mstatus;
        
    // cycle counter
    // 复位撤销后就一直计数
    always @ (posedge clk) begin
        if (~rst_n) begin
            cycle <= 0;
        end else begin
            cycle <= cycle + 1'b1;
        end
    end

    // write reg
    // 写寄存器操作
    always @ (posedge clk) begin
        if (~rst_n) begin
            mtvec <=  0;
            mcause <= 0;
            mepc <= 0;
            mie <= 0;
            mstatus <= 0;
            mscratch <= 0;
        end else begin
            // 优先响应ex模块的写操作
            if (we_i) begin
                case (waddr_i[`CsrMemAddrWIDTH - 1:0])
                    `CSR_MTVEC: begin
                        mtvec <= data_i;
                    end
                    `CSR_MCAUSE: begin
                        mcause <= data_i;
                    end
                    `CSR_MEPC: begin
                        mepc <= data_i;
                    end
                    `CSR_MIE: begin
                        mie <= data_i;
                    end
                    `CSR_MSTATUS: begin
                        mstatus <= data_i;
                    end
                    `CSR_MSCRATCH: begin
                        mscratch <= data_i;
                    end
                    default: begin

                    end
                endcase
            // clint模块写操作
            end else if (clint_we_i) begin
                case (clint_waddr_i[`CsrMemAddrWIDTH- 1:0])
                    `CSR_MTVEC: begin
                        mtvec <= clint_data_i;
                    end
                    `CSR_MCAUSE: begin
                        mcause <= clint_data_i;
                    end
                    `CSR_MEPC: begin
                        mepc <= clint_data_i;
                    end
                    `CSR_MIE: begin
                        mie <= clint_data_i;
                    end
                    `CSR_MSTATUS: begin
                        mstatus <= clint_data_i;
                    end
                    `CSR_MSCRATCH: begin
                        mscratch <= clint_data_i;
                    end
                    default: begin

                    end
                endcase
            end
        end
    end

    // read reg
    // ex模块读CSR寄存器
    always @ (*) begin
        if ((waddr_i[`CsrMemAddrWIDTH - 1:0] == raddr_i[`CsrMemAddrWIDTH - 1:0]) && (we_i == 1'b1)) begin
            data_o <= data_i;
        end else begin
            case (raddr_i[`CsrMemAddrWIDTH - 1:0])
                `CSR_CYCLE: begin
                    data_o <= cycle[31:0];
                end
                `CSR_CYCLEH: begin
                    data_o <= cycle[63:32];
                end
                `CSR_MTVEC: begin
                    data_o <= mtvec;
                end
                `CSR_MCAUSE: begin
                    data_o <= mcause;
                end
                `CSR_MEPC: begin
                    data_o <= mepc;
                end
                `CSR_MIE: begin
                    data_o <= mie;
                end
                `CSR_MSTATUS: begin
                    data_o <= mstatus;
                end
                `CSR_MSCRATCH: begin
                    data_o <= mscratch;
                end
                default: begin
                    data_o <= 0;
                end
            endcase
        end
    end

endmodule