`timescale 1ns / 1ps

module m5_number_capture_tb;

    reg         clk;
    reg         rst_n;
    reg  [3:0]  key_code;
    reg         key_valid;
    reg         enable;
    wire [13:0] number;
    wire        done;

    integer errors;

    m5_number_capture uut (
        .clk      (clk),
        .rst_n    (rst_n),
        .key_code (key_code),
        .key_valid(key_valid),
        .enable   (enable),
        .number   (number),
        .done     (done)
    );

    //============================================================
    // Reloj
    //============================================================
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    //============================================================
    // Tareas
    //============================================================
    task reset_system;
    begin
        rst_n = 1'b0;
        key_code = 4'd0;
        key_valid = 1'b0;
        enable = 1'b0;
        repeat(3) @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);
        $display("✓ Sistema reseteado");
    end
    endtask

    task send_key;
        input [3:0] key;
    begin
        @(negedge clk);
        key_code  = key;
        key_valid = 1'b1;
        @(negedge clk);
        key_valid = 1'b0;
        key_code  = 4'd0;
    end
    endtask

    task check_number;
        input [13:0] expected;
        input [120*8:1] msg;
    begin
        @(posedge clk);
        #1;
        if (number !== expected) begin
            $display("✗ ERROR: %0s | esperado=%0d obtenido=%0d", msg, expected, number);
            errors = errors + 1;
        end else begin
            $display("✓ %0s | number=%0d", msg, number);
        end
    end
    endtask

    task check_done;
        input expected;
        input [120*8:1] msg;
    begin
        #1;
        if (done !== expected) begin
            $display("✗ ERROR: %0s | esperado done=%0b obtenido=%0b", msg, expected, done);
            errors = errors + 1;
        end else begin
            $display("✓ %0s | done=%0b", msg, done);
        end
    end
    endtask

    //============================================================
    // Pruebas
    //============================================================
    initial begin
        errors = 0;

        $dumpfile("m5_number_capture_tb.vcd");
        $dumpvars(0, m5_number_capture_tb);

        $display("==================================================");
        $display("Iniciando testbench de m5_number_capture");
        $display("==================================================");

        reset_system();

        // -------------------------------------------------------
        // Prueba 1: enable = 0, no debe capturar
        // -------------------------------------------------------
        $display("\n--- Prueba 1: enable desactivado ---");
        enable = 1'b0;
        send_key(4'd5);
        check_number(14'd0, "Enable=0 ignora tecla");
        check_done(1'b0, "Done permanece en 0");

        // -------------------------------------------------------
        // Prueba 2: primer dígito
        // -------------------------------------------------------
        $display("\n--- Prueba 2: primer digito ---");
        enable = 1'b1;
        send_key(4'd7);
        check_number(14'd7, "Captura primer digito");
        check_done(1'b1, "Done se activa en digito valido");

        @(posedge clk);
        check_done(1'b0, "Done baja al siguiente ciclo");

        // -------------------------------------------------------
        // Prueba 3: segundo dígito
        // -------------------------------------------------------
        $display("\n--- Prueba 3: segundo digito ---");
        send_key(4'd3);
        check_number(14'd73, "Captura segundo digito");
        check_done(1'b1, "Done se activa otra vez");

        @(posedge clk);
        check_done(1'b0, "Done baja al siguiente ciclo");

        // -------------------------------------------------------
        // Prueba 4: tercer dígito
        // -------------------------------------------------------
        $display("\n--- Prueba 4: tercer digito ---");
        send_key(4'd8);
        check_number(14'd738, "Captura tercer digito");
        check_done(1'b1, "Done se activa en tercer digito");

        @(posedge clk);
        check_done(1'b0, "Done baja al siguiente ciclo");

        // -------------------------------------------------------
        // Prueba 5: cuarto dígito
        // -------------------------------------------------------
        $display("\n--- Prueba 5: cuarto digito ---");
        send_key(4'd4);
        check_number(14'd7384, "Captura cuarto digito");
        check_done(1'b1, "Done se activa en cuarto digito");

        @(posedge clk);
        check_done(1'b0, "Done baja al siguiente ciclo");

        // -------------------------------------------------------
        // Prueba 6: quinto dígito debe ignorarse
        // -------------------------------------------------------
        $display("\n--- Prueba 6: quinto digito ignorado ---");
        send_key(4'd9);
        check_number(14'd7384, "Quinto digito ignorado");
        check_done(1'b0, "Done no se activa");

        // -------------------------------------------------------
        // Prueba 7: tecla no decimal debe ignorarse
        // -------------------------------------------------------
        $display("\n--- Prueba 7: tecla no decimal ---");
        send_key(4'hA);
        check_number(14'd7384, "Tecla no decimal ignorada");
        check_done(1'b0, "Done no se activa");

        // -------------------------------------------------------
        // Prueba 8: reset
        // -------------------------------------------------------
        $display("\n--- Prueba 8: reset ---");
        @(negedge clk);
        rst_n = 1'b0;
        @(posedge clk);
        #1;
        if (number !== 14'd0 || done !== 1'b0) begin
            $display("✗ ERROR: reset no limpio correctamente");
            errors = errors + 1;
        end else begin
            $display("✓ Reset limpio correctamente");
        end
        @(negedge clk);
        rst_n = 1'b1;

        // -------------------------------------------------------
        // Prueba 9: nuevo número con ceros
        // -------------------------------------------------------
        $display("\n--- Prueba 9: captura con ceros ---");
        enable = 1'b1;
        send_key(4'd0);
        check_number(14'd0, "Primer cero");
        send_key(4'd0);
        check_number(14'd0, "Segundo cero");
        send_key(4'd5);
        check_number(14'd5, "005 se representa como 5");

        // -------------------------------------------------------
        // Resumen
        // -------------------------------------------------------
        $display("\n==================================================");
        if (errors == 0)
            $display("✅ TODAS LAS PRUEBAS PASARON");
        else
            $display("❌ SE ENCONTRARON %0d ERRORES", errors);
        $display("==================================================");

        #20;
        $finish;
    end

endmodule
