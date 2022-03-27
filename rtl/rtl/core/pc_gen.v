`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/30 21:18:15
// Design Name: 
// Module Name: pc_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`include "include.v"

//true pre_if
module pc_gen #(
    parameter PC_WIDTH = 31
)(
    input clk,
    input rst_n,
    input [`BUS_WIDTH - 1:0]jump_addr,
    input jump,
    input fence_flush,
    input jtag_halt_flag_i,
    input clint_hold_flag,
    input mem_addr_ok,
    //input mem_ok,
    output reg rom_req,
    input [`BUS_WIDTH - 1:0] pc_if,
    output reg [`BUS_WIDTH - 1:0]  next_pc,
    //not used
    input allow_in_if,
    output ready_go_pre,
//    output jump_fail,
    output valid_pre
    );
//    wire hold_pipe;
//    wire stop_req;
//    assign stop_req = flush || hold || !allow_in_if;
    wire [`BUS_WIDTH - 1:0] pc_add;
    reg [`BUS_WIDTH - 1:0] jump_addr_temp;
    wire cancel_pc;
    assign cancel_pc = fence_flush || jtag_halt_flag_i || clint_hold_flag || !allow_in_if ;
    wire [2:0]pc_control;
    reg save_jump;
    reg save_jump_valid;
    assign pc_control = {cancel_pc, jump, save_jump_valid};
    assign pc_add = pc_if  + {`BUS_WIDTH'd4};
    
    /// branch cal is not compeleted, so and (~hold)
    assign ready_go_pre = rom_req && mem_addr_ok;
    //if no ready go, next stage set this to zero
    assign valid_pre = mem_addr_ok;
//    assign rom_req = !stop_req;
    
    always@(*)begin
        case(pc_control)
            //none
            3'b100:begin
                next_pc <= pc_add;
                rom_req <= 1'b0;
                save_jump <= 1'b0;
            end
            //none
            3'b101:begin
                next_pc <= jump_addr_temp;
                rom_req <= 1'b0;
                save_jump <= 1'b0;
            end
            //save
            3'b110:begin
                next_pc <= jump_addr;
                rom_req <= 1'b0;
                save_jump <= 1'b1;
            end
            3'b111:begin
                next_pc <= jump_addr_temp;
                rom_req <= 1'b0;
                save_jump <= 1'b1;
            end
            3'b000:begin
                next_pc <= pc_add;
                rom_req <= 1'b1;
                save_jump <= 1'b0;
            end
            //use old jump until ok
            3'b001:begin
                next_pc <= jump_addr_temp;
                rom_req <= 1'b1;
                save_jump <= 1'b0;
            end
            //flush old jump addr
            3'b010:begin
                next_pc <= jump_addr;
                rom_req <= 1'b1;
                save_jump <= 1'b0;
            end
            3'b011:begin
                next_pc <= jump_addr;
                rom_req <= 1'b1;
                save_jump <= 1'b0;
            end
            default:begin
                next_pc <= pc_add;
                rom_req <= 1'b1;
                save_jump <= 1'b0;
            end
        endcase
    end
    
    always@(posedge clk)begin
       if ( !rst_n )begin
            jump_addr_temp <= 0; 
            save_jump_valid <= 0;
        end
        else if(save_jump && jump)begin
            jump_addr_temp <= jump_addr;
            save_jump_valid <= 1;
        end
        else if(!save_jump && rom_req && mem_addr_ok )begin
            save_jump_valid <= 0;
        end
        else begin
            jump_addr_temp <= jump_addr_temp;
            save_jump_valid <= save_jump_valid;
        end
    end
    
endmodule
