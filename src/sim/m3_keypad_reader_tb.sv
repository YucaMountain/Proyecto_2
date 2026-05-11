`timescale 1ns / 1ps

module m3_keypad_reader_tb;

    //============================================================
    // Parámetros
    //============================================================
    localparam CLK_PERIOD = 20;   // periodo de reloj de simulación
    localparam HOLD_CYCLES = 40;  // > 20 ciclos para pasar debounce

    //============================================================
    // Señales
    //============================================================
    reg         clk;
    reg         rst_n;
    reg  [3:0]  rows;
    wire [3:0]  cols;
    wire [3:0]  key_code;
    wire        key_valid;

    // Variables para “apretar” una tecla en la matriz
    reg         key_active;
    reg  [1:0]  pressed_row;
    reg  [1:0]  pressed_col;

    integer errors;
    integer pulse_count;

    //============================================================
    // DUT
    //============================================================
    m3_keypad_reader uut (
        .clk      (clk),
        .rst_n    (rst_n),
        .rows     (rows),
        .cols     (cols),
        .key_code (key_code),
        .key_valid(key_valid)
    );

    //============================================================
    // Reloj
    //============================================================
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    //============================================================
    // Modelo del teclado matricial
    // Reposo: filas en 1111 (pull-up)
    // Si una tecla está activa, solo baja la fila cuando la columna
    // correspondiente está siendo escaneada (cols[col] = 0)
    //============================================================
    always @(*) begin
        rows = 4'b1111;

        if (key_active) begin
            case (pressed_col)
                2'd0: if (cols[0] == 1'b0) rows[pressed_row] = 1'b0;
                2'd1: if (cols[1] == 1'b0) rows[pressed_row] = 1'b0;
                2'd2: if (cols[2] == 1'b0) rows[pressed_row] = 1'b0;
                2'd3: if (cols[3] == 1'b0) rows[pressed_row] = 1'b0;
            endcase
        end
    end

    //============================================================
    // Función: código esperado según fila/columna
    //============================================================
    function [3:0] expected_key;
        input [1:0] row;
        input [1:0] col;
        begin
            case ({row, col})
                4'b0000: expected_key = 4'h1;
                4'b0001: expected_key = 4'h2;
                4'b0010: expected_key = 4'h3;
                4'b0011: expected_key = 4'hA;

                4'b0100: expected_key = 4'h4;
                4'b0101: expected_key = 4'h5;
                4'b0110: expected_key = 4'h6;
                4'b0111: expected_key = 4'hB;

                4'b1000: expected_key = 4'h7;
                4'b1001: expected_key = 4'h8;
                4'b1010: expected_key = 4'h9;
                4'b1011: expected_key = 4'hC;

                4'b1100: expected_key = 4'hE;
                4'b1101: expected_key = 4'h0;
                4'b1110: expected_key = 4'hF;
                4'b1111: expected_key = 4'hD;

                default: expected_key = 4'h0;
            endcase
        end
    endfunction

    //============================================================
    // Tareas
    //============================================================
    task reset_system;
    begin
        rst_n       = 1'b0;
        key_active  = 1'b0;
        pressed_row = 2'd0;
        pressed_col = 2'd0;
        repeat(5) @(posedge clk);
        rst_n = 1'b1;
        repeat(5) @(posedge clk);
        $display("✓ Sistema reseteado");
    end
    endtask

    task press_key;
        input [1:0] row;
        input [1:0] col;
    begin
        $display("  Presionando tecla fila=%0d col=%0d", row, col);
        pressed_row = row;
        pressed_col = col;
        key_active  = 1'b1;
    end
    endtask

    task release_key;
    begin
        $display("  Liberando tecla");
        key_active = 1'b0;
    end
    endtask

    task wait_cycles;
        input integer n;
        integer i;
    begin
        for (i = 0; i < n; i = i + 1)
            @(posedge clk);
    end
    endtask

    task test_one_key;
        input [1:0] row;
        input [1:0] col;
        input [100*8:1] name;
        reg [3:0] exp;
    begin
        exp = expected_key(row, col);
        pulse_count = 0;

        $display("\n--- %0s ---", name);

        press_key(row, col);

        // esperar a que pase debounce y salga key_valid
        wait_cycles(HOLD_CYCLES);

        if (key_valid !== 1'b1) begin
            $display("  ✗ ERROR: key_valid no se activó");
            errors = errors + 1;
        end else begin
            $display("  ✓ key_valid detectado");
        end

        if (key_code !== exp) begin
            $display("  ✗ ERROR: esperado key_code=%h, obtenido=%h", exp, key_code);
            errors = errors + 1;
        end else begin
            $display("  ✓ key_code correcto: %h", key_code);
        end

        // confirmar que key_valid dura un ciclo
        @(posedge clk);
        if (key_valid !== 1'b0) begin
            $display("  ✗ ERROR: key_valid duró más de un ciclo");
            errors = errors + 1;
        end else begin
            $display("  ✓ key_valid fue pulso de un ciclo");
        end

        // sostener más tiempo y verificar que no vuelva a disparar
        wait_cycles(20);
        if (key_valid !== 1'b0) begin
            $display("  ✗ ERROR: key_valid volvió a activarse con tecla sostenida");
            errors = errors + 1;
        end else begin
            $display("  ✓ tecla sostenida no generó nuevos pulsos");
        end

        release_key();
        wait_cycles(HOLD_CYCLES);
    end
    endtask

    //============================================================
    // Conteo de pulsos
    //============================================================
    always @(posedge clk) begin
        if (key_valid)
            pulse_count = pulse_count + 1;
    end

    //============================================================
    // Test principal
    //============================================================
    initial begin
        errors = 0;
        pulse_count = 0;

        $display("============================================================");
        $display("Iniciando testbench de m3_keypad_reader");
        $display("============================================================");

        reset_system();

        // Pruebas representativas
        test_one_key(2'd0, 2'd0, "Prueba tecla 1");
        test_one_key(2'd0, 2'd3, "Prueba tecla A");
        test_one_key(2'd1, 2'd1, "Prueba tecla 5");
        test_one_key(2'd2, 2'd2, "Prueba tecla 9");
        test_one_key(2'd3, 2'd1, "Prueba tecla 0");
        test_one_key(2'd3, 2'd3, "Prueba tecla D");

        // Verificar que en reposo sigue escaneando columnas
        $display("\n--- Verificación de escaneo en reposo ---");
        key_active = 1'b0;
        wait_cycles(20);
        $display("  cols actual = %b", cols);

        $display("\n============================================================");
        if (errors == 0)
            $display("✅ TODAS LAS PRUEBAS PASARON");
        else
            $display("❌ SE ENCONTRARON %0d ERRORES", errors);
        $display("============================================================");

        #100;
        $finish;
    end

    //============================================================
    // Monitor
    //============================================================
    initial begin
        $monitor("t=%0t rows=%b cols=%b key_valid=%b key_code=%h",
                 $time, rows, cols, key_valid, key_code);
    end

    //============================================================
    // VCD
    //============================================================
    initial begin
        $dumpfile("m3_keypad_reader_tb.vcd");
        $dumpvars(0, m3_keypad_reader_tb);
    end

endmodule
