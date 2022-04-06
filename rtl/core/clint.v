`include "include.v"


// core local interruptor module
// �����жϹ����ٲ�ģ��
module clint(

    input wire clk,
    input wire rst_n,
    
    // from core
    input wire[`INT_BUS] int_flag_i,         // �ж������ź�

    // from exu
    input wire inst_ecall_i,                    // ecallָ��
    input wire inst_ebreak_i,                   // ebreakָ��
    input wire inst_mret_i,                     // mretָ��
    input wire memory_access_missalign,
    input wire [`BUS_WIDTH - 1:0] inst_addr_i,     // ָ���ַ
//    input wire jump_flag_i,
    
    // from csr_reg
    input wire[`DATA_WIDTH - 1:0] csr_mtvec,           // mtvec�Ĵ���
    input wire[`DATA_WIDTH - 1:0] csr_mepc,            // mepc�Ĵ���
    input wire[`DATA_WIDTH - 1:0] csr_mstatus,         // mstatus�Ĵ���

    // to csr_reg
    output reg we_o,                         // дCSR�Ĵ�����־
    output reg [`BUS_WIDTH - 1:0] waddr_o,         // дCSR�Ĵ�����ַ
    output reg [`DATA_WIDTH - 1:0] data_o,              // дCSR�Ĵ�������

    // to ex
    output wire stall_flag_o,                 // ��ˮ����ͣ��־
    output reg [`BUS_WIDTH - 1:0] int_addr_o,     // �ж���ڵ�ַ
    output reg int_assert_o                  // �жϱ�־
  );

    
    wire global_int_en;
    assign  global_int_en = csr_mstatus[3];
    // �ж�״̬����
    localparam S_INT_IDLE            = 4'b0001;
    localparam S_INT_SYNC_ASSERT     = 4'b0010;
    localparam S_INT_ASYNC_ASSERT    = 4'b0100;
    localparam S_INT_MRET            = 4'b1000;

    // дCSR�Ĵ���״̬����
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

//    wire ex_pipe_ok;
    
    assign stall_flag_o = ((int_state != S_INT_IDLE) | (csr_state != S_CSR_IDLE))? 1'b1: 1'b0;
    
    // �ж��ٲ��߼�
    always @ (*) begin
        if (!rst_n) begin
            int_state <= S_INT_IDLE;
        end 
        else if ((int_flag_i != `INT_NONE) && (global_int_en )) begin
                int_state <= S_INT_ASYNC_ASSERT;
        end
        else begin
            if (inst_ecall_i || inst_ebreak_i || memory_access_missalign) begin
                // ���ִ�н׶ε�ָ��Ϊ����ָ����Ȳ�����ͬ���жϣ��ȳ���ָ��ִ�����ٴ���
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
                    // ͬ���쳣����ַȡ�쳣ָ���ַ
                    // ����͵���� ���жϺ��쳣�ķ���û�������֣���Ϊ������ͬ���ж�
                    // ���ǰһ��ָ����jump��ͬ��ָ��ᱻflush����������clint��Ӧ
                    if (int_state == S_INT_SYNC_ASSERT) begin
                        csr_state <= S_CSR_MEPC;
                        inst_addr <= inst_addr_i;
                         cause <= inst_ebreak_i? 32'd3:
                                     inst_ecall_i? 32'd11:
                                     memory_access_missalign?32'd4:
                                     32'd10;
                     //�첽�жϣ�û�п����쳣
                     //��ǰid�׶ε�ָ�ex�׶ε�ָ���4
                     //ֵ��ע����ǣ���һ������id�׶δ�ģ�����Ӱ��ex�׶����е�ָ�
                     //�����Ƿ����ǿ�����ex�׶�ָ��Ϊjump�������
                     //��һ�Ļ��ٴν����жϵ�jump��������һ�̵�jump��Ч
                     //�����˳��쳣֮���ָ���ַȷʵӦ����jump��ַ
                     //����Ĵ����Ϊ���ж��Ժ�����ִ��ex�׶ε�ָ��
                    end else if (int_state == S_INT_ASYNC_ASSERT) begin
                        // ��ʱ���ж�
                        cause <= 32'h80000004;
                        csr_state <= S_CSR_MEPC;
                        begin
                            inst_addr <= inst_addr_i;
                        end
                    //�쳣����
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
    
    // �����ж��ź�ǰ����д����CSR�Ĵ���
    always @ (posedge clk) begin
        if (!rst_n) begin
            we_o <= 1'b0;
            waddr_o <= 0;
            data_o <= 0;
        end else begin
            case (csr_state)
                // ��mepc�Ĵ�����ֵ��Ϊ��ǰָ���ַ
                S_CSR_MEPC: begin
                    we_o <=  1'b1;
                    waddr_o <= {20'h0, `CSR_MEPC};
                    data_o <= inst_addr;
                end
                // д�жϲ�����ԭ��
                S_CSR_MCAUSE: begin
                    we_o <=  1'b1;
                    waddr_o <= {20'h0, `CSR_MCAUSE};
                    data_o <= cause;
                end
                // �ر�ȫ���ж�
                S_CSR_MSTATUS: begin
                    we_o <=   1'b1;
                    waddr_o <= {20'h0, `CSR_MSTATUS};
                    data_o <= {csr_mstatus[31:8],csr_mstatus[3],csr_mstatus[6:4], 1'b0, csr_mstatus[2:0]};
//                    data_o <= {csr_mstatus[31:4], 1'b0, csr_mstatus[2:0]};
                end
                // �жϷ���
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
    
        // �����ж��źŸ�exģ��
    always @ (posedge clk) begin
        if (!rst_n) begin
            int_assert_o <=  0;
            int_addr_o <= 0;
        end else begin
            case (csr_state)
                // �����жϽ����ź�.д��mcause�Ĵ������ܷ�
                // �ĳ�д��status����ת
                S_CSR_MSTATUS: begin
//                S_CSR_MCAUSE: begin
                    int_assert_o <= 1;
                    int_addr_o <= csr_mtvec;
                end
                // �����жϷ����ź�
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