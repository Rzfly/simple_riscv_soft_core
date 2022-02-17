
`include "include.v"

module mem_arbiter(
    input clk,
    input rst_n,
    input [`BUS_WIDTH - 1:0] rom_address,
    output [`DATA_WIDTH - 1: 0]  rom_rdata,
    output rom_addr_ok,
    output rom_data_ok,
    input rom_req,
    
    input [`BUS_WIDTH - 1:0]ram_address,
    input [`DATA_WIDTH - 1: 0]ram_wdata,
    input [`RAM_MASK_WIDTH - 1: 0]ram_wmask,
    output [`DATA_WIDTH - 1: 0]    ram_rdata,
    output ram_addr_ok,
    output ram_data_ok,
    input ram_req,
    input ram_we,
    
    output[`BUS_WIDTH - 1:0]     mem_address,
    input [`DATA_WIDTH - 1: 0]    mem_rdata,
    output[`DATA_WIDTH - 1: 0]   mem_wdata,
    output [`RAM_MASK_WIDTH - 1: 0]mem_wmask,
    output mem_req,
    output mem_we,
    input mem_addr_ok,
    input mem_data_ok
);

    parameter state_idle= 2'b00;
    parameter state_rom = 2'b01;
    parameter state_ram = 2'b10;
    
    reg [1:0] state;
    reg [1:0] next_state;
    //ram
    reg grant1;
    //rom
    reg grant0;
    always@(posedge clk or negedge rst_n)
    begin
        if ( ~rst_n )
        begin;
            state <= 2'b00;
        end
        else begin
            state <= next_state;
        end
    end
    always@(*)begin
        if(ram_req)begin
            grant1 = 1'b1;
            grant0 = 1'b0;
        end
        else if(rom_req)begin
            grant1 = 1'b0;
            grant0 = 1'b1;
        end
        else begin
            grant1 = 1'b0;
            grant0 = 1'b0;
        end
    end

    always@(*)begin
        case(state)
            state_idle:begin
                if( mem_addr_ok & ram_req & (~mem_data_ok))begin
                    next_state <= state_ram;
                end
                else if( mem_addr_ok & rom_req & (~mem_data_ok)) begin
                    next_state <= state_rom;
                end
                else begin
                    next_state <= state_idle;
                end
            end
            state_rom:begin
                //note:mem_data_ok = rom_data_ok
                //mem_addr_ok & ram_req may be write,  maybe read
                if( mem_data_ok & mem_addr_ok & ram_req ) begin
                    next_state <= state_ram;
                end
                else if(mem_data_ok & mem_addr_ok & rom_req ) begin
                    next_state <= state_rom;
                end
                else if(mem_data_ok) begin
                    next_state <= state_idle;
                end
                else begin
                    next_state <= state_rom;
                end
            end
            state_ram:begin
                if( mem_data_ok & mem_addr_ok & ram_req) begin
                    next_state <= state_ram;
                end
                else if(mem_data_ok & mem_addr_ok & rom_req) begin
                    next_state <= state_rom;
                end
                else if(mem_data_ok) begin
                    next_state <= state_idle;
                end
                else begin
                    next_state <= state_ram;
                end
            end
            default:begin
                if( mem_addr_ok & ram_req)begin
                    next_state <= state_ram;
                end
                else if( mem_addr_ok & rom_req) begin
                    next_state <= state_rom;
                end
                else begin
                    next_state <= state_idle;
                end
            end
        endcase
    end

    assign ram_addr_ok = (grant1)?mem_addr_ok:1'b0;
    assign rom_addr_ok = (grant0)?mem_addr_ok:1'b0;
    assign mem_address = (ram_req)?ram_address:rom_address;
    assign mem_wdata = (ram_req)?ram_wdata:32'd0;
    assign mem_wmask = (ram_req)?ram_wmask:{`RAM_MASK_WIDTH{1'b0}}; 
    assign mem_we = (ram_req)?ram_we:1'b0;
    assign mem_req = ram_req | rom_req;
    
    assign ram_data_ok = (state[1])?mem_data_ok:1'b0;
    assign rom_data_ok = (state[0])?mem_data_ok:1'b0;
    //rom
    assign ram_rdata = (state[1])?mem_rdata:32'd0;
    assign rom_rdata = (state[0])?mem_rdata:`INST_NOP;
//    wire  [31:0] rom_rdata_switch;
//    assign rom_rdata_switch =  (state[0])?mem_rdata:`INST_NOP;
//    wire  [31:0] ram_rdata_switch;
//    assign ram_rdata_switch =  (state[1])?mem_rdata:32'd0;
//    assign rom_rdata = rom_rdata_switch;
//    assign ram_rdata = ram_rdata_switch;
endmodule