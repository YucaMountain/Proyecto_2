module number_capture (
    input  logic clk,
    input  logic rst_n,

    input  logic [3:0] key_code,
    input  logic       key_valid,

    input  logic       enable,

    output logic [9:0] number,
    output logic       done
);

    logic [1:0] digit_count;
    logic [9:0] temp_number;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            temp_number <= 10'd0;
            number      <= 10'd0;
            digit_count <= 2'd0;
            done        <= 1'b0;
        end else begin
            done <= 1'b0;

            // Si la FSM deshabilita captura, reinicia la captura actual
            if (!enable) begin
                temp_number <= 10'd0;
                digit_count <= 2'd0;
            end
            // Solo acepta teclas numéricas 0-9
            else if (key_valid && key_code <= 4'd9) begin
                if (digit_count < 3) begin
                    temp_number <= (temp_number * 10) + key_code;
                    digit_count <= digit_count + 1'b1;

                    // Al llegar al tercer dígito, entrega número y done
                    if (digit_count == 2) begin
                        number      <= (temp_number * 10) + key_code;
                        done        <= 1'b1;
                        temp_number <= 10'd0;
                        digit_count <= 2'd0;
                    end
                end
            end
        end
    end

endmodule
