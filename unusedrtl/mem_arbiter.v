
`include "include.v"

module mem_arbiter(
    input clk,
    input rst_n,
//    input bus_hold_i,
//    output mem_hold_o,
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

    

//    localparam grant1 = 1'b1;
//    localparam grant0 = 1'b0;
    
//    reg grant;
    
//    always@(*)begin
//        if(ram_req)begin
//            grant = grant1;
//        end
//        else begin
//            grant = grant0;
//        end
//    end

//    always@(*)begin
//        if(ram_req)begin
//            grant = grant1;
//        end
//        else begin
//            grant = grant0;
//        end
//    end
    
    parameter state_idle= 3'b001;
    parameter state_rom = 3'b010;
    parameter state_ram = 3'b100;
    
    reg [2:0] state;
    reg [2:0] next_state;
    //ram
    reg grant1;
    //rom
    reg grant0;
    always@(posedge clk)
    begin
        if ( ~rst_n )
        begin;
            state <= state_idle;
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
                if( ram_addr_ok && ram_req && !(ram_data_ok))begin
                    next_state <= state_ram;
                end
                else if( rom_addr_ok && rom_req && !(rom_data_ok)) begin
                    next_state <= state_rom;
                end
                else begin
                    next_state <= state_idle;
                end
            end
            state_rom:begin
                //note:mem_data_ok = rom_data_ok
                //mem_addr_ok & ram_req may be write,  maybe read
                if( mem_data_ok && ram_addr_ok && ram_req ) begin
                    next_state <= state_ram;
                end
                else if(mem_data_ok && rom_addr_ok && rom_req ) begin
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
                if( mem_data_ok && ram_addr_ok && ram_req) begin
                    next_state <= state_ram;
                end
                else if(mem_data_ok && rom_addr_ok && rom_req) begin
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
                next_state <= state_idle;
            end
        endcase
    end

    assign ram_addr_ok = (grant1)?mem_addr_ok:1'b0;
    assign rom_addr_ok = (grant0)?mem_addr_ok:1'b0;
    assign mem_address = (ram_req)?ram_address:rom_address;
    assign mem_wdata = (ram_req)?ram_wdata:32'd0;
    assign mem_wmask = (ram_req)?ram_wmask:{`RAM_MASK_WIDTH{1'b0}}; 
    assign mem_we = (ram_req)?ram_we:1'b0;
    wire req_i_pass;
    //start no addr ok
    //end addr ok
    assign req_i_pass = state[0] | mem_data_ok;
    assign mem_req =  req_i_pass && (ram_req || rom_req );
    
//    assign grant1 = ram_req && (state[0]);
//    assign grant0 = rom_req && (state[0]);
    
//     (state[0]) |  
    
    assign ram_data_ok = (state[2])?mem_data_ok:1'b0;
    assign rom_data_ok = (state[1])?mem_data_ok:1'b0;
    //rom
    assign ram_rdata = (state[2])?mem_rdata:32'd0;
    assign rom_rdata = (state[1])?mem_rdata:`INST_NOP;

//    assign  mem_hold_o =  bus_hold_i;

endmodule