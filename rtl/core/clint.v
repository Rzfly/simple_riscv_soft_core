`include "include.v"


// core local interruptor module
// �����жϹ����ٲ�ģ��
module clint(

    input wire clk,
    input wire rst_n,

    // from core
    input wire[`INT_BUS] int_flag_i,         // �ж������ź�

    // from id
    input wire[`InstBus]     inst_i,          // ָ������
    // �쳣ָ��ĵ�ַ 
    input wire[`InstAddrBus] inst_addr_i,    // ָ���ַ

    // from ex
    input wire jump_flag_i,
    input wire[`InstAddrBus] jump_addr_i,
//    input wire div_started_i,

    // from ctrl
    input wire[`Hold_Flag_Bus] hold_flag_i,  // ��ˮ����ͣ��־

    // from csr_reg
    input wire[`DATA_WIDTH - 1:0] data_i,              // CSR�Ĵ�����������
    input wire[`DATA_WIDTH - 1:0] csr_mtvec,           // mtvec�Ĵ���
    input wire[`DATA_WIDTH - 1:0] csr_mepc,            // mepc�Ĵ���
    input wire[`DATA_WIDTH - 1:0] csr_mstatus,         // mstatus�Ĵ���

    input wire global_int_en_i,              // ȫ���ж�ʹ�ܱ�־

    // to ctrl
    output wire hold_flag_o,                 // ��ˮ����ͣ��־

    // to csr_reg
    output reg we_o,                                // дCSR�Ĵ�����־
    output reg[`BUS_WIDTH - 1 : 0] waddr_o,         // дCSR�Ĵ�����ַ
    output reg[`BUS_WIDTH - 1 : 0] raddr_o,         // ��CSR�Ĵ�����ַ
    output reg[`DATA_WIDTH - 1 : 0] data_o,         // дCSR�Ĵ�������

    // to ex
    output reg[`DATA_WIDTH - 1:0] int_addr_o,     // �ж���ڵ�ַ
    output reg int_assert_o                      // �жϱ�־

    );

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


    assign hold_flag_o = ((int_state != S_INT_IDLE) | (csr_state != S_CSR_IDLE))? 1'b1: 1'b0;


    // �ж��ٲ��߼�
    always @ (*) begin
        if (~rst_n) begin
            int_state = S_INT_IDLE;
        end else begin
            //��ʱ��֧��ecall ebreak
            if (inst_i == `INST_ECALL || inst_i == `INST_EBREAK) begin
                // ���ִ�н׶ε�ָ��Ϊ����ָ����Ȳ�����ͬ���жϣ��ȳ���ָ��ִ�����ٴ���
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

    // дCSR�Ĵ���״̬�л�
    always @ (posedge clk) begin
        if (~rst_n)  begin
            csr_state <= S_CSR_IDLE;
            cause <= 0;
            inst_addr <= 0;
        end else begin
            case (csr_state)
                //�����ж�״̬ ��¼�ж�ԭ��
                //tips ��ʵȫ������ͬ���ж� 
                //�첽�ж��Ƕ��ڷǵ�����ָ����Ե�
                S_CSR_IDLE: begin
                    // ͬ���ж�
                    if (int_state == S_INT_SYNC_ASSERT) begin
                        csr_state <= S_CSR_MEPC;
                        // ���жϴ�������Ὣ�жϷ��ص�ַ��4
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
                    // �첽�ж�
                    end else if (int_state == S_INT_ASYNC_ASSERT) begin
                        // ��ʱ���ж�
                        cause <= 32'h80000004;
                        csr_state <= S_CSR_MEPC;
                        if (jump_flag_i) begin
                            inst_addr <= jump_addr_i;
                        // �첽�жϿ����жϳ���ָ���ִ�У��жϴ�����������ִ�г���ָ��
                        end  
                        else begin
                            inst_addr <= inst_addr_i;
                        end
                    // �жϷ���
                    end else if (int_state == S_INT_MRET) begin
                        csr_state <= S_CSR_MSTATUS_MRET;
                    end
                end
                //��¼�쳣��ַ ���ڷ���
                S_CSR_MEPC: begin
                    csr_state <= S_CSR_MSTATUS;
                end
                //��¼�쳣״̬ ʡ���˼�¼�Ƿ���ַ��ָ��Ĳ���
                S_CSR_MSTATUS: begin
                    csr_state <= S_CSR_MCAUSE;
                end
                //д���ж�ԭ�� �ȴ��жϷ���
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

    // �����ж��ź�ǰ����д����CSR�Ĵ���
    always @ (posedge clk) begin
        if (~rst_n) begin
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
                    data_o <= {csr_mstatus[31:4], 1'b0, csr_mstatus[2:0]};
                end
                // �жϷ���
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

    // �����ж��źŸ�exģ��
    always @ (posedge clk) begin
        if (~rst_n) begin
            int_assert_o <= 1'b0;
            int_addr_o <= 0;
        end else begin
            //��ʵ����д�����ӳ٣�����Ҳû�й�ϵ������flush��ȡ��ָ��
            case (csr_state)
                // �����жϽ����ź�.д��mcause�Ĵ������ܷ�
                S_CSR_MCAUSE: begin
                    int_assert_o <= 1'b1;
                    int_addr_o <= csr_mtvec;
                end
                // �����жϷ����ź�
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