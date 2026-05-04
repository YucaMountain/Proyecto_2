module m4_display_controller (
    input  logic clk,
    input  logic rst_n,
    input  logic [3:0] key_code,
    input  logic       key_valid,
    
    input  logic        force_reset, 
    input  logic        force_load,
    input  logic [15:0] data_to_load,

    output logic [15:0] display_data 
);

    logic [1:0] digit_count;

    always_ff @(posedge clk or negedge rst_n) begin
        // 1. Reset Asíncrono (Botón físico, máxima prioridad)
        if (!rst_n) begin
            display_data <= 16'hCCCC; 
            digit_count  <= 2'b00;
        end 
        // 2. Reset Síncrono (Orden enviada por el m7)
        else if (force_reset) begin
            display_data <= 16'hCCCC; 
            digit_count  <= 2'b00;
        end 
        // 3. Carga de resultados (Orden enviada por el m7)
        else if (force_load) begin
            display_data <= data_to_load;
            digit_count  <= 2'b11; 
        end 
        // 4. Comportamiento normal del teclado
        else if (key_valid) begin
            if (key_code < 4'hA) begin
                if (digit_count < 3) begin
                    display_data <= {key_code, display_data[15:4]};
                    digit_count  <= digit_count + 1'b1;
                end
            end else if (key_code == 4'hC) begin
                 display_data <= 16'hCCCC;
                 digit_count  <= 2'b00;
            end
        end
    end
endmodule