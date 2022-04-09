`include "include.v"

module prefetch(
    input   clk,
    input   rst_n,
    input   [`BUS_WIDTH - 1:0]jump_addr,
    input   jump,
    input   fence_flush,
    input   jtag_halt_flag_i,
    input   clint_hold_flag,
    input   mem_addr_ok,
    input   pre_taken_i,
    input   [`BUS_WIDTH - 1:0] pre_taken_target_i,
    input   [`BUS_WIDTH - 1:0] pc_if,
    output  rom_req,
    output  reg [`BUS_WIDTH - 1:0] pc_pre,
    output  reg [`BUS_WIDTH - 1:0] pc_bp,
    output  reg [`BUS_WIDTH - 1:0] rom_address,
//    output  reg bp_taken_reg,
    input   early_bp_wrong_if,
    //not used
    input   allow_in_if,
    output  ready_go_pre,
    output  valid_pre
);

    reg [`BUS_WIDTH - 1:0]  next_pc;
    wire update_pc;
    wire req_handshake;
    wire [2:0]pc_control;
    wire [`BUS_WIDTH - 1:0] pc_add;
    wire [`BUS_WIDTH - 1:0] pc_add_bp_recover;
    
//    wire bp_taken;
//    wire [`BUS_WIDTH - 1:0] bp_taken_target;
    
    assign req_handshake = rom_req && mem_addr_ok;
    assign update_pc = req_handshake || jump || early_bp_wrong_if;
    assign pc_control = {early_bp_wrong_if, jump, pre_taken_i};
    assign pc_add = pc_pre  + {`BUS_WIDTH'd4};
    assign pc_add_bp_recover = pc_if + {`BUS_WIDTH'd4};
//    assign bp_taken = 1'b0;
//    assign bp_taken_target = jump_addr;
    
    /// branch cal is not compeleted, so and (~hold)
    assign ready_go_pre = rom_req && mem_addr_ok;
    //if no ready go, next stage set this to zero
    assign valid_pre = mem_addr_ok;
    
    always@(*)begin
        case(pc_control)
            //unbranch
            3'b100:begin
                next_pc <= pc_add_bp_recover;
            end
            //unbranch
            3'b101:begin
                next_pc <= pc_add_bp_recover;
            end
            //jump
            3'b110:begin
                next_pc <= jump_addr;
            end
            //jump
            3'b111:begin
                next_pc <= jump_addr;
            end
            3'b000:begin
                next_pc <= pc_add;
            end
            3'b001:begin
                next_pc <= pre_taken_target_i;
            end
            3'b010:begin
                next_pc <= jump_addr;
            end
            3'b011:begin
                next_pc <= jump_addr;
            end
            default:begin
                next_pc <= pc_add;
            end
        endcase
    end
    
    always@(posedge clk)begin
        if( !rst_n )begin
            pc_pre  <= 0;
            pc_bp   <= 0;
            rom_address <= 0;
//            bp_taken_reg <= 0;
        end
        else if(update_pc)begin
            pc_bp   <= next_pc;
            pc_pre  <= next_pc;
            rom_address <= next_pc;
//            bp_taken_reg <= pre_taken_i;
        end
//        else if(jump || early_bp_wrong_if)begin
//            pc_pre  <= next_pc;
//            bp_taken_reg <= 1'b0;
//        end
//        else if(req_handshake)begin
//            pc_pre  <= next_pc;
//            bp_taken_reg <= pre_taken_target_i;
//        end
    end
    
   assign rom_req = allow_in_if && !(fence_flush || jtag_halt_flag_i || clint_hold_flag || early_bp_wrong_if);
    

endmodule
