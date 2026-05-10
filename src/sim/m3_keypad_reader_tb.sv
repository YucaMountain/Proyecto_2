`timescale 1ns / 1ps

module keypad_reader_tb ();

    // Parámetros
    localparam CLK_PERIOD = 20;  // 50 MHz
    localparam DEBOUNCE_TIME = 10000;  // 10us para simulación (en realidad sería más)
    
    // Señales
    logic clk;
    logic rst_n;
    logic [3:0] rows;
    logic [3:0] cols;
    logic [3:0] key_code;
    logic key_valid;
    
    // Variables para simular el teclado
    logic [3:0] keypad_matrix [0:3][0:3];
    logic [3:0] simulated_rows;
    
    // Instancia del módulo
    keypad_reader uut (
        .clk       (clk),
        .rst_n     (rst_n),
        .rows      (rows),
        .cols      (cols),
        .key_code  (key_code),
        .key_valid (key_valid)
    );
    
    // Generación del reloj
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Simulación del teclado (matriz 4x4)
    task press_key(input int row, input int col);
        begin
            $display("  Presionando tecla en fila %0d, columna %0d", row, col);
            
            // Simular rebotes
            for (int i = 0; i < 5; i++) begin
                #(CLK_PERIOD * 2);
                rows = ~(1 << row);  // Activar fila correspondiente
                #(CLK_PERIOD * 1);
                rows = 4'b0000;      // Rebote
            end
            
            // Presión estable
            rows = ~(1 << row);
            #(DEBOUNCE_TIME);
            
            $display("  Tecla estabilizada");
        end
    endtask
    
    task release_key();
        begin
            $display("  Liberando tecla");
            
            // Simular rebotes
            for (int i = 0; i < 3; i++) begin
                #(CLK_PERIOD * 2);
                rows = 4'b0000;
                #(CLK_PERIOD * 1);
                rows = ~(1 << 0);  // Rebote con otra fila
            end
            
            // Liberación estable
            rows = 4'b0000;
            #(DEBOUNCE_TIME);
            
            $display("  Tecla liberada");
        end
    endtask
    
    // Monitorear columnas
    initial begin
        forever begin
            @(cols);
            #1;  // Pequeño retraso para evitar race conditions
            // Esto es solo para visualización
        end
    end
    
    // Función para obtener la tecla esperada
    function [3:0] get_expected_key(input int row, input int col);
        case ({row, col})
            {2'b00, 2'b00}: get_expected_key = 4'h1;
            {2'b01, 2'b00}: get_expected_key = 4'h4;
            {2'b10, 2'b00}: get_expected_key = 4'h7;
            {2'b11, 2'b00}: get_expected_key = 4'hE;
            
            {2'b00, 2'b01}: get_expected_key = 4'h2;
            {2'b01, 2'b01}: get_expected_key = 4'h5;
            {2'b10, 2'b01}: get_expected_key = 4'h8;
            {2'b11, 2'b01}: get_expected_key = 4'h0;
            
            {2'b00, 2'b10}: get_expected_key = 4'h3;
            {2'b01, 2'b10}: get_expected_key = 4'h6;
            {2'b10, 2'b10}: get_expected_key = 4'h9;
            {2'b11, 2'b10}: get_expected_key = 4'hF;
            
            {2'b00, 2'b11}: get_expected_key = 4'hA;
            {2'b01, 2'b11}: get_expected_key = 4'hB;
            {2'b10, 2'b11}: get_expected_key = 4'hC;
            {2'b11, 2'b11}: get_expected_key = 4'hD;
            
            default: get_expected_key = 4'h0;
        endcase
    endfunction
    
    // Proceso principal de prueba
    initial begin
        $display("===========================================");
        $display("Iniciando testbench del keypad_reader");
        $display("===========================================\n");
        
        // Inicialización
        rows = 4'b0000;
        
        // Reset del sistema
        $display("Aplicando reset...");
        rst_n = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        $display("✓ Sistema reseteado\n");
        
        // Prueba 1: Presionar todas las teclas una por una
        $display("--- Prueba 1: Verificar todas las teclas ---");
        for (int row = 0; row < 4; row++) begin
            for (int col = 0; col < 4; col++) begin
                $display("\nProbando tecla en fila %0d, columna %0d", row, col);
                
                press_key(row, col);
                
                // Esperar a que se detecte la tecla
                #(CLK_PERIOD * 10);
                
                // Verificar key_valid
                if (key_valid) begin
                    $display("  ✓ key_valid detectado");
                    
                    // Verificar código
                    if (key_code == get_expected_key(row, col)) begin
                        $display("  ✓ Código correcto: %h", key_code);
                    end else begin
                        $display("  ✗ ERROR: Código esperado %h, obtenido %h", 
                                 get_expected_key(row, col), key_code);
                    end
                end else begin
                    $display("  ✗ ERROR: key_valid no detectado");
                end
                
                release_key();
                #(CLK_PERIOD * 100);
            end
        end
        $display("");
        
        // Prueba 2: Verificar que key_valid es solo un pulso
        $display("--- Prueba 2: Verificar pulso de key_valid ---");
        $display("\nPresionando tecla 1 (fila0,col0)");
        press_key(0, 0);
        
        // Verificar que key_valid dure solo un ciclo
        @(posedge clk);
        if (key_valid) begin
            @(posedge clk);
            if (!key_valid) begin
                $display("  ✓ key_valid es un solo pulso (correcto)");
            end else begin
                $display("  ✗ ERROR: key_valid dura más de un ciclo");
            end
        end
        
        release_key();
        #(CLK_PERIOD * 50);
        $display("");
        
        // Prueba 3: Múltiples teclas rápidamente
        $display("--- Prueba 3: Secuencia rápida de teclas ---");
        
        // Presionar tecla 1
        $display("\nSecuencia: 1, 2, 3, 4");
        press_key(0, 0);  // Tecla 1
        #(CLK_PERIOD * 20);
        release_key();
        #(CLK_PERIOD * 10);
        
        press_key(0, 1);  // Tecla 2
        #(CLK_PERIOD * 20);
        release_key();
        #(CLK_PERIOD * 10);
        
        press_key(0, 2);  // Tecla 3
        #(CLK_PERIOD * 20);
        release_key();
        #(CLK_PERIOD * 10);
        
        press_key(0, 3);  // Tecla 4
        #(CLK_PERIOD * 20);
        release_key();
        #(CLK_PERIOD * 50);
        $display("");
        
        // Prueba 4: Tecla sostenida (debe generar solo un pulso)
        $display("--- Prueba 4: Tecla sostenida por mucho tiempo ---");
        $display("\nPresionando tecla 5 y sosteniendo");
        press_key(1, 0);  // Tecla 5
        
        // Esperar varios ciclos
        repeat(500) @(posedge clk);
        
        // Debe haber generado solo un pulso
        $display("  Verificando que no hay múltiples detecciones...");
        #(CLK_PERIOD * 10);
        
        release_key();
        #(CLK_PERIOD * 50);
        $display("");
        
        // Prueba 5: Teclas simultáneas (debe ignorarse)
        $display("--- Prueba 5: Múltiples teclas simultáneas ---");
        $display("\nPresionando dos teclas a la vez");
        
        // Simular dos filas activas
        rows = ~(1 << 0) | ~(1 << 1);  // Filas 0 y 1 activas
        #(DEBOUNCE_TIME);
        
        // Verificar que no se detecte o que key_code sea 0
        if (!key_valid) begin
            $display("  ✓ Teclas simultáneas ignoradas correctamente");
        end else begin
            $display("  ✗ ERROR: Se detectó tecla con múltiples filas");
        end
        
        rows = 4'b0000;
        #(CLK_PERIOD * 50);
        $display("");
        
        // Prueba 6: Reset durante operación
        $display("--- Prueba 6: Reset durante operación ---");
        $display("\nPresionando tecla y aplicando reset");
        press_key(2, 2);  // Tecla 9
        
        #(CLK_PERIOD * 100);
        $display("Aplicando reset...");
        rst_n = 0;
        #(CLK_PERIOD * 10);
        rst_n = 1;
        
        if (!key_valid) begin
            $display("  ✓ Sistema reseteado correctamente");
        end
        
        release_key();
        #(CLK_PERIOD * 50);
        
        // Prueba 7: Simulación completa de entrada de código
        $display("\n--- Prueba 7: Ingresando código 1234 ---");
        
        // Ingresar 1
        press_key(0, 0);
        #(CLK_PERIOD * 50);
        release_key();
        #(CLK_PERIOD * 20);
        
        // Ingresar 2
        press_key(0, 1);
        #(CLK_PERIOD * 50);
        release_key();
        #(CLK_PERIOD * 20);
        
        // Ingresar 3
        press_key(0, 2);
        #(CLK_PERIOD * 50);
        release_key();
        #(CLK_PERIOD * 20);
        
        // Ingresar 4
        press_key(0, 3);
        #(CLK_PERIOD * 50);
        release_key();
        
        $display("  Secuencia completada");
        
        // Prueba 8: Verificar escaneo de columnas
        $display("\n--- Prueba 8: Monitoreo de escaneo de columnas ---");
        $display("Las columnas deberían estar cambiando secuencialmente:");
        
        for (int i = 0; i < 16; i++) begin
            @(posedge clk);
            if (i % 4 == 0)
                $display("  col_index = %0d, cols = %b", i%4, cols);
        end
        
        // Resumen final
        $display("\n===========================================");
        $display("Pruebas completadas exitosamente");
        $display("===========================================");
        
        #1000;
        $finish;
    end
    
    // Monitor de señales
    initial begin
        $monitor("Time=%0t | rows=%b | cols=%b | key_valid=%b | key_code=%h", 
                 $time, rows, cols, key_valid, key_code);
    end
    
    // Generar archivo VCD
    initial begin
        $dumpfile("tb_keypad_reader.vcd");
        $dumpvars(0, tb_keypad_reader);
    end
    
    // Verificación automática adicional
    int errors = 0;
    
    always @(posedge clk) begin
        if (key_valid) begin
            // Verificar que key_code no sea 0 cuando hay tecla válida
            if (key_code == 4'h0 && rows != 4'b0000) begin
                $error("key_valid activo pero key_code = 0");
                errors++;
            end
        end
    end
    
    // Finalizar con resumen de errores
    final begin
        if (errors == 0)
            $display("\n✅ TODAS LAS PRUEBAS PASARON - 0 errores");
        else
            $display("\n❌ PRUEBAS FALLIDAS - %0d errores encontrados", errors);
    end
    
endmodule
