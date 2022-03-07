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
module prefetch (
    input clk,
    input rst_n,
    input [`BUS_WIDTH - 1:0]jump_addr,
    input jump,
    input jtag_halt_flag_i,
    input clint_hold_flag,
    input mem_addr_ok,
    //input mem_ok,
    output reg rom_req,
    output jump_fail,
    input [`BUS_WIDTH - 1:0] pc_if,
    output reg [`BUS_WIDTH - 1:0]  next_pc,
    //not used
    input allow_in_if,
    output ready_go_pre,
    output valid_pre
    );
	
    wire [`BUS_WIDTH - 1:0] pc_add;
    wire cancel_pc;
    assign cancel_pc = jtag_halt_flag_i || clint_hold_flag || !allow_in_if;
    wire [1:0]pc_control;
    assign pc_control = {cancel_pc, jump};
    assign pc_add = pc_if  + {`BUS_WIDTH'd4};
    
    /// branch cal is not compeleted, so and (~hold)
    assign ready_go_pre = rom_req && mem_addr_ok;
    //if no ready go, next stage set this to zero
    assign valid_pre = mem_addr_ok;
//    assign rom_req = !stop_req;
    assign jump_fail = jump && !mem_addr_ok;
	
	always@(*)begin
        case(pc_control)
            //normal
            2'b00:begin
                next_pc <= pc_add;
                rom_req <= 1'b1;
            end
			//jump
            2'b01:begin
                next_pc <= jump_addr;
                rom_req <= 1'b1;
            end
            //none
            2'b10:begin
                next_pc <= pc_add;
                rom_req <= 1'b0;
            end
            //cancel-jump, jump depends on ex
            2'b11:begin
                next_pc <= jump_addr;
                rom_req <= 1'b0;
            end
            default:begin
                next_pc <= pc_add;
                rom_req <= 1'b0;
            end
        endcase
    end
	
endmodule
    
    // // regs 
    // prefetch prefetch_inst(
        // .clk(clk),
        // .rst_n(rst_n),
        // .jump_addr(jump_addr),
        // .jump(pc_jump),
        // .jtag_halt_flag_i(jtag_halt_flag_i),
        // .clint_hold_flag(clint_hold_flag),
        // .mem_addr_ok(rom_addr_ok),
        // .rom_req(rom_req),
        // .jump_fail(jump_fail),
        // .pc_if(pc_if),
        // .next_pc(next_pc),
        // .allow_in_if(allow_in_if),
        // .ready_go_pre(ready_go_pre),
        // .valid_pre(valid_pre)
    // );