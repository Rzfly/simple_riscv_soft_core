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

// CSR�Ĵ���ģ��
module csr_reg(

    input wire clk,
    input wire rst_n,

    // form ex
    input wire we_i,                            // exģ��д�Ĵ�����־
    input wire[`CsrMemAddrWIDTH - 1 :0]  raddr_i,        // exģ����Ĵ�����ַ
    input wire[`CsrMemAddrWIDTH - 1 :0]  waddr_i,        // exģ��д�Ĵ�����ַ
    input wire[`DATA_WIDTH - 1:0]     data_i,             // exģ��д�Ĵ�������

    // from clint
    input wire clint_we_i,                  // clintģ��д�Ĵ�����־
    input wire[`MemAddrWIDTH - 1 :0] clint_raddr_i,  // clintģ����Ĵ�����ַ
    input wire[`MemAddrWIDTH - 1 :0] clint_waddr_i,  // clintģ��д�Ĵ�����ַ
    input wire[`DATA_WIDTH - 1:0] clint_data_i,       // clintģ��д�Ĵ�������

    output wire global_int_en_o,            // ȫ���ж�ʹ�ܱ�־

    // to clint
    output reg [`DATA_WIDTH - 1:0] clint_data_o,       // clintģ����Ĵ�������
    output wire[`DATA_WIDTH - 1:0] clint_csr_mtvec,   // mtvec
    output wire[`DATA_WIDTH - 1:0] clint_csr_mepc,    // mepc
    output wire[`DATA_WIDTH - 1:0] clint_csr_mstatus, // mstatus

    // to ex
    output reg [`DATA_WIDTH - 1:0] data_o              // exģ����Ĵ�������
    );

    //��ʱ������
    reg[2*`DATA_WIDTH - 1:0] cycle;
    //�쳣��ڵ�ַ
    reg[`DATA_WIDTH - 1:0] mtvec;
    //�쳣����ԭ��
    reg[`DATA_WIDTH - 1:0] mcause;
   //�쳣֮ǰ�ĵ�ַ
    reg[`DATA_WIDTH - 1:0] mepc;
    //�ж�����
    reg[`DATA_WIDTH - 1:0] mie;
    //״̬�Ĵ��� �����ж�ʹ�� 
    reg[`DATA_WIDTH - 1:0] mstatus;
    //��ʱ����Ĵ���
    reg[`DATA_WIDTH - 1:0] mscratch;

    assign global_int_en_o = (mstatus[3] == 1'b1)? `True: `False;

    assign clint_csr_mtvec = mtvec;
    assign clint_csr_mepc = mepc;
    assign clint_csr_mstatus = mstatus;

    // cycle counter
    // ��λ�������һֱ����
    always @ (posedge clk) begin
        if (~rst_n) begin
            cycle <= 0;
        end else begin
            cycle <= cycle + 1'b1;
        end
    end

    // write reg
    // д�Ĵ�������
    always @ (posedge clk) begin
        if (~rst_n) begin
            mtvec <=  0;
            mcause <= 0;
            mepc <= 0;
            mie <= 0;
            mstatus <= 0;
            mscratch <= 0;
        end else begin
            // ������Ӧexģ���д����
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
            // clintģ��д����
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
    // exģ���CSR�Ĵ���
    always @ (*) begin
        if ((waddr_i[`CsrMemAddrWIDTH - 1:0] == raddr_i[`CsrMemAddrWIDTH - 1:0]) && (we_i == 1'b1)) begin
            data_o = data_i;
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

    // read reg
    // clintģ���CSR�Ĵ���
    always @ (*) begin
        if ((clint_waddr_i[`CsrMemAddrWIDTH - 1:0]  == clint_raddr_i[`CsrMemAddrWIDTH - 1:0] ) && (clint_we_i == 1'b1)) begin
            clint_data_o = clint_data_i;
        end else begin
            case (clint_raddr_i[`CsrMemAddrWIDTH - 1:0] )
                `CSR_CYCLE: begin
                    clint_data_o = cycle[`DATA_WIDTH - 1:0];
                end
                `CSR_CYCLEH: begin
                    clint_data_o <= cycle[2*`DATA_WIDTH - 1:`DATA_WIDTH];
                end
                `CSR_MTVEC: begin
                    clint_data_o <= mtvec;
                end
                `CSR_MCAUSE: begin
                    clint_data_o <= mcause;
                end
                `CSR_MEPC: begin
                    clint_data_o <= mepc;
                end
                `CSR_MIE: begin
                    clint_data_o <= mie;
                end
                `CSR_MSTATUS: begin
                    clint_data_o <= mstatus;
                end
                `CSR_MSCRATCH: begin
                    clint_data_o <= mscratch;
                end
                default: begin
                    clint_data_o <= 0;
                end
            endcase
        end
    end

endmodule