`include "include.v"


// core local interruptor module
// 核心中断管理、仲裁模块
module clint(

    input wire clk,
    input wire rst_n,

    // from core
    input wire[`INT_BUS] int_flag_i,         // 中断输入信号

    // from id
    input wire[`InstBus]     inst_i,          // 指令内容
    // 异常指令的地址 
    input wire[`InstAddrBus] inst_addr_i,    // 指令地址

    // from ex
    input wire jump_flag_i,
    input wire[`InstAddrBus] jump_addr_i,
//    input wire div_started_i,

    // from ctrl
    input wire[`Hold_Flag_Bus] hold_flag_i,  // 流水线暂停标志

    // from csr_reg
    input wire[`DATA_WIDTH - 1:0] data_i,              // CSR寄存器输入数据
    input wire[`DATA_WIDTH - 1:0] csr_mtvec,           // mtvec寄存器
    input wire[`DATA_WIDTH - 1:0] csr_mepc,            // mepc寄存器
    input wire[`DATA_WIDTH - 1:0] csr_mstatus,         // mstatus寄存器

    input wire global_int_en_i,              // 全局中断使能标志

    // to ctrl
    output wire hold_flag_o,                 // 流水线暂停标志

    // to csr_reg
    output reg we_o,                                // 写CSR寄存器标志
    output reg[`BUS_WIDTH - 1 : 0] waddr_o,         // 写CSR寄存器地址
    output reg[`BUS_WIDTH - 1 : 0] raddr_o,         // 读CSR寄存器地址
    output reg[`DATA_WIDTH - 1 : 0] data_o,         // 写CSR寄存器数据

    // to ex
    output reg[`DATA_WIDTH - 1:0] int_addr_o,     // 中断入口地址
    output reg int_assert_o                      // 中断标志

    );

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


    assign hold_flag_o = ((int_state != S_INT_IDLE) | (csr_state != S_CSR_IDLE))? 1'b1: 1'b0;


    // 中断仲裁逻辑
    always @ (*) begin
        if (~rst_n) begin
            int_state = S_INT_IDLE;
        end else begin
            //暂时不支持ecall ebreak
            if (inst_i == `INST_ECALL || inst_i == `INST_EBREAK) begin
                // 如果执行阶段的指令为除法指令，则先不处理同步中断，等除法指令执行完再处理
                int_state = S_INT_IDLE;
            end else if (int_flag_i != `INT_NONE && global_int_en_i == `True) begin
                int_state = S_INT_ASYNC_ASSERT;
            end else if (inst_i == `INST_MRET) begin
                int_state = S_INT_MRET;
            end else begin
                int_state = S_INT_IDLE;
            end
        end
    end

    // 写CSR寄存器状态切换
    always @ (posedge clk) begin
        if (~rst_n)  begin
            csr_state <= S_CSR_IDLE;
            cause <= 0;
            inst_addr <= 0;
        end else begin
            case (csr_state)
                //进入中断状态 记录中断原因
                //tips 其实全部都是同步中断 
                //异步中断是对于非单周期指令而言的
                S_CSR_IDLE: begin
                    // 同步中断
                    if (int_state == S_INT_SYNC_ASSERT) begin
                        csr_state <= S_CSR_MEPC;
                        // 在中断处理函数里会将中断返回地址加4
                        if (jump_flag_i) begin
                            inst_addr <= jump_addr_i - 4'h4;
                        end else begin
                            inst_addr <= inst_addr_i;
                        end
                        case (inst_i)
                            `INST_ECALL: begin
                                cause <= 32'd11;
                            end
                            `INST_EBREAK: begin
                                cause <= 32'd3;
                            end
                            default: begin
                                cause <= 32'd10;
                            end
                        endcase
                    // 异步中断
                    end else if (int_state == S_INT_ASYNC_ASSERT) begin
                        // 定时器中断
                        cause <= 32'h80000004;
                        csr_state <= S_CSR_MEPC;
                        if (jump_flag_i) begin
                            inst_addr <= jump_addr_i;
                        // 异步中断可以中断除法指令的执行，中断处理完再重新执行除法指令
                        end  
                        else begin
                            inst_addr <= inst_addr_i;
                        end
                    // 中断返回
                    end else if (int_state == S_INT_MRET) begin
                        csr_state <= S_CSR_MSTATUS_MRET;
                    end
                end
                //记录异常地址 用于返回
                S_CSR_MEPC: begin
                    csr_state <= S_CSR_MSTATUS;
                end
                //记录异常状态 省略了记录非法地址和指令的步骤
                S_CSR_MSTATUS: begin
                    csr_state <= S_CSR_MCAUSE;
                end
                //写入中断原因 等待中断返回
                S_CSR_MCAUSE: begin
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
        if (~rst_n) begin
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
                    data_o <= {csr_mstatus[31:4], 1'b0, csr_mstatus[2:0]};
                end
                // 中断返回
                S_CSR_MSTATUS_MRET: begin
                    we_o <=   1'b1;
                    waddr_o <= {20'h0, `CSR_MSTATUS};
                    data_o <= {csr_mstatus[31:4], csr_mstatus[7], csr_mstatus[2:0]};
                end
                default: begin
                    we_o <=   1'b1;
                    waddr_o <= 0;
                    data_o <= 0;
                end
            endcase
        end
    end

    // 发出中断信号给ex模块
    always @ (posedge clk) begin
        if (~rst_n) begin
            int_assert_o <= 1'b0;
            int_addr_o <= 0;
        end else begin
            //其实这种写法有延迟，但是也没有关系，可以flush多取的指令
            case (csr_state)
                // 发出中断进入信号.写完mcause寄存器才能发
                S_CSR_MCAUSE: begin
                    int_assert_o <= 1'b1;
                    int_addr_o <= csr_mtvec;
                end
                // 发出中断返回信号
                S_CSR_MSTATUS_MRET: begin
                    int_assert_o <= 1'b1;
                    int_addr_o <= csr_mepc;
                end
                default: begin
                    int_assert_o <= 1'b0;
                    int_addr_o <= 0;
                end
            endcase
        end
    end

endmodule