`include "include.v"


// core local interruptor module
// 核心中断管理、仲裁模块
module clint(

    input wire clk,
    input wire rst_n,
    
    // from core
    input wire[`INT_BUS] int_flag_i,         // 中断输入信号

    // from exu
    input wire inst_ecall_i,                    // ecall指令
    input wire inst_ebreak_i,                   // ebreak指令
    input wire inst_mret_i,                     // mret指令
    input wire memory_access_missalign,
    input wire [`BUS_WIDTH - 1:0] inst_addr_i,     // 指令地址
//    input wire jump_flag_i,
    
    // from csr_reg
    input wire[`DATA_WIDTH - 1:0] csr_mtvec,           // mtvec寄存器
    input wire[`DATA_WIDTH - 1:0] csr_mepc,            // mepc寄存器
    input wire[`DATA_WIDTH - 1:0] csr_mstatus,         // mstatus寄存器

    // to csr_reg
    output reg we_o,                         // 写CSR寄存器标志
    output reg [`BUS_WIDTH - 1:0] waddr_o,         // 写CSR寄存器地址
    output reg [`DATA_WIDTH - 1:0] data_o,              // 写CSR寄存器数据

    // to ex
    output wire stall_flag_o,                 // 流水线暂停标志
    output reg [`BUS_WIDTH - 1:0] int_addr_o,     // 中断入口地址
    output reg int_assert_o                  // 中断标志
  );

    
    wire global_int_en;
    assign  global_int_en = csr_mstatus[3];
    // 中断状态定义
    localparam S_INT_IDLE            = 4'b0001;
    localparam S_INT_SYNC_ASSERT     = 4'b0010;
    localparam S_INT_ASYNC_ASSERT    = 4'b0100;
    localparam S_INT_MRET            = 4'b1000;

    // 写CSR寄存器状态定义
    localparam S_CSR_IDLE            = 5'b00001;
    localparam S_CSR_MSTATUS         = 5'b00010;
    localparam S_CSR_MEPC            = 5'b00100;
    localparam S_CSR_MSTATUS_MRET    = 5'b01000;
    localparam S_CSR_MCAUSE          = 5'b10000;

    reg[3:0] int_state;
    reg[4:0] csr_state;
    //pc
    reg[`InstAddrBus] inst_addr;
    reg[31:0] cause;

    wire ex_pipe_ok;
    
    assign stall_flag_o = ((int_state != S_INT_IDLE) | (csr_state != S_CSR_IDLE))? 1'b1: 1'b0;
    
    // 中断仲裁逻辑
    always @ (*) begin
        if (!rst_n) begin
            int_state <= S_INT_IDLE;
        end 
        else if ((int_flag_i != `INT_NONE) && (global_int_en )) begin
                int_state <= S_INT_ASYNC_ASSERT;
        end
        else begin
            if (inst_ecall_i || inst_ebreak_i || memory_access_missalign) begin
                // 如果执行阶段的指令为除法指令，则先不处理同步中断，等除法指令执行完再处理
                int_state <= S_INT_SYNC_ASSERT;
            end else if (inst_mret_i) begin
                int_state <= S_INT_MRET;
            end else begin
                int_state <= S_INT_IDLE;
            end
        end
        
    end

  always @ (posedge clk) begin
        if (!rst_n)  begin
            csr_state <= S_CSR_IDLE;
            cause <= 0;
            inst_addr <= 0;
        end else begin
            case (csr_state)
                S_CSR_IDLE: begin
                    // 同步异常，地址取异常指令地址
                    // 作者偷懒了 在中断和异常的返回没有做区分，因为不存在同步中断
                    // 如果前一条指令是jump，同步指令会被flush，不会引起clint响应
                    if (int_state == S_INT_SYNC_ASSERT) begin
                        csr_state <= S_CSR_MEPC;
                        inst_addr <= inst_addr_i;
                         cause <= inst_ebreak_i? 32'd3:
                                     inst_ecall_i? 32'd11:
                                     memory_access_missalign?32'd4:
                                     32'd10;
                     //异步中断，没有考虑异常
                     //当前id阶段的指令即ex阶段的指令加4
                     //值得注意的是，这一拍是在id阶段打的，不会影响ex阶段现有的指令。
                     //这里是否忘记考虑了ex阶段指令为jump的情况？
                     //下一拍会再次进行中断的jump，所以上一刻的jump无效
                     //但是退出异常之后的指令地址确实应该是jump地址
                     //这里的处理变为，中断以后重新执行ex阶段的指令
                    end else if (int_state == S_INT_ASYNC_ASSERT) begin
                        // 定时器中断
                        cause <= 32'h80000004;
                        csr_state <= S_CSR_MEPC;
                        begin
                            inst_addr <= inst_addr_i;
                        end
                    //异常返回
                    end else if (int_state == S_INT_MRET) begin
                        csr_state <= S_CSR_MSTATUS_MRET;
                    end
                end
                S_CSR_MEPC: begin
                    csr_state <= S_CSR_MCAUSE;
                end
                S_CSR_MCAUSE: begin
                    csr_state <= S_CSR_MSTATUS;
                end
                S_CSR_MSTATUS: begin
                    csr_state <= S_CSR_IDLE;
                end
                S_CSR_MSTATUS_MRET: begin
                    csr_state <= S_CSR_IDLE;
                end
                default: begin
                    csr_state <= S_CSR_IDLE;
                end
            endcase
        end
    end
    
    // 发出中断信号前，先写几个CSR寄存器
    always @ (posedge clk) begin
        if (!rst_n) begin
            we_o <= 1'b0;
            waddr_o <= 0;
            data_o <= 0;
        end else begin
            case (csr_state)
                // 将mepc寄存器的值设为当前指令地址
                S_CSR_MEPC: begin
                    we_o <=  1'b1;
                    waddr_o <= {20'h0, `CSR_MEPC};
                    data_o <= inst_addr;
                end
                // 写中断产生的原因
                S_CSR_MCAUSE: begin
                    we_o <=  1'b1;
                    waddr_o <= {20'h0, `CSR_MCAUSE};
                    data_o <= cause;
                end
                // 关闭全局中断
                S_CSR_MSTATUS: begin
                    we_o <=   1'b1;
                    waddr_o <= {20'h0, `CSR_MSTATUS};
                    data_o <= {csr_mstatus[31:8],csr_mstatus[3],csr_mstatus[6:4], 1'b0, csr_mstatus[2:0]};
//                    data_o <= {csr_mstatus[31:4], 1'b0, csr_mstatus[2:0]};
                end
                // 中断返回
                S_CSR_MSTATUS_MRET: begin
                    we_o <=   1'b1;
                    waddr_o <= {20'h0, `CSR_MSTATUS};
                    data_o <= {csr_mstatus[31:4], csr_mstatus[7], csr_mstatus[2:0]};
                end
                default: begin
                    we_o <=   1'b0;
                    waddr_o <= 0;
                    data_o <= 0;
                end
            endcase
        end
    end
    
        // 发出中断信号给ex模块
    always @ (posedge clk) begin
        if (!rst_n) begin
            int_assert_o <=  0;
            int_addr_o <= 0;
        end else begin
            case (csr_state)
                // 发出中断进入信号.写完mcause寄存器才能发
                // 改成写完status再跳转
                S_CSR_MSTATUS: begin
//                S_CSR_MCAUSE: begin
                    int_assert_o <= 1;
                    int_addr_o <= csr_mtvec;
                end
                // 发出中断返回信号
                S_CSR_MSTATUS_MRET: begin
                    int_assert_o <= 1;
                    int_addr_o <= csr_mepc;
                end
                default: begin
                    int_assert_o <= 0;
                    int_addr_o <= 0;
                end
            endcase
        end
    end
    
endmodule