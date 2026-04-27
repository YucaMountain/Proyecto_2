module seven_segment_driver (
    input  logic clk,
    input  logic rst_n,

    input  logic [10:0] value,   // número a mostrar (0–1998)

    output logic [6:0] seg,      // segmentos (a–g)
    output logic [3:0] an        // activación de displays
);

    //========================================
    // 🔹 1. Conversión binario → BCD
    //========================================
    logic [3:0] thousands, hundreds, tens, ones;

    always_comb begin
        int temp;
        temp = value;

        thousands = temp / 1000;
        temp = temp % 1000;

        hundreds = temp / 100;
        temp = temp % 100;

        tens = temp / 10;
        ones = temp % 10;
    end

    //========================================
    // 🔹 2. Multiplexación
    //========================================
    logic [1:0] digit_sel;
    logic [3:0] current_digit;

    // divisor de frecuencia (para multiplexar)
    logic [15:0] counter;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            counter <= 0;
        else
            counter <= counter + 1;
    end

    assign digit_sel = counter[15:14]; // cambia rápido

    always_comb begin
        case (digit_sel)
            2'b00: begin
                an = 4'b1110;
                current_digit = ones;
            end
            2'b01: begin
                an = 4'b1101;
                current_digit = tens;
            end
            2'b10: begin
                an = 4'b1011;
                current_digit = hundreds;
            end
            2'b11: begin
                an = 4'b0111;
                current_digit = thousands;
            end
        endcase
    end

    //========================================
    // 🔹 3. Decodificador 7 segmentos
    //========================================
    always_comb begin
        case (current_digit)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            default: seg = 7'b1111111;
        endcase
    end

endmodule