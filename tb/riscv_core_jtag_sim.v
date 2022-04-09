`timescale 1 ns / 1 ps

`include "include.v"


// select one option only
//`define TEST_PROG  1
//`define TEST_JTAG  1


// testbench module
module axi_riscv_core_jtag_sim();

    reg clk;
    reg rst_n;
    reg uart_tx;

    always #5 clk = ~clk;     // 50MHz
    wire [`DATA_WIDTH - 1: 0] x3;
    wire [`DATA_WIDTH - 1: 0] x26;
    wire [`DATA_WIDTH - 1: 0] x27;

    assign x3 = axi_soc_top_inst.riscv_core_inst.regfile_inst.rf[3];
    assign x26 = axi_soc_top_inst.riscv_core_inst.regfile_inst.rf[26];
    assign x27 = axi_soc_top_inst.riscv_core_inst.regfile_inst.rf[27];

    integer r;

    reg TCK;
    reg TMS;
    reg TDI;
    wire TDO;

    integer i;
    reg[39:0] shift_reg;
    reg in;
    wire[39:0] req_data = axi_soc_top_inst.u_jtag_top.u_jtag_driver.dtm_req_data;
    wire[4:0] ir_reg = axi_soc_top_inst.u_jtag_top.u_jtag_driver.ir_reg;
    wire dtm_req_valid = axi_soc_top_inst.u_jtag_top.u_jtag_driver.dtm_req_valid;
    wire[31:0] dmstatus = axi_soc_top_inst.u_jtag_top.u_jtag_dm.dmstatus;

    initial begin
        clk = 0;
        rst_n = `RstEnable;
        uart_tx = 1;
        TCK = 1;
        TMS = 1;
        TDI = 1;
        #40
        rst_n = `RstDisable;
        #200
        $display("jtag test running...");
        // reset
        for (i = 0; i < 8; i = i + 1) begin
            TMS = 1;
            TCK = 0;
            #100
            TCK = 1;
            #100
            TCK = 0;
        end

        // IR
        shift_reg = 40'b10001;

        // IDLE
        TMS = 0;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // SELECT-DR
        TMS = 1;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // SELECT-IR
        TMS = 1;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // CAPTURE-IR
        TMS = 0;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // SHIFT-IR
        TMS = 0;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // SHIFT-IR & EXIT1-IR
        for (i = 5; i > 0; i = i - 1) begin
            if (shift_reg[0] == 1'b1)
                TDI = 1'b1;
            else
                TDI = 1'b0;

            if (i == 1)
                TMS = 1;

            TCK = 0;
            #100
            in = TDO;
            TCK = 1;
            #100
            TCK = 0;

            shift_reg = {{(35){1'b0}}, in, shift_reg[4:1]};
        end

        // PAUSE-IR
        TMS = 0;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // EXIT2-IR
        TMS = 1;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // UPDATE-IR
        TMS = 1;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // IDLE
        TMS = 0;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // IDLE
        TMS = 0;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // IDLE
        TMS = 0;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // IDLE
        TMS = 0;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // dmi write
        shift_reg = {6'h10, {(32){1'b0}}, 2'b10};

        // SELECT-DR
        TMS = 1;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // CAPTURE-DR
        TMS = 0;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // SHIFT-DR
        TMS = 0;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // SHIFT-DR & EXIT1-DR
        for (i = 40; i > 0; i = i - 1) begin
            if (shift_reg[0] == 1'b1)
                TDI = 1'b1;
            else
                TDI = 1'b0;

            if (i == 1)
                TMS = 1;

            TCK = 0;
            #100
            in = TDO;
            TCK = 1;
            #100
            TCK = 0;

            shift_reg = {in, shift_reg[39:1]};
        end

        // PAUSE-DR
        TMS = 0;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // EXIT2-DR
        TMS = 1;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // UPDATE-DR
        TMS = 1;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // IDLE
        TMS = 0;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        $display("ir_reg = 0x%x", ir_reg);
        $display("dtm_req_valid = %d", dtm_req_valid);
        $display("req_data = 0x%x", req_data);

        // IDLE
        TMS = 0;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // IDLE
        TMS = 0;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        $display("dmstatus = 0x%x", dmstatus);

        // IDLE
        TMS = 0;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // SELECT-DR
        TMS = 1;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // dmi read
        shift_reg = {6'h11, {(32){1'b0}}, 2'b01};

        // CAPTURE-DR
        TMS = 0;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // SHIFT-DR
        TMS = 0;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // SHIFT-DR & EXIT1-DR
        for (i = 40; i > 0; i = i - 1) begin
            if (shift_reg[0] == 1'b1)
                TDI = 1'b1;
            else
                TDI = 1'b0;

            if (i == 1)
                TMS = 1;

            TCK = 0;
            #100
            in = TDO;
            TCK = 1;
            #100
            TCK = 0;

            shift_reg = {in, shift_reg[39:1]};
        end

        // PAUSE-DR
        TMS = 0;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // EXIT2-DR
        TMS = 1;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // UPDATE-DR
        TMS = 1;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // IDLE
        TMS = 0;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // IDLE
        TMS = 0;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // IDLE
        TMS = 0;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // IDLE
        TMS = 0;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // SELECT-DR
        TMS = 1;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // dmi read
        shift_reg = {6'h11, {(32){1'b0}}, 2'b00};

        // CAPTURE-DR
        TMS = 0;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // SHIFT-DR
        TMS = 0;
        TCK = 0;
        #100
        TCK = 1;
        #100
        TCK = 0;

        // SHIFT-DR & EXIT1-DR
        for (i = 40; i > 0; i = i - 1) begin
            if (shift_reg[0] == 1'b1)
                TDI = 1'b1;
            else
                TDI = 1'b0;

            if (i == 1)
                TMS = 1;

            TCK = 0;
            #100
            in = TDO;
            TCK = 1;
            #100
            TCK = 0;

            shift_reg = {in, shift_reg[39:1]};
        end

        #100

        $display("shift_reg = 0x%x", shift_reg[33:2]);

        if (dmstatus == shift_reg[33:2]) begin
            $display("######################");
            $display("### jtag test pass ###");
            $display("######################");
        end else begin
            $display("######################");
            $display("!!! jtag test fail !!!");
            $display("######################");
        end


        $finish;
    end

    // sim timeout
    initial begin
        #50000000
        $display("Time Out.");
        $finish;
    end

    // read mem data
    initial begin
        #20
//        $readmemh ("C:\\Users\\newrz\\Desktop\\riscv\\simple_riscv_soft_core\\sim\\inst.data", soc_top_inst.srambus_inst.sirv_sim_ram_inst.mem_r);
//        $readmemh ("C:\\Users\\newrz\\Desktop\\riscv\\tinyriscv\\sim\\inst.data", soc_top_inst.srambus_inst.sirv_sim_ram_inst.mem_r);
//        $readmemh ("C:\\Users\\newrz\\Desktop\\riscv\\simple_riscv_soft_core\\sim\\inst.data", soc_top_inst.sirv_duelport_ram_inst.mem_r);
        $readmemh ("C:\\Users\\newrz\\Desktop\\riscv\\simple_riscv_soft_core\\sim\\instdata3.txt", axi_soc_top_inst.AXI_DUELPORTSRAM_inst.sirv_duelport_ram_inst.mem_r);
    end

    // generate wave file, used by gtkwave
    initial begin
        $dumpfile("axi_riscv_core_jtag_sim.vcd");
        $dumpvars(0, axi_riscv_core_jtag_sim);
    end

    wire over;
    wire succ;
    wire halted_ind;
    wire uart_tx_pin;
    wire uart_rx_pin;
    wire [1:0]gpio;
    reg gpio_input;
    wire gpio_output;
    initial begin
        gpio_input = 0;
    end
    always #10000 gpio_input = ~gpio_input;
    assign gpio[1] = gpio_input;
    assign gpio_output = gpio[0];
//    wire jtag_TCK;
//    wire jtag_TMS;
//    wire jtag_TDI;
//    wire jtag_TDO;
    wire spi_miso;
    wire spi_mosi;
    wire spi_ss;
    wire spi_clk;
    assign spi_miso = 1'b0;
    assign uart_rx_pin = uart_tx;
    axi_soc_top soc_top_inst(
        .sys_clk(clk),
        .rst_ext_i(rst_n),
        .uart_debug_pin(1'b0),
        .over(over),
        .succ(succ),
        .halted_ind(halted_ind),
        .uart_tx_pin(uart_tx_pin),
        .uart_rx_pin(uart_rx_pin),
        .gpio(gpio),
        .spi_miso(spi_miso),
        .spi_mosi(spi_mosi),
        .spi_ss(spi_ss),
        .spi_clk(spi_clk)
        ,
        .jtag_TCK(TCK),
        .jtag_TMS(TMS),
        .jtag_TDI(TDI),
        .jtag_TDO(TDO)
    );


    reg [7:0] mem_a [3:0];    
    initial begin
        $readmemh("F:/vivadoworkspace/Arty/tx.txt",mem_a);
    end
    
task tx_bit(
    input [7:0]data
);
    integer i;
    for (i = 0 ; i <10 ; i = i + 1) begin
        case (i)
            0: uart_tx <=  1'b0;
            1: uart_tx <=  data[0];
            2: uart_tx <=  data[1];
            3: uart_tx <=  data[2];
            4: uart_tx <=  data[3];
            5: uart_tx <=  data[4];
            6: uart_tx <=  data[5];
            7: uart_tx <=  data[6];
            8: uart_tx <=  data[7];
            9: uart_tx <=   1'b1;
            default:uart_tx <= 1'b1;
        endcase
        #8601;
    end
endtask

task tx_byte();
    integer i;
      for (i = 0 ; i <4 ; i = i + 1) begin
            tx_bit(mem_a[i]);
      end
endtask

    initial begin
        #100000
        tx_byte();
        #250000
        tx_byte();
    end
endmodule
