module top_module (
    input  logic clk,       // Reloj 27 MHz de la placa
    input  logic rst_n,     // Botón de reset físico
    input  logic [3:0] rows,// Teclado: Filas
    output logic [3:0] cols,// Teclado: Columnas
    output logic [6:0] seg, // Display: Segmentos
    output logic [3:0] an   // Display: Ánodos/Transistores
);

    // CABLES INTERNOS (Señales de interconexión)
    
    logic clk_1khz;
    logic [3:0] key_code_wire;
    logic key_valid_wire;
    
    // Cable que lleva la imagen de la pantalla (Va de m4 hacia m6 y m7)
    logic [15:0] display_data_wire;

    // Cables NUEVOS: La comunicación privada de m7 hacia m4
    logic        m7_to_m4_clear; // Señal de borrado
    logic        m7_to_m4_load;  // Señal de cargar resultado
    logic [15:0] m7_to_m4_data;  // El número del resultado de la suma

    
    // 1. DIVISOR DE RELOJ
    m1_clk_divider u_clk_div (
        .clk_in  (clk),
        .rst_n   (rst_n),
        .clk_out (clk_1khz)
    );

    
    // 2. LECTOR DE TECLADO
    m3_keypad_reader u_keypad (
        .clk       (clk_1khz),
        .rst_n     (rst_n),
        .rows      (rows),
        .cols      (cols),
        .key_code  (key_code_wire),
        .key_valid (key_valid_wire)
    );

    
    // 3. CONTROLADOR DE PANTALLA
    m4_display_controller u_controller (
        .clk          (clk_1khz),
        .rst_n        (rst_n),
        .key_code     (key_code_wire),
        .key_valid    (key_valid_wire),
        
        // Entradas de control que vienen del m7
        .force_reset  (m7_to_m4_clear), 
        .force_load   (m7_to_m4_load),  
        .data_to_load (m7_to_m4_data),  
        
        // Salida hacia el display
        .display_data (display_data_wire)
    );

    
    // 4. CALCULADORA (El Cerebro)
    m7_calculadora u_calculadora (
        .clk             (clk_1khz),
        .rst_n           (rst_n),
        .key_code        (key_code_wire),
        .key_valid       (key_valid_wire),
        
        // "Mira" lo que hay en el cable del display
        .current_display (display_data_wire), 
        
        // Envía órdenes por los cables hacia el m4
        .m4_clear        (m7_to_m4_clear),
        .m4_load         (m7_to_m4_load),
        .m4_result_data  (m7_to_m4_data)
    );

    // 5. DRIVER FÍSICO DEL DISPLAY (Muestra lo que le diga el controlador)
    m6_seven_segment_driver u_display (
        .clk      (clk_1khz),
        .rst_n    (rst_n),
        .hex_data (display_data_wire),
        .seg      (seg),
        .an       (an)
    );

endmodule