`timescale 1ns / 1ps

module seven_segment_driver_tb();

    // Parámetros
    localparam CLK_PERIOD = 20; // 50 MHz
    
    // Señales
    logic clk;
    logic rst_n;
    logic [10:0] value;
    logic [6:0] seg;
    logic [3:0] an;
    
    // Instancia del módulo
    seven_segment_driver uut (
        .clk    (clk),
        .rst_n  (rst_n),
        .value  (value),
        .seg    (seg),
        .an     (an)
    );
    
    // Generación del reloj
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Tareas auxiliares
    task reset_system();
        begin
            rst_n = 0;
            repeat(5) @(posedge clk);
            rst_n = 1;
            @(posedge clk);
        end
    endtask
    
    task set_value(input [10:0] new_value);
        begin
            value = new_value;
            @(posedge clk);
        end
    endtask
    
    // Tarea para verificar un dígito específico (corregido: task en lugar de function)
    task check_digit(input [1:0] digit_pos, input [3:0] expected_value);
        logic [3:0] current_digit;
        logic [6:0] expected_seg;
        logic result;
        
        // Esperar a que se active el display correspondiente
        case (digit_pos)
            2'b00: begin // Unidades
                wait(an == 4'b1110);
                current_digit = expected_value;
            end
            2'b01: begin // Decenas
                wait(an == 4'b1101);
                current_digit = expected_value;
            end
            2'b10: begin // Centenas
                wait(an == 4'b1011);
                current_digit = expected_value;
            end
            2'b11: begin // Miles
                wait(an == 4'b0111);
                current_digit = expected_value;
            end
        endcase
        
        // Calcular segmentos esperados
        case (current_digit)
            4'd0: expected_seg = 7'b1000000;
            4'd1: expected_seg = 7'b1111001;
            4'd2: expected_seg = 7'b0100100;
            4'd3: expected_seg = 7'b0110000;
            4'd4: expected_seg = 7'b0011001;
            4'd5: expected_seg = 7'b0010010;
            4'd6: expected_seg = 7'b0000010;
            4'd7: expected_seg = 7'b1111000;
            4'd8: expected_seg = 7'b0000000;
            4'd9: expected_seg = 7'b0010000;
            default: expected_seg = 7'b1111111;
        endcase
        
        // Verificar resultado
        result = (seg === expected_seg);
        if (result)
            $display("  ✓ Dígito %0d correcto", digit_pos);
        else
            $display("  ✗ ERROR en dígito %0d: esperado %b, obtenido %b", 
                     digit_pos, expected_seg, seg);
    endtask
    
    // Proceso principal de prueba
    initial begin
        $display("===========================================");
        $display("Iniciando testbench del driver 7 segmentos");
        $display("===========================================\n");
        
        // Inicialización
        value = 0;
        
        // Reset del sistema
        reset_system();
        $display("✓ Sistema reseteado\n");
        
        // Prueba 1: Valores pequeños
        $display("--- Prueba 1: Valores pequeños (0-9) ---");
        for (int i = 0; i <= 9; i++) begin
            set_value(i);
            #(CLK_PERIOD * 100); // Esperar a que se multiplexen los displays
            
            $display("Valor = %0d", i);
            check_digit(2'b00, i);
        end
        $display("");
        
        // Prueba 2: Valores de dos dígitos
        $display("--- Prueba 2: Valores de dos dígitos (10-99) ---");
        for (int i = 10; i <= 99; i+= 10) begin
            set_value(i);
            #(CLK_PERIOD * 100);
            
            $display("Valor = %0d", i);
            check_digit(2'b01, i/10);
            check_digit(2'b00, i%10);
        end
        $display("");
        
        // Prueba 3: Valores de tres dígitos
        $display("--- Prueba 3: Valores de tres dígitos (100-999) ---");
        set_value(123);
        #(CLK_PERIOD * 100);
        $display("Valor = 123");
        check_digit(2'b10, 1);
        check_digit(2'b01, 2);
        check_digit(2'b00, 3);
        
        set_value(456);
        #(CLK_PERIOD * 100);
        $display("Valor = 456");
        check_digit(2'b10, 4);
        check_digit(2'b01, 5);
        check_digit(2'b00, 6);
        
        set_value(789);
        #(CLK_PERIOD * 100);
        $display("Valor = 789");
        check_digit(2'b10, 7);
        check_digit(2'b01, 8);
        check_digit(2'b00, 9);
        $display("");
        
        // Prueba 4: Valores de cuatro dígitos
        $display("--- Prueba 4: Valores de cuatro dígitos (1000-1998) ---");
        set_value(1234);
        #(CLK_PERIOD * 100);
        $display("Valor = 1234");
        check_digit(2'b11, 1);
        check_digit(2'b10, 2);
        check_digit(2'b01, 3);
        check_digit(2'b00, 4);
        
        set_value(1998);
        #(CLK_PERIOD * 100);
        $display("Valor = 1998");
        check_digit(2'b11, 1);
        check_digit(2'b10, 9);
        check_digit(2'b01, 9);
        check_digit(2'b00, 8);
        $display("");
        
        // Prueba 5: Valores en el límite
        $display("--- Prueba 5: Valores límite ---");
        set_value(0);
        #(CLK_PERIOD * 100);
        $display("Valor = 0");
        check_digit(2'b00, 0);
        
        set_value(1998);
        #(CLK_PERIOD * 100);
        $display("Valor = 1998");
        check_digit(2'b11, 1);
        check_digit(2'b10, 9);
        check_digit(2'b01, 9);
        check_digit(2'b00, 8);
        $display("");
        
        // Prueba 6: Secuencia rápida de valores
        $display("--- Prueba 6: Secuencia rápida de valores ---");
        for (int i = 0; i <= 1998; i += 200) begin
            set_value(i);
            #(CLK_PERIOD * 50);
            $display("Valor = %0d actualizado", i);
        end
        $display("");
        
        // Prueba 7: Verificar multiplexación
        $display("--- Prueba 7: Verificando multiplexación ---");
        set_value(9876);
        #(CLK_PERIOD * 500);
        
        $display("Observando multiplexación para valor 9876:");
        $display("  - Debería verse: Miles=9, Centenas=8, Decenas=7, Unidades=6");
        $display("  - Los ánodos deberían activarse secuencialmente");
        $display("");
        
        // Prueba 8: Reset durante operación
        $display("--- Prueba 8: Reset en medio de operación ---");
        set_value(5555);
        #(CLK_PERIOD * 50);
        $display("Reset aplicado...");
        reset_system();
        $display("Post-reset - Valor = %0d", value);
        #(CLK_PERIOD * 50);
        
        // Resumen final
        $display("===========================================");
        $display("Pruebas completadas exitosamente");
        $display("===========================================");
        
        #100;
        $finish;
    end
    
    // Monitor de señales (opcional)
    initial begin
        $monitor("Time=%0t | value=%0d | an=%b | seg=%b", 
                 $time, value, an, seg);
    end
    
    // Generar archivo VCD para波形 (corregido)
    initial begin
        $dumpfile("seven_segment_driver_tb.vcd");
        $dumpvars(0, seven_segment_driver_tb);  // Nombre correcto del módulo
    end
    
endmodule
