module wallace_tree_full(
    input clk,
    input rst_n,
    input cancel,
    input [16:0]num_in,    
    output [4:0]carry_layer1_o,
    
    input [4:0]carry_layer2_i,
    output [3:0]carry_layer2_o,
    
    input [3:0]carry_layer3_i,
    output [1:0]carry_layer3_o,
    
    input [1:0]carry_layer4_i,
    output [1:0]carry_layer4_o,
    
    input [1:0]carry_layer5_i,
    output carry_layer5_o,
    
    input carry_layer6_i,
    output c_out,
    output s_out
    );
    
    wire [4:0]layer_1_s;
    
    genvar i;
    generate
        for(i = 0; i < 5 ; i = i + 1)
        begin:layer_1
            carry_save_adder #(.DATA_WIDTH(1))
            carry_save_adder_inst_l1(
                .a(num_in[2 + 3*i]),
                .b(num_in[3 + 3*i]),
                .c(num_in[4 + 3*i]),
                .sum(layer_1_s[i]),
                .cout(carry_layer1_o[i])
            );           
        end
    endgenerate
    
    
    wire [11:0]layer_2_i;
    wire [3:0]layer_2_s;
    assign layer_2_i = {layer_1_s, carry_layer2_i, num_in[1],num_in[0]};
    
    
    genvar j;
    generate
        for(j = 0; j < 4 ; j = j + 1)
        begin:layer_2
            carry_save_adder #(.DATA_WIDTH(1))
            carry_save_adder_inst_l2(
                .a(layer_2_i[0 + 3*j]),
                .b(layer_2_i[1 + 3*j]),
                .c(layer_2_i[2 + 3*j]),
                .sum(layer_2_s[j]),
                .cout(carry_layer2_o[j])
            );           
        end
    endgenerate
    
    
    reg [3:0]layer_2_s_d;
    reg [3:0]carry_layer3_i_d;
  
    always@(posedge clk)begin
        if(!rst_n || cancel)begin
            layer_2_s_d <= 'd0;
            carry_layer3_i_d <= 'd0;
        end
        else begin
            layer_2_s_d <= layer_2_s;
            carry_layer3_i_d <= carry_layer3_i;
        end
    end
    
    wire [5:0]layer_3_i;
    wire [1:0]layer_3_s;
    assign layer_3_i = {layer_2_s_d, carry_layer3_i_d[3:2]};
    
    genvar k;
    generate
        for(k = 0; k < 2 ; k = k + 1)
        begin:layer_3
            carry_save_adder #(.DATA_WIDTH(1))
            carry_save_adder_inst_l3(
                .a(layer_3_i[0 + 3*k]),
                .b(layer_3_i[1 + 3*k]),
                .c(layer_3_i[2 + 3*k]),
                .sum(layer_3_s[k]),
                .cout(carry_layer3_o[k])
            );           
        end
    endgenerate
    
    
    wire [5:0]layer_4_i;
    wire [1:0]layer_4_s;
    //2 + 2 + 2
    assign layer_4_i = {layer_3_s, carry_layer4_i,carry_layer3_i_d[1:0]};
    
    
    genvar l;
    generate
        for(l = 0; l < 2 ; l = l + 1)
        begin:layer_4
            carry_save_adder #(.DATA_WIDTH(1))
            carry_save_adder_inst_l4(
                .a(layer_4_i[0 + 3*l]),
                .b(layer_4_i[1 + 3*l]),
                .c(layer_4_i[2 + 3*l]),
                .sum(layer_4_s[l]),
                .cout(carry_layer4_o[l])
            );           
        end
    endgenerate
    
    
    wire [2:0]layer_5_i;
    wire layer_5_s;
    assign layer_5_i = {layer_4_s, carry_layer5_i[1]};
    
    carry_save_adder #(.DATA_WIDTH(1))
    carry_save_adder_inst_l5(
        .a(layer_5_i[0]),
        .b(layer_5_i[1]),
        .c(layer_5_i[2]),
        .sum(layer_5_s),
        .cout(carry_layer5_o)
    );   
    
    wire [2:0]layer_6_i;
    assign layer_6_i = {layer_5_s, carry_layer6_i,carry_layer5_i[0]};
    
    
    carry_save_adder #(.DATA_WIDTH(1))
    carry_save_adder_inst_l6(
        .a(layer_6_i[0]),
        .b(layer_6_i[1]),
        .c(layer_6_i[2]),
        .sum(s_out),
        .cout(c_out)
    );   
    
endmodule
