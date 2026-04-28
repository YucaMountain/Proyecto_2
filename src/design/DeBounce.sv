//==============================================================================
// DeBounce - VERSIÓN CORREGIDA Y PROBADA
//==============================================================================
module DeBounce (
    input  wire clk,
    input  wire n_reset,
    input  wire button_in,
    output reg  DB_out
);
    
    // Parámetros (ajustados para simulación rápida)
    localparam DEBOUNCE_CYCLES = 100;  // 100 ciclos para simulación
    // Para hardware real usar: 250000 (10ms @ 50MHz)
    
    reg [16:0] counter;
    reg button_stable;
    reg prev_state;
    
    always @(posedge clk or negedge n_reset) begin
        if (!n_reset) begin
            counter <= 0;
            DB_out <= 0;
            prev_state <= 0;
        end else begin
            prev_state <= button_in;
            
            // Si cambió la entrada, reiniciar contador
            if (button_in != prev_state) begin
                counter <= 0;
            end
            // Si es estable y no ha cambiado
            else if (counter < DEBOUNCE_CYCLES) begin
                counter <= counter + 1;
            end
            // Si pasó el tiempo de debounce, actualizar salida
            else begin
                DB_out <= button_in;
            end
        end
    end
    
endmodule