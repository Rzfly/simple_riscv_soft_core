    
//    control_gen control_gen_inst(
//        .fence_flush(fence_flush),
//        .hazared_stall_pipe(stall_pipe),
//        .mem_hold(mem_hold),
//        .clint_hold_flag(clint_hold_flag),
//        .jtag_halt_flag(jtag_halt_flag_i),
//        .jump(pc_jump),
//        .cancel_pc(cancel_pc),
//        .cancel_if(flush_if),
//        .hold_if(hold_if),
//        .cancel_id(flush_id),
//        .hold_id(hold_id),
//        .cancel_ex(flush_ex),
//        .hold_ex(hold_ex)
//    );
module control_gen(
    input fence_flush,
    input hazared_stall_pipe,
    input mem_hold,
    input clint_hold_flag,
    input jtag_halt_flag,
    input jump,
    output reg cancel_pc,
    output reg cancel_if,
    output reg hold_if,
    output reg cancel_id,
    output reg hold_id,
    output reg cancel_ex,
    output reg hold_ex
);

    wire [5:0]pipe_control_signal;
    // external > excution > before excution
    // clint jump >  excution
    // fence = jump, will not occur at the same time
    // ecall no hazard
    // external int, also no hazard
    // flush ,next input ins becomes nop, next output becomes nop
    // cancel cancel instuctions now,next output becomes nop and receive new instruction
    // flush is type of cancel
    assign pipe_control_signal = {jtag_halt_flag, mem_hold, clint_hold_flag, fence_flush, jump, hazared_stall_pipe};
    always@(*)begin
        case(pipe_control_signal)
            //jtag
            6'b1xxxxx:begin
                cancel_pc <= 1'b0;
                cancel_if <= 1'b0; 
                hold_if <= 1'b1; 
                cancel_id <= 1'b0; 
                hold_id <= 1'b1; 
                cancel_ex <= 1'b0; 
                hold_ex <= 1'b1; 
            end
            //mem_hold
            6'bx1xxxx:begin
                cancel_pc <= 1'b0;
                cancel_if <= 1'b0; 
                hold_if <= 1'b1; 
                cancel_id <= 1'b0; 
                hold_id <= 1'b0; 
                cancel_ex <= 1'b0; 
                hold_ex <= 1'b0; 
            end
            //ecall and exteral int
            //clint hold, then jump
            6'bxx1xxx:begin
                cancel_pc <= 1'b0;
                cancel_if <= 1'b0; 
                hold_if <= 1'b1; 
                cancel_id <= 1'b0; 
                hold_id <= 1'b1; 
                //if ecall,start when id,reach when ex, already excuting
                //if external int, now ex pc already excuting, next ex becomes nop
                cancel_ex <= 1'b0; 
                //wait until epc saved
                hold_ex <= 1'b1; 
            end
            //fence_flush
            //hold ,then jump
            6'bxxx1xx:begin 
                //not req
                cancel_pc <= 1'b1;
                //cancel wait
                cancel_if <= 1'b1; 
                hold_if <= 1'b0; 
                cancel_id <= 1'b1; 
                hold_id <= 1'b0; 
                //fence should wait unitl wb complete
                cancel_ex <= 1'b0; 
                //fence will hold unitl wb complete
                hold_ex <= 1'b0; 
            end
            //jump
            6'bxxxx1x:begin
                //req
                cancel_pc <= 1'b0;
                //cancel wait
                cancel_if <= 1'b1; 
                hold_if <= 1'b0; 
                cancel_id <= 1'b1; 
                hold_id <= 1'b0; 
                cancel_ex <= 1'b0; 
                hold_ex <= 1'b0; 
            end
            //hazared_stall_pipe
            6'bxxxxx1:begin
                //req
                cancel_pc <= 1'b0;
                cancel_if <= 1'b0; 
                hold_if <= 1'b1; 
                cancel_id <= 1'b0; 
                hold_id <= 1'b1; 
                cancel_ex <= 1'b0; 
                hold_ex <= 1'b0; 
            end
            default:begin
                //req
                cancel_pc <= 1'b0;
                cancel_if <= 1'b0; 
                hold_if <= 1'b0; 
                cancel_id <= 1'b0; 
                hold_id <= 1'b0; 
                cancel_ex <= 1'b0; 
                hold_ex <= 1'b0; 
            end
        endcase
    end
endmodule