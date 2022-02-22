

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

    // slave 0 mem
    output [`BUS_WIDTH - 1:0] s0_addr_o,
    output [`DATA_WIDTH - 1:0] s0_data_o,
    input wire[`DATA_WIDTH - 1:0] s0_data_i,
    output s0_req_o,
    output s0_we_o,
    output [`RAM_MASK_WIDTH - 1:0]s0_wem,
    input  s0_addr_ok,
    input  s0_data_ok,
    
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

    
    // 访问地址的最�?4位决定要访问的是哪一个从设备
    // 因此�?多支�?16个从设备
    parameter [3:0]slave_0 = 4'b0000;
    parameter [3:0]slave_1 = 4'b0001;
    parameter [3:0]slave_2 = 4'b0010;
    parameter [3:0]slave_4 = 4'b0100;
    assign hold_flag_o = 1'b0;


//    wire[3:0] req;
//    reg[1:0] grant;
//    assign req = m0_req_i;

    // 根据仲裁结果，�?�择(访问)对应的从设备
//    always @ (*) begin
//        m0_data_o = 32'd0;
//        s0_wem = 0;
//        s2_wem = 0;
//        s4_wem = 0;
//        m0_addr_ok = 0;
//        m0_data_ok = 0;
//        s0_addr_o = 32'd0;
//        s2_addr_o = 32'd0;
//        s4_addr_o = 32'd0;
//        s0_data_o = 32'd0;
//        s2_data_o = 32'd0;
//        s4_data_o = 32'd0;
//        s0_we_o =  1'b0;
//        s2_we_o =  1'b0;
//        s4_we_o =  1'b0;
//        s0_req_o = 1'b0;
//        s2_req_o = 1'b0;
//        s4_req_o = 1'b0;
        
//        case (m0_addr_i[31:28])
//            slave_0: begin
//                s0_we_o = m0_we_i;
//                s0_addr_o = {{4'h0}, {m0_addr_i[27:0]}};
//                s0_data_o = m0_data_i;
//                m0_data_o = s0_data_i;
//                s0_wem = m0_wem;
//                m0_addr_ok = s0_addr_ok;
//                m0_data_ok = s0_data_ok;
//                s0_req_o = m0_req_i;
//            end
//            slave_1: begin
//                s0_we_o = m0_we_i;
//                s0_addr_o = {{4'h0}, {m0_addr_i[27:0]}};
//                s0_data_o = m0_data_i;
//                m0_data_o = s0_data_i;
//                s0_wem = m0_wem;
//                m0_addr_ok = s0_addr_ok;
//                m0_data_ok = s0_data_ok;
//                s0_req_o = m0_req_i;
//            end
//            slave_2: begin
//                s2_we_o = m0_we_i;
//                s2_addr_o = {{4'h0}, {m0_addr_i[27:0]}};
//                s2_data_o = m0_data_i;
//                m0_data_o = s2_data_i;
//                s2_wem = m0_we_i;
//                m0_addr_ok = s2_addr_ok;
//                m0_data_ok = s2_data_ok;
//                s2_req_o = m0_req_i;
//            end
//            slave_4: begin
//                s4_we_o = m0_we_i;
//                s4_addr_o = {{4'h0}, {m0_addr_i[27:0]}};
//                s4_data_o = m0_data_i;
//                m0_data_o = s4_data_i;
//                s4_wem = m0_we_i;
//                m0_addr_ok = s4_addr_ok;
//                m0_data_ok = s4_data_ok;
//                s4_req_o = m0_req_i;
//            end
//            default: begin
//                m0_data_o = 32'd0;
//                s0_wem = 0;
//                s2_wem = 0;
//                s4_wem = 0;
//                m0_addr_ok = 0;
//                m0_data_ok = 0;
//                s0_addr_o = 32'd0;
//                s2_addr_o = 32'd0;
//                s4_addr_o = 32'd0;
//                s0_data_o = 32'd0;
//                s2_data_o = 32'd0;
//                s4_data_o = 32'd0;
//                s0_we_o =  1'b0;
//                s2_we_o =  1'b0;
//                s4_we_o =  1'b0;
//            end
//        endcase
//    end
    
    
        
    parameter state_idle= 4'b0001;
    parameter state_mem = 4'b0010;
    parameter state_timer = 4'b0100;
    parameter state_gpio = 4'b1000;
    
    reg [3:0] state;
    reg [3:0] next_state;
    
    wire slave_mem = ((m0_addr_i[31:28] == slave_0) || (m0_addr_i[31:28] == slave_1))?1'b1:1'b0;
    wire slave_timer = ((m0_addr_i[31:28] == slave_2) )?1'b1:1'b0;
    wire slave_gpio = ((m0_addr_i[31:28] == slave_4))?1'b1:1'b0;
  
    wire m0_req_i_pass;
    assign m0_req_i_pass = state[0] | m0_data_ok;
    
    assign m0_addr_ok = (s0_req_o & s0_addr_ok) | (s2_req_o & s2_addr_ok)|(s4_req_o & s4_addr_ok);
    assign m0_data_ok =  {{state[1]}} & s0_data_ok | {32{state[2]}} & s2_data_ok | {32{state[3]}} & s4_data_ok;
    assign m0_data_o = {32{state[1]}} & s0_data_i | {32{state[2]}} & s2_data_i | {32{state[3]}} & s4_data_i;
    
    assign s0_addr_o = (slave_mem)? {{4'h0}, {m0_addr_i[27:0]}}:'d0; 
    assign s2_addr_o = (slave_timer)? {{4'h0}, {m0_addr_i[27:0]}}:'d0; 
    assign s4_addr_o = (slave_gpio)? {{4'h0}, {m0_addr_i[27:0]}}:'d0;  
    assign s0_data_o = (slave_mem)? m0_data_i:'d0; 
    assign s2_data_o = (slave_timer)? m0_data_i:'d0; 
    assign s4_data_o = (slave_gpio)? m0_data_i:'d0;  
    
    assign s0_wem = (slave_mem)? m0_wem:'d0; 
    assign s2_wem = (slave_timer)? m0_wem:'d0; 
    assign s4_wem = (slave_gpio)? m0_wem:'d0; 
    
    assign s0_we_o = (slave_mem)? m0_we_i:'d0; 
    assign s2_we_o = (slave_timer)? m0_we_i:'d0; 
    assign s4_we_o = (slave_gpio)? m0_we_i:'d0;  
    
    assign s0_req_o = (slave_mem)? m0_req_i_pass:'d0; 
    assign s2_req_o = (slave_timer)? m0_req_i_pass:'d0; 
    assign s4_req_o = (slave_gpio)? m0_req_i_pass:'d0; 
       
// slave 5 interface / spi
//    output reg[`BUS_WIDTH - 1:0] s5_addr_o,
//    output reg[`DATA_WIDTH - 1:0]s5_data_o,
//    input wire[`DATA_WIDTH - 1:0] s5_data_i,
//    output reg s5_we_o,


    always@(posedge clk )
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
        case(state)
            //waiting for req
            state_idle:begin
                if(s0_req_o && s0_addr_ok && !(s0_data_ok))begin
                    next_state <= state_mem;
                end
                else if( s2_req_o && s2_addr_ok && !(s2_data_ok))begin
                    next_state <= state_timer;
                end
                else if( s4_req_o && s4_addr_ok && !(s4_data_ok))begin
                    next_state <= state_gpio;
                end
                else begin
                    next_state <= state_idle;
                end
            end
            //waiting mem data ok
            state_mem:begin
               if( s0_data_ok && s2_addr_ok && s2_req_o ) begin
                    next_state <= state_timer;
                end
                else if( s0_data_ok && s4_addr_ok && s4_req_o ) begin
                    next_state <= state_gpio;
                end
                else if(s0_data_ok  && (!s0_addr_ok)) begin
                    next_state <= state_idle;
                end
                else begin
                    next_state <= state_mem;
                end
            end
            state_timer:begin
                if( s2_data_ok && s0_addr_ok && s0_req_o ) begin
                    next_state <= state_mem;
                end
                else if( s2_data_ok && s4_addr_ok && s4_req_o ) begin
                    next_state <= state_gpio;
                end
                else if(s2_data_ok && (!s2_addr_ok)) begin
                    next_state <= state_idle;
                end
                else begin
                    next_state <= state_timer;
                end
            end
            state_gpio:begin
                if( s4_data_ok && s0_addr_ok && s0_req_o ) begin
                    next_state <= state_mem;
                end
                else if( s4_data_ok && s2_addr_ok && s2_req_o ) begin
                    next_state <= state_timer;
                end
                else if(s4_data_ok && (!s4_addr_ok)) begin
                    next_state <= state_idle;
                end
                else begin
                    next_state <= state_gpio;
                end
            end
            default:begin
                    next_state <= state_idle;
            end
        endcase
    end
    
endmodule