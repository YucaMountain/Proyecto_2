`timescale 1ns / 1ps

module tb_m7_prueba;

    reg         clk;
    reg         rst_n;
    reg  [3:0]  key_code;
    reg         key_valid;
    reg  [15:0] current_display;

    wire        m4_clear;
    wire        m4_load;
    wire [15:0] m4_result_data;

    m7_prueba dut (
        .clk             (clk),
        .rst_n           (rst_n),
        .key_code        (key_code),
        .key_valid       (key_valid),
        .current_display (current_display),
        .m4_clear        (m4_clear),
        .m4_load         (m4_load),
        .m4_result_data  (m4_result_data)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task press_key;
        input [3:0] code;
    begin
        @(negedge clk);
        key_code  = code;
        key_valid = 1'b1;
        @(negedge clk);
        key_valid = 1'b0;
    end
    endtask

    initial begin
        $dumpfile("tb_m7_prueba.vcd");
        $dumpvars(0, tb_m7_prueba);

        $display("=== Iniciando tb_m7_prueba ===");

        rst_n = 0;
        key_code = 0;
        key_valid = 0;
        current_display = 16'h0000;
        repeat(4) @(posedge clk);
        rst_n = 1;
        repeat(2) @(posedge clk);

        // A = 123
        current_display = 16'h1230;
        press_key(4'hA);
        repeat(2) @(posedge clk);

        // B = 456
        current_display = 16'h4560;
        press_key(4'hB);
        repeat(2) @(posedge clk);

        // calcular -> 123 + 456 = 579
        press_key(4'hD);
        repeat(8) @(posedge clk);

        if (m4_result_data !== 16'h579C)
            $display("ERROR: esperado 579C, obtenido %h", m4_result_data);

        // limpiar
        press_key(4'hC);
        repeat(2) @(posedge clk);

        // A = 999
        current_display = 16'h9990;
        press_key(4'hA);
        repeat(2) @(posedge clk);

        // B = 999
        current_display = 16'h9990;
        press_key(4'hB);
        repeat(2) @(posedge clk);

        // calcular -> 999 + 999 = 1998
        press_key(4'hD);
        repeat(8) @(posedge clk);

        if (m4_result_data !== 16'h8991)
            $display("ERROR: esperado 8991, obtenido %h", m4_result_data);

        $display("=== Fin tb_m7_prueba ===");
        $finish;
    end

endmodule
