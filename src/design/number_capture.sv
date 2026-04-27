module number_capture (
    input  logic clk,
    input  logic rst_n,

    input  logic [3:0] key_code,
    input  logic       key_valid,

    input  logic       enable,      // NUEVO (controlado por FSM)

    output logic [9:0] number,
    output logic       done
);

    logic [1:0] digit_count;
    logic [9:0] temp_number;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            temp_number <= 0;
            digit_count <= 0;
            done <= 0;
        end else begin
            done <= 0;

            if (enable && key_valid && key_code <= 9) begin
                
                if (digit_count < 3) begin
                    temp_number <= (temp_number * 10) + key_code;
                    digit_count <= digit_count + 1;

                    if (digit_count == 2) begin
                        number <= (temp_number * 10) + key_code;
                        done <= 1;
                    end
                end
                // si ya hay 3 → ignora nuevas teclas
            end
        end
    end

endmodule