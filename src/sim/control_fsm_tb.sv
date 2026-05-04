//==============================================================================
// Testbench para control_fsm - Máquina de estados para control de suma
//==============================================================================
`timescale 1ns / 1ps

module control_fsm_tb();
    
    //========================================================================
    // Parámetros de simulación
    //========================================================================
    localparam CLK_PERIOD = 20;  // 50 MHz
    
    //========================================================================
    // Señales del testbench
    //========================================================================
    logic clk;
    logic rst_n;
    logic [3:0] key_code;
    logic key_valid;
    logic [9:0] number_in;
    logic number_done;
    logic [9:0] numA;
    logic [9:0] numB;
    logic start_sum;
    logic enable_capture;
    
    // Variables para verificación
    int test_count = 0;
    int pass_count = 0;
    int fail_count = 0;
    
    //========================================================================
    // Instanciación del módulo
    //========================================================================
    control_fsm uut (
        .clk           (clk),
        .rst_n         (rst_n),
        .key_code      (key_code),
        .key_valid     (key_valid),
        .number_in     (number_in),
        .number_done   (number_done),
        .numA          (numA),
        .numB          (numB),
        .start_sum     (start_sum),
        .enable_capture(enable_capture)
    );
    
    //========================================================================
    // Generación de reloj
    //========================================================================
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    //========================================================================
    // Tareas de utilidad
    //========================================================================
    
    task reset_system();
        rst_n = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        $display("✓ Sistema reseteado");
    endtask
    
    task send_number(input [9:0] number);
        $display("  Enviando número: %0d", number);
        number_in = number;
        number_done = 1;
        @(posedge clk);
        number_done = 0;
        @(posedge clk);
    endtask
    
    task send_key(input [3:0] key);
        $display("  Enviando tecla: %h", key);
        key_code = key;
        key_valid = 1;
        @(posedge clk);
        key_valid = 0;
        @(posedge clk);
    endtask
    
    task wait_cycles(input int cycles);
        repeat(cycles) @(posedge clk);
    endtask
    
    task check_condition(
        input logic condition,
        input string test_name,
        input string details
    );
        test_count++;
        if (condition) begin
            $display("  ✓ %s - PASÓ (%s)", test_name, details);
            pass_count++;
        end else begin
            $display("  ✗ %s - FALLÓ (%s)", test_name, details);
            fail_count++;
        end
    endtask
    
    task check_equal(
        input [9:0] actual,
        input [9:0] expected,
        input string signal_name
    );
        test_count++;
        if (actual === expected) begin
            $display("  ✓ %s = %0d (correcto)", signal_name, actual);
            pass_count++;
        end else begin
            $display("  ✗ %s = %0d (esperado %0d)", signal_name, actual, expected);
            fail_count++;
        end
    endtask
    
    //========================================================================
    // Monitor de señales
    //========================================================================
    initial begin
        $monitor("Time=%0t | state=%s | numA=%0d | numB=%0d | start_sum=%b | enable=%b",
                 $time, uut.state.name(), numA, numB, start_sum, enable_capture);
    end
    
    //========================================================================
    // Prueba principal
    //========================================================================
    initial begin
        $display("============================================================");
        $display("Iniciando Testbench de control_fsm");
        $display("============================================================\n");
        
        // Inicialización
        key_code = 0;
        key_valid = 0;
        number_in = 0;
        number_done = 0;
        
        reset_system();
        
        // Prueba 1: Verificar estado inicial
        $display("\n--- Prueba 1: Verificación del estado inicial ---");
        wait_cycles(5);
        check_condition((enable_capture == 1), "Enable capture inicial", "debe estar activado");
        check_condition((start_sum == 0), "Start sum inicial", "debe estar inactivo");
        check_equal(numA, 0, "numA inicial");
        check_equal(numB, 0, "numB inicial");
        
        // Prueba 2: Capturar número A
        $display("\n--- Prueba 2: Capturar número A ---");
        send_number(123);
        wait_cycles(2);
        check_equal(numA, 123, "numA después de capturar");
        check_condition((enable_capture == 1), "Enable capture sigue activo", "debe seguir en INPUT_A");
        
        // Prueba 3: Enviar tecla A para cambiar a INPUT_B
        $display("\n--- Prueba 3: Tecla A para cambiar a INPUT_B ---");
        send_key(4'hA);
        wait_cycles(2);
        check_condition((uut.state == uut.INPUT_B), "Transición a INPUT_B", "debe cambiar al estado B");
        check_condition((enable_capture == 1), "Enable capture en INPUT_B", "debe seguir activo");
        
        // Prueba 4: Capturar número B
        $display("\n--- Prueba 4: Capturar número B ---");
        send_number(456);
        wait_cycles(5);
        check_equal(numB, 456, "numB después de capturar");
        check_condition((uut.state == uut.COMPUTE), "Transición a COMPUTE", "debe pasar a calcular");
        
        // Prueba 5: Verificar señal start_sum en estado COMPUTE
        $display("\n--- Prueba 5: Señal start_sum en estado COMPUTE ---");
        wait_cycles(2);
        check_condition((start_sum == 1), "Start_sum activado", "debe ser 1 en COMPUTE");
        check_condition((enable_capture == 0), "Enable capture desactivado", "debe ser 0 en COMPUTE");
        
        // Prueba 6: Volver a INPUT_A después de COMPUTE
        $display("\n--- Prueba 6: Retorno a INPUT_A ---");
        wait_cycles(3);
        check_condition((uut.state == uut.INPUT_A), "Retorno a INPUT_A", "debe volver al estado inicial");
        check_condition((start_sum == 0), "Start_sum limpiado", "debe volver a 0");
        check_condition((enable_capture == 1), "Enable capture reactivado", "debe ser 1 nuevamente");
        
        // Prueba 7: Flujo completo
        $display("\n--- Prueba 7: Flujo completo 789 + 321 ---");
        send_number(789);
        wait_cycles(2);
        check_equal(numA, 789, "numA en flujo completo");
        send_key(4'hA);
        wait_cycles(2);
        check_condition((uut.state == uut.INPUT_B), "Estado INPUT_B", "Cambio exitoso");
        send_number(321);
        wait_cycles(5);
        check_equal(numB, 321, "numB en flujo completo");
        check_condition((uut.state == uut.COMPUTE), "Estado COMPUTE", "Transición exitosa");
        check_condition((start_sum == 1), "Start_sum activado", "Señal de inicio de suma");
        wait_cycles(3);
        check_condition((uut.state == uut.INPUT_A), "Retorno a INPUT_A", "Fin de ciclo");
        
        // Prueba 8: Reset durante operación
        $display("\n--- Prueba 8: Reset durante operación ---");
        send_number(999);
        wait_cycles(2);
        send_key(4'hA);
        wait_cycles(2);
        $display("  Aplicando reset...");
        rst_n = 0;
        wait_cycles(3);
        rst_n = 1;
        wait_cycles(2);
        check_condition((uut.state == uut.INPUT_A), "Estado post-reset", "debe ser INPUT_A");
        check_equal(numA, 0, "numA post-reset");
        check_equal(numB, 0, "numB post-reset");
        
        // Prueba 9: Múltiples ciclos
        $display("\n--- Prueba 9: Múltiples ciclos de suma ---");
        send_number(100); send_key(4'hA); send_number(200);
        wait_cycles(5);
        send_number(300); send_key(4'hA); send_number(400);
        wait_cycles(5);
        $display("  ✓ Todos los ciclos completados");
        
        // Prueba 10: Teclas inválidas
        $display("\n--- Prueba 10: Teclas inválidas (no 'A') ---");
        send_number(111);
        send_key(4'hB); // Tecla incorrecta
        wait_cycles(2);
        check_condition((uut.state == uut.INPUT_A), "Tecla B en INPUT_A", "debe permanecer en INPUT_A");
        
        // Prueba 11: Verificación de number_done
        $display("\n--- Prueba 11: Verificación de number_done ---");
        number_in = 555;
        wait_cycles(3);
        check_condition((numA != 555), "Sin number_done", "numA NO debe actualizarse");
        send_number(555);
        wait_cycles(2);
        check_equal(numA, 555, "numA después de number_done");
        
        // Prueba 12: Transición automática
        $display("\n--- Prueba 12: Transición automática en INPUT_B ---");
        send_key(4'hA);
        wait_cycles(2);
        send_number(777);
        wait_cycles(2);
        check_condition((uut.state == uut.COMPUTE), "Transición automática", "debe pasar a COMPUTE");
        
        // Resumen final
        $display("\n============================================================");
        $display("RESUMEN DE PRUEBAS");
        $display("============================================================");
        $display("Pruebas totales: %0d", test_count);
        $display("Pruebas exitosas: %0d", pass_count);
        $display("Pruebas fallidas: %0d", fail_count);
        $display("============================================================");
        
        if (fail_count == 0) $display("\n✅ ¡TODAS LAS PRUEBAS PASARON EXITOSAMENTE! ✅");
        else $display("\n❌ ALGUNAS PRUEBAS FALLARON ❌");
        
        #1000;
        $finish;
    end
    
    // Aserción
    always @(posedge clk) begin
        if (uut.state == uut.COMPUTE) begin
            assert (enable_capture === 0) else 
                $error("enable_capture debe ser 0 en estado COMPUTE");
        end
    end
    
    // Archivo VCD
    initial begin
        $dumpfile("control_fsm_tb.vcd");
        $dumpvars(0, control_fsm_tb);
        $dumpvars(0, uut);
    end
    
endmodule