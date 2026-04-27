`timescale 1ns/1ps

module number_capture_tb;

    // Señales
    logic clk;
    logic rst_n;

    logic [3:0] key_code;
    logic key_valid;
    logic enable;

    logic [9:0] number;
    logic done;

    // DUT
    number_capture DUT (
        .clk(clk),
        .rst_n(rst_n),
        .key_code(key_code),
        .key_valid(key_valid),
        .enable(enable),
        .number(number),
        .done(done)
    );

    // Clock (periodo 20 ns)
    always #10 clk = ~clk;

    // Estímulos
    initial begin
        $dumpfile("number_capture.vcd");
        $dumpvars(0, number_capture_tb);

        clk = 0;
        rst_n = 0;
        key_code = 0;
        key_valid = 0;
        enable = 1;

        // Reset
        #50;
        rst_n = 1;

        // ---------------------------
        // Caso 1: 3 dígitos válidos (357)
        // ---------------------------
        send_key(4'd3);
        send_key(4'd5);
        send_key(4'd7);

        #50;

        // ---------------------------
        // Caso 2: cuarto dígito (debe ignorarse)
        // ---------------------------
        send_key(4'd9);

        #100;

        // ---------------------------
        // Caso 3: entradas no decimales (A, F)
        // ---------------------------
        send_key(4'hA);
        send_key(4'hF);

        #100;

        // ---------------------------
        // Caso 4: nuevo número (128)
        // ---------------------------
        rst_n = 0;
        #50;
        rst_n = 1;

        send_key(4'd1);
        send_key(4'd2);
        send_key(4'd8);

        #100;

        $finish;
    end

    // Tarea para simular pulsación de tecla
    task send_key(input [3:0] key);
        begin
            @(posedge clk);
            key_code  = key;
            key_valid = 1;

            @(posedge clk);
            key_valid = 0;

            // separación entre teclas
            repeat(5) @(posedge clk);
        end
    endtask

endmodule