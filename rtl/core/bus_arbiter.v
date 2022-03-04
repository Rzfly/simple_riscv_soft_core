

module bus_arbiter(

    input wire clk,
    input wire rst_n,
    //master 0
    // master 0 interface
    //mem req
    input wire[`BUS_WIDTH - 1:0] m0_addr_i,
    input wire[`DATA_WIDTH - 1:0] m0_data_i,
    output [`DATA_WIDTH - 1:0] m0_data_o,
    //not used, always granted
    input wire m0_req_i,
    input wire m0_we_i,
    input [`RAM_MASK_WIDTH - 1:0]m0_wem,
    output m0_addr_ok,
    output m0_data_ok,
    
    input wire[`BUS_WIDTH - 1:0] m1_addr_i,
    input wire[`DATA_WIDTH - 1:0] m1_data_i,
    output [`DATA_WIDTH - 1:0] m1_data_o,
    //not used, always granted
    input wire m1_req_i,
    input wire m1_we_i,
    input [`RAM_MASK_WIDTH - 1:0]m1_wem,
    output m1_addr_ok,
    output m1_data_ok,
    
    input wire[`BUS_WIDTH - 1:0] m2_addr_i,
    input wire[`DATA_WIDTH - 1:0] m2_data_i,
    output [`DATA_WIDTH - 1:0] m2_data_o,
    //not used, always granted
    input wire m2_req_i,
    input wire m2_we_i,
    input [`RAM_MASK_WIDTH - 1:0]m2_wem,
    output m2_addr_ok,
    output m2_data_ok,

    // slave 0 mem
    (* mark_debug="true" *)output [`BUS_WIDTH - 1:0] s0_addr_o,
    (* mark_debug="true" *)output [`DATA_WIDTH - 1:0] s0_data_o,
    (* mark_debug="true" *)input wire[`DATA_WIDTH - 1:0] s0_data_i,
    (* mark_debug="true" *)output s0_req_o,
    (* mark_debug="true" *)output s0_we_o,
    (* mark_debug="true" *)output [`RAM_MASK_WIDTH - 1:0]s0_wem,
    (* mark_debug="true" *)input  s0_addr_ok,
    (* mark_debug="true" *)input  s0_data_ok,
    
    // slave 2 timer
    output [`BUS_WIDTH - 1:0] s2_addr_o,
    output [`DATA_WIDTH - 1:0] s2_data_o,
    input wire[`DATA_WIDTH - 1:0] s2_data_i,
    output  s2_req_o,
    output  s2_we_o,
    output [`RAM_MASK_WIDTH - 1:0]s2_wem,
    input s2_addr_ok,
    input s2_data_ok,
    
    // slave 4 interface / gpio
    output [`BUS_WIDTH - 1:0] s4_addr_o,
    output [`DATA_WIDTH - 1:0] s4_data_o,
    input wire[`DATA_WIDTH - 1:0]s4_data_i,
    output  s4_req_o,
    output  s4_we_o,
    output [`RAM_MASK_WIDTH - 1:0]s4_wem,
    input  s4_addr_ok,
    input  s4_data_ok,

    output hold_flag_o
);

    parameter [3:0]slave_0 = 4'b0000;
    parameter [3:0]slave_1 = 4'b0001;
    parameter [3:0]slave_2 = 4'b0010;
    parameter [3:0]slave_4 = 4'b0100;

    parameter slave_state_idle = 4'b0001;
    parameter slave_state_mem = 4'b0010;
    parameter slave_state_timer = 4'b0100;
    parameter slave_state_gpio = 4'b1000;
    
    parameter master_state_idle = 4'b0001;
    parameter master_state_rom  = 4'b0010;
    parameter master_state_ram  = 4'b0100;
    parameter master_state_jtag = 4'b1000;
    (* mark_debug="true" *)reg [3:0] master_state;
    (* mark_debug="true" *)reg [3:0] next_master_state;
    
    wire master_req_i_pass;

    
//    wire  master_addr_ok;
    wire  slave_addr_ok;
    wire  master_data_ok;
    wire [`DATA_WIDTH - 1:0] master_data_o;
    wire [`DATA_WIDTH - 1:0] master_data_i;
    wire [`BUS_WIDTH - 1:0] master_addr_i;
    wire  master_we;
    wire  master_req;
    wire [`RAM_MASK_WIDTH - 1:0]master_wem;

    reg [2:0]grant;
    wire [2:0]master_req_table;
    assign master_req_table = {m2_req_i,m1_req_i,m0_req_i};
    always@(*)begin
        case(master_req_table)
            3'b111:begin
                grant <= 3'b100;
            end
            3'b110:begin
                grant <= 3'b100;
            end
            3'b101:begin
                grant <= 3'b100;
            end
            3'b100:begin
                grant <= 3'b100;
            end
            3'b011:begin
                grant <= 3'b010;
            end
            3'b010:begin
                grant <= 3'b010;
            end
            3'b001:begin
                grant <= 3'b001;
            end
            default:begin
                grant <= 3'b000;
            end
        endcase
    end
    
    assign hold_flag_o = 1'b0;
    //not used, always granted

    assign m0_addr_ok = (grant[0])?slave_addr_ok:1'b0;
    assign m1_addr_ok = (grant[1])?slave_addr_ok:1'b0;
    assign m2_addr_ok = (grant[2])?slave_addr_ok:1'b0;
    assign master_addr_i = {`BUS_WIDTH{grant[2]}} & m2_addr_i | {`BUS_WIDTH{grant[1]}} & m1_addr_i | {`BUS_WIDTH{grant[0]}} & m0_addr_i;
    assign master_data_i = {`BUS_WIDTH{grant[2]}} & m2_data_i | {`BUS_WIDTH{grant[1]}} & m1_data_i | {`BUS_WIDTH{grant[0]}} & m0_data_i;
    assign master_we    = {{grant[2]}} & m2_we_i || {grant[1]} & m1_we_i || {grant[0]} & m0_we_i;
    assign master_req    = {{grant[2]}} & m2_req_i || {grant[1]} & m1_req_i || {grant[0]} & m0_req_i;
    assign master_data_i = {`BUS_WIDTH{grant[2]}} & m2_data_i | {`BUS_WIDTH{grant[1]}} & m1_data_i | {`BUS_WIDTH{grant[0]}} & m0_data_i;
    assign master_wem   = {`RAM_MASK_WIDTH{grant[2]}} & m2_wem | {`RAM_MASK_WIDTH{grant[1]}} & m1_wem | {`RAM_MASK_WIDTH{grant[0]}} & m0_wem;
    
    
    assign  m0_data_ok = (master_state[1])?master_data_ok:1'b0;
    assign  m1_data_ok = (master_state[2])?master_data_ok:1'b0;
    assign  m2_data_ok = (master_state[3])?master_data_ok:1'b0;
    
    assign  m0_data_o = (master_state[1])?master_data_o:0;
    assign  m1_data_o = (master_state[2])?master_data_o:0;
    assign  m2_data_o = (master_state[3])?master_data_o:0;
    
    always@(posedge clk )
    begin
        if ( !rst_n )
        begin;
            master_state <= master_state_idle;
        end
        else begin
            master_state <= next_master_state;
        end
    end

    
    always@(*)begin
        case(master_state)
            //waiting for req
            master_state_idle:begin
                if( slave_addr_ok && m2_req_i)begin
                    next_master_state <= master_state_jtag;
                end
                else if( slave_addr_ok && m1_req_i )begin
                    next_master_state <= master_state_ram;
                end
                else if( slave_addr_ok && m0_req_i )begin
                    next_master_state <= master_state_rom;
                end
                else begin
                    next_master_state <= master_state_idle;
                end
            end
            //waiting mem data ok
            master_state_rom:begin
                if( master_data_ok && slave_addr_ok && m2_req_i)begin
                    next_master_state <= master_state_jtag;
                end
                else if(master_data_ok && slave_addr_ok && m1_req_i )begin
                    next_master_state <= master_state_ram;
                end
                else if(master_data_ok && slave_addr_ok && m0_req_i )begin
                    next_master_state <= master_state_rom;
                end
                else if(master_data_ok)begin
                    next_master_state <= master_state_idle;
                end
                else begin
                    next_master_state <= master_state_rom;
                end
            end    
            master_state_ram:begin
                if( master_data_ok && slave_addr_ok && m2_req_i)begin
                    next_master_state <= master_state_jtag;
                end
                else if(master_data_ok && slave_addr_ok && m1_req_i )begin
                    next_master_state <= master_state_ram;
                end
                else if(master_data_ok && slave_addr_ok && m0_req_i )begin
                    next_master_state <= master_state_rom;
                end
                else if(master_data_ok)begin
                    next_master_state <= master_state_idle;
                end
                else begin
                    next_master_state <= master_state_ram;
                end
            end    
            master_state_jtag:begin
                if( master_data_ok && slave_addr_ok && m2_req_i)begin
                    next_master_state <= master_state_jtag;
                end
                else if(master_data_ok && slave_addr_ok && m1_req_i )begin
                    next_master_state <= master_state_ram;
                end
                else if( master_data_ok && slave_addr_ok && m0_req_i )begin
                    next_master_state <= master_state_rom;
                end
                else if(master_data_ok)begin
                    next_master_state <= master_state_idle;
                end
                else begin
                    next_master_state <= master_state_jtag;
                end
            end
            default:begin
                    next_master_state <= master_state_idle;
            end
        endcase
    end
    
    (* mark_debug="true" *)reg [3:0] slave_state;
    (* mark_debug="true" *)reg [3:0] next_slave_state;

    assign master_req_i_pass = (slave_state[0] || master_data_ok) && ( master_req );
    wire slave_mem = ((master_addr_i[31:28] == slave_0) || (master_addr_i[31:28] == slave_1))?1'b1:1'b0;
    wire slave_timer = ((master_addr_i[31:28] == slave_2) )?1'b1:1'b0;
    wire slave_gpio= ((master_addr_i[31:28] == slave_4))?1'b1:1'b0;
    
    
    assign slave_addr_ok = (s0_req_o & s0_addr_ok) | (s2_req_o & s2_addr_ok)|(s4_req_o & s4_addr_ok);
    assign master_data_ok = {{slave_state[1]}} & s0_data_ok | {{slave_state[2]}} & s2_data_ok | {{slave_state[3]}} & s4_data_ok;
    assign master_data_o = {32{slave_state[1]}} & s0_data_i | {32{slave_state[2]}} & s2_data_i | {32{slave_state[3]}} & s4_data_i;
    
    
    assign s0_addr_o = (slave_mem)? {{4'h0}, {master_addr_i[27:0]}}:'d0; 
    assign s2_addr_o = (slave_timer)? {{4'h0}, {master_addr_i[27:0]}}:'d0; 
    assign s4_addr_o = (slave_gpio)? {{4'h0}, {master_addr_i[27:0]}}:'d0;  
    assign s0_data_o = (slave_mem)? master_data_i:'d0; 
    assign s2_data_o = (slave_timer)? master_data_i:'d0; 
    assign s4_data_o = (slave_gpio)? master_data_i:'d0;  
    
    
    assign s0_wem = (slave_mem)? master_wem:'d0; 
    assign s2_wem = (slave_timer)? master_wem:'d0; 
    assign s4_wem = (slave_gpio)? master_wem:'d0; 
    
    assign s0_we_o = (slave_mem)? master_we:'d0; 
    assign s2_we_o = (slave_timer)? master_we:'d0; 
    assign s4_we_o = (slave_gpio)? master_we:'d0;  
    
    assign s0_req_o = (slave_mem)? master_req_i_pass:'d0; 
    assign s2_req_o = (slave_timer)? master_req_i_pass:'d0; 
    assign s4_req_o = (slave_gpio)? master_req_i_pass:'d0; 

    always@(posedge clk )
    begin
        if ( ~rst_n )
        begin;
            slave_state <= slave_state_idle;
        end
        else begin
            slave_state <= next_slave_state;
        end
    end

    always@(*)begin
        case(slave_state)
            //waiting for req
            slave_state_idle:begin
                if(s0_req_o && s0_addr_ok && !(s0_data_ok))begin
                    next_slave_state <= slave_state_mem;
                end
                else if( s2_req_o && s2_addr_ok && !(s2_data_ok))begin
                    next_slave_state <= slave_state_timer;
                end
                else if( s4_req_o && s4_addr_ok && !(s4_data_ok))begin
                    next_slave_state <= slave_state_gpio;
                end
                else begin
                    next_slave_state <= slave_state_idle;
                end
            end
            //waiting mem data ok
            slave_state_mem:begin
               if( s0_data_ok && s2_addr_ok && s2_req_o ) begin
                    next_slave_state <= slave_state_timer;
                end
                else if( s0_data_ok && s4_addr_ok && s4_req_o ) begin
                    next_slave_state <= slave_state_gpio;
                end
                else if(s0_data_ok  && (!master_req)) begin
                    next_slave_state <= slave_state_idle;
                end
                else begin
                    next_slave_state <= slave_state_mem;
                end
            end
            slave_state_timer:begin
                if( s2_data_ok && s0_addr_ok && s0_req_o ) begin
                    next_slave_state <= slave_state_mem;
                end
                else if( s2_data_ok && s4_addr_ok && s4_req_o ) begin
                    next_slave_state <= slave_state_gpio;
                end
                else if(s2_data_ok && (!master_req)) begin
                    next_slave_state <= slave_state_idle;
                end
                else begin
                    next_slave_state <= slave_state_timer;
                end
            end
            slave_state_gpio:begin
                if( s4_data_ok && s0_addr_ok && s0_req_o ) begin
                    next_slave_state <= slave_state_mem;
                end
                else if( s4_data_ok && s2_addr_ok && s2_req_o ) begin
                    next_slave_state <= slave_state_timer;
                end
                else if(s4_data_ok && (!master_req)) begin
                    next_slave_state <= slave_state_idle;
                end
                else begin
                    next_slave_state <= slave_state_gpio;
                end
            end
            default:begin
                    next_slave_state <= slave_state_idle;
            end
        endcase
    end
    
endmodule