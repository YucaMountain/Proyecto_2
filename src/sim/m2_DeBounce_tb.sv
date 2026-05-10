//==============================================================================
// Testbench para DeBounce - Versión compatible con Verilog 2001
//==============================================================================
`timescale 1ns / 1ps

module DeBounce_tb();
    
    //========================================================================
    // Parámetros de simulación
    //========================================================================
    localparam CLK_PERIOD = 20;  // 50 MHz -> 20ns periodo
    
    //========================================================================
    // Señales
    //========================================================================
    reg clk;
    reg n_reset;
    reg button_in;
    wire DB_out;
    
    // Variables para verificación
    integer test_count = 0;
    integer pass_count = 0;
    integer fail_count = 0;
    
    //========================================================================
    // Instanciación del módulo (con parámetros para simulación rápida)
    //========================================================================
    DeBounce #(
        
    ) uut (
        .clk      (clk),
        .n_reset  (n_reset),
        .button_in(button_in),
        .DB_out   (DB_out)
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
    task reset_system;
        begin
            n_reset = 0;
            repeat(5) @(posedge clk);
            n_reset = 1;
            @(posedge clk);
            $display("✓ Sistema reseteado");
        end
    endtask
    
    task press_button;
        begin
            $display("  Presionando botón...");
            button_in = 1'b1;
        end
    endtask
    
    task release_button;
        begin
            $display("  Liberando botón...");
            button_in = 1'b0;
        end
    endtask
    
    task wait_cycles;
        input integer cycles;
        integer i;
        begin
            for (i = 0; i < cycles; i = i + 1) begin
                @(posedge clk);
            end
        end
    endtask
    
    //========================================================================
    // Simulación de rebotes
    //========================================================================
    task simulate_bounces;
        input integer duration_cycles;
        integer i;
        begin
            for (i = 0; i < duration_cycles; i = i + 1) begin
                #(CLK_PERIOD/2);
                button_in = ~button_in;
            end
        end
    endtask
    
    //========================================================================
    // Verificación automática
    //========================================================================
    task check_output;
        input expected;
        input [100:0] test_name;
        begin
            test_count = test_count + 1;
            #1;  // Pequeño delay para estabilidad
            if (DB_out === expected) begin
                $display("  ✓ %s - PASÓ (salida = %b)", test_name, DB_out);
                pass_count = pass_count + 1;
            end else begin
                $display("  ✗ %s - FALLÓ (esperado=%b, obtenido=%b)", 
                         test_name, expected, DB_out);
                fail_count = fail_count + 1;
            end
        end
    endtask
    
    //========================================================================
    // Prueba principal
    //========================================================================
    initial begin
        $display("============================================================");
        $display("Iniciando Testbench del Módulo DeBounce");
        $display("============================================================\n");
        
        // Inicialización
        button_in = 1'b0;
        
        // Reset
        reset_system();
        
        //========================================================================
        // Prueba 1: Botón normal sin rebotes
        //========================================================================
        $display("\n--- Prueba 1: Botón normal sin rebotes ---");
        press_button();
        wait_cycles(200);  // Esperar más que el debounce
        check_output(1'b1, "Boton presionado estable");
        release_button();
        wait_cycles(200);
        check_output(1'b0, "Boton liberado estable");
        
        //========================================================================
        // Prueba 2: Botón con rebotes al presionar
        //========================================================================
        $display("\n--- Prueba 2: Boton con rebotes al presionar ---");
        press_button();
        simulate_bounces(5);   // Simular 5 rebotes rápidos
        wait_cycles(200);
        check_output(1'b1, "Boton con rebotes - estabiliza en alto");
        release_button();
        wait_cycles(10);
        check_output(1'b0, "Mantiene alto hasta liberar");
        
        //========================================================================
        // Prueba 3: Rebotes cortos (deben ser ignorados)
        //========================================================================
        $display("\n--- Prueba 3: Rebotes cortos (deben ser ignorados) ---");
        release_button();
        wait_cycles(100);
        check_output(1'b0, "Estado inicial bajo");
        
        // Rebotar pero no estabilizar
        press_button();
        wait_cycles(5);
        release_button();
        wait_cycles(10);
        check_output(1'b0, "Rebote corto - ignorado");
        
        // Intentar estabilizar
        press_button();
        wait_cycles(200);
        check_output(1'b1, "Segunda presion - estabiliza");
        
        //========================================================================
        // Prueba 4: Rebotes múltiples
        //========================================================================
        $display("\n--- Prueba 4: Rebotes multiples y aleatorios ---");
        release_button();
        wait_cycles(50);
        
        // Secuencia de rebotes
        press_button();
        #(CLK_PERIOD * 3); release_button();
        #(CLK_PERIOD * 2); press_button();
        #(CLK_PERIOD * 4); release_button();
        #(CLK_PERIOD * 1); press_button();
        #(CLK_PERIOD * 5); release_button();
        #(CLK_PERIOD * 2); press_button();
        
        wait_cycles(200);
        check_output(1'b1, "Rebotes caoticos - estabiliza alto");
        
        release_button();
        wait_cycles(200);
        check_output(1'b0, "Liberacion final");
        
        //========================================================================
        // Prueba 5: Reset durante operación
        //========================================================================
        $display("\n--- Prueba 5: Reset durante boton presionado ---");
        press_button();
        wait_cycles(50);
        $display("  Aplicando reset...");
        n_reset = 0;
        wait_cycles(10);
        check_output(1'b0, "Reset activo - salida 0");
        
        n_reset = 1;
        wait_cycles(50);
        
        // Verificar que funciona post-reset
        release_button();
        wait_cycles(50);
        press_button();
        wait_cycles(200);
        check_output(1'b1, "Post-reset - funciona correctamente");
        release_button();
        
        //========================================================================
        // Prueba 6: Botón sostenido
        //========================================================================
        $display("\n--- Prueba 6: Boton sostenido por largo tiempo ---");
        press_button();
        wait_cycles(1000);
        check_output(1'b1, "Boton sostenido - mantiene salida alta");
        release_button();
        wait_cycles(200);
        check_output(1'b0, "Liberacion despues de presion larga");
        
        //========================================================================
        // Prueba 7: Secuencia rápida
        //========================================================================
        $display("\n--- Prueba 7: Secuencia rapida de presiones ---");
        for (integer i = 0; i < 5; i = i + 1) begin
            press_button();
            wait_cycles(200);
            release_button();
            wait_cycles(100);
        end
        check_output(1'b0, "Secuencia rapida completada");
        
        //========================================================================
        // Resumen final
        //========================================================================
        $display("\n============================================================");
        $display("RESUMEN DE PRUEBAS");
        $display("============================================================");
        $display("Pruebas totales: %0d", test_count);
        $display("Pruebas exitosas: %0d", pass_count);
        $display("Pruebas fallidas: %0d", fail_count);
        $display("============================================================");
        
        if (fail_count == 0) begin
            $display("\n✅ ¡TODAS LAS PRUEBAS PASARON EXITOSAMENTE! ✅");
        end else begin
            $display("\n❌ ALGUNAS PRUEBAS FALLARON - Revisar resultados ❌");
        end
        
        $display("\nSimulacion completada en tiempo: %0t", $time);
        
        #1000;
        $finish;
    end
    
    //========================================================================
    // Monitoreo de señales
    //========================================================================
    initial begin
        $monitor("Time=%0t | button_in=%b | DB_out=%b | n_reset=%b", 
                 $time, button_in, DB_out, n_reset);
    end
    
    //========================================================================
    // Generación de archivo VCD
    //========================================================================
    initial begin
        $dumpfile("DeBounce_tb.vcd");
        $dumpvars(0, DeBounce_tb);
    end
    
endmodule
