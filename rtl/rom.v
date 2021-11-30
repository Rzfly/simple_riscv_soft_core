`include "include.v"

module rom #(
    parameter DEPTH = `MEMORY_DEPTH
)(
    input clk,
    input we,
    input rst_n,
    input [`MEMORY_DEPTH - 1:0]addr,
    input [`DATA_WIDTH - 1:0]datai,
    output [`DATA_WIDTH - 1:0]datao
);

    instruction_rom instruction_rom_inst(
        .a(addr),
        .spo(datao)
    );

endmodule