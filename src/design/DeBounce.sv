//==============================================================================
// DeBounce - VERSIÓN CORREGIDA Y MEJORADA
//==============================================================================
module DeBounce (
    input  wire clk,
    input  wire n_reset,
    input  wire button_in,
    output reg  DB_out
);

    // Parámetro de debounce
    localparam integer DEBOUNCE_CYCLES = 100;

    // Cálculo automático del ancho del contador
    localparam integer COUNTER_WIDTH = $clog2(DEBOUNCE_CYCLES + 1);

    reg [COUNTER_WIDTH-1:0] counter;

    // Sincronización de entrada asíncrona
    reg sync_0, sync_1;

    // Estado estable previo
    reg stable_state;

    always @(posedge clk or negedge n_reset) begin
        if (!n_reset) begin
            sync_0       <= 1'b0;
            sync_1       <= 1'b0;
            counter      <= {COUNTER_WIDTH{1'b0}};
            stable_state <= 1'b0;
            DB_out       <= 1'b0;
        end else begin
            // Sincronizador de 2 etapas
            sync_0 <= button_in;
            sync_1 <= sync_0;

            // Si la entrada sincronizada cambió respecto al estado estable,
            // empieza o continúa el conteo
            if (sync_1 != stable_state) begin
                if (counter < DEBOUNCE_CYCLES) begin
                    counter <= counter + 1'b1;
                end else begin
                    stable_state <= sync_1;
                    DB_out       <= sync_1;
                    counter      <= {COUNTER_WIDTH{1'b0}};
                end
            end else begin
                // Si no hay cambio, reinicia contador
                counter <= {COUNTER_WIDTH{1'b0}};
            end
        end
    end

endmodule
