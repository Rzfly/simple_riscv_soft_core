
module srambus(
    input clk,
    input rst_n,
    input mem_req,
    input we,
    input [1:0]size,// 0 = 1 bytes, 1 = 2 bytes, 2 = 4 bytes. always set to 2
    input [`BUS_WIDTH - 1:0]addr,
    input [`DATA_WIDTH - 1:0]datai,
    output [`DATA_WIDTH - 1:0]datao,
    input [`RAM_MASK_WIDTH - 1:0]wem,
    output mem_addr_ok,
    output mem_data_ok
);
 
 sirv_sim_ram #(
    .FORCE_X2ZERO(0),
    .DP(`MEMORY_DEPTH),
    .DW(`DATA_WIDTH),
    .MW(`RAM_MASK_WIDTH),
    .AW(`DATA_WIDTH) 
  )sirv_sim_ram_inst(
    .clk (clk ),
    .rst_n (rst_n ),
    .cs  (mem_req),
    .we  (we  ),
    .addr(addr),
    .din (datai ),
    .wem (wem),
    .dout(datao),
    .mem_addr_ok(mem_addr_ok),
    .mem_data_ok(mem_data_ok)
  );
    
endmodule