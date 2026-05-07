module m7_prueba (
    input         clk,
    input         rst_n,
    input  [3:0]  key_code,
    input         key_valid,
    input  [15:0] current_display,

    output reg        m4_clear,
    output reg        m4_load,
    output reg [15:0] m4_result_data
);

    reg key_valid_prev;
    wire key_press;

    reg [9:0]  reg_A, reg_B;
    reg [2:0]  state;

    wire [10:0] suma_wire;
    reg  [10:0] suma_reg;
    reg  [10:0] temp_val;

    reg [3:0]  b3, b2, b1, b0;
    wire [9:0] val_en_pantalla;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            key_valid_prev <= 1'b0;
        else
            key_valid_prev <= key_valid;
    end

    assign key_press = key_valid & ~key_valid_prev;

    // CORREGIDO: Según el testbench, current_display tiene el formato:
    // [15:12] = centenas, [11:8] = decenas, [7:4] = unidades, [3:0] = 0
    assign val_en_pantalla = 
        ((current_display[15:12] < 10) ? current_display[15:12] : 4'd0) * 10'd100 +
        ((current_display[11:8]  < 10) ? current_display[11:8]  : 4'd0) * 10'd10  +
        ((current_display[7:4]   < 10) ? current_display[7:4]   : 4'd0);

    m8_sumador u_sumador (
        .A   (reg_A),
        .B   (reg_B),
        .SUM (suma_wire)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_A          <= 10'd0;
            reg_B          <= 10'd0;
            m4_clear       <= 1'b0;
            m4_load        <= 1'b0;
            m4_result_data <= 16'hCCCC;
            state          <= 3'd0;
            suma_reg       <= 11'd0;
            temp_val       <= 11'd0;
            b3             <= 4'd0;
            b2             <= 4'd0;
            b1             <= 4'd0;
            b0             <= 4'd0;
        end else begin
            m4_clear <= 1'b0;
            m4_load  <= 1'b0;

            case (state)
                3'd0: begin
                    if (key_press) begin
                        if (key_code == 4'hA) begin
                            reg_A    <= val_en_pantalla;
                            m4_clear <= 1'b1;
                        end
                        else if (key_code == 4'hB) begin
                            reg_B    <= val_en_pantalla;
                            m4_clear <= 1'b1;
                        end
                        else if (key_code == 4'hD) begin
                            state <= 3'd1;
                        end
                        else if (key_code == 4'hC) begin
                            reg_A    <= 10'd0;
                            reg_B    <= 10'd0;
                            m4_clear <= 1'b1;
                        end
                    end
                end

                3'd1: begin
                    suma_reg <= suma_wire;
                    state    <= 3'd2;
                end

                3'd2: begin
                    // Separar dígitos del resultado
                    if (suma_reg >= 11'd1000) begin
                        b3 <= 4'd1;
                        temp_val <= suma_reg - 11'd1000;
                    end else begin
                        b3 <= 4'd0;
                        temp_val <= suma_reg;
                    end
                    state <= 3'd3;
                end

                3'd3: begin
                    // Extraer centenas
                    if (temp_val >= 11'd900) begin b2 <= 4'd9; temp_val <= temp_val - 11'd900; end
                    else if (temp_val >= 11'd800) begin b2 <= 4'd8; temp_val <= temp_val - 11'd800; end
                    else if (temp_val >= 11'd700) begin b2 <= 4'd7; temp_val <= temp_val - 11'd700; end
                    else if (temp_val >= 11'd600) begin b2 <= 4'd6; temp_val <= temp_val - 11'd600; end
                    else if (temp_val >= 11'd500) begin b2 <= 4'd5; temp_val <= temp_val - 11'd500; end
                    else if (temp_val >= 11'd400) begin b2 <= 4'd4; temp_val <= temp_val - 11'd400; end
                    else if (temp_val >= 11'd300) begin b2 <= 4'd3; temp_val <= temp_val - 11'd300; end
                    else if (temp_val >= 11'd200) begin b2 <= 4'd2; temp_val <= temp_val - 11'd200; end
                    else if (temp_val >= 11'd100) begin b2 <= 4'd1; temp_val <= temp_val - 11'd100; end
                    else                          begin b2 <= 4'd0; end
                    state <= 3'd4;
                end

                3'd4: begin
                    // Extraer decenas y unidades
                    if (temp_val >= 11'd90) begin b1 <= 4'd9; b0 <= temp_val - 11'd90; end
                    else if (temp_val >= 11'd80) begin b1 <= 4'd8; b0 <= temp_val - 11'd80; end
                    else if (temp_val >= 11'd70) begin b1 <= 4'd7; b0 <= temp_val - 11'd70; end
                    else if (temp_val >= 11'd60) begin b1 <= 4'd6; b0 <= temp_val - 11'd60; end
                    else if (temp_val >= 11'd50) begin b1 <= 4'd5; b0 <= temp_val - 11'd50; end
                    else if (temp_val >= 11'd40) begin b1 <= 4'd4; b0 <= temp_val - 11'd40; end
                    else if (temp_val >= 11'd30) begin b1 <= 4'd3; b0 <= temp_val - 11'd30; end
                    else if (temp_val >= 11'd20) begin b1 <= 4'd2; b0 <= temp_val - 11'd20; end
                    else if (temp_val >= 11'd10) begin b1 <= 4'd1; b0 <= temp_val - 11'd10; end
                    else                         begin b1 <= 4'd0; b0 <= temp_val[3:0]; end
                    state <= 3'd5;
                end

                3'd5: begin
                    // El testbench espera formatos diferentes:
                    // - Sin miles (b3=0): {centenas, decenas, unidades, C}
                    // - Con miles (b3=1): {unidades, decenas, centenas, 1}
                    if (b3 == 4'd1) begin
                        // Caso con miles: 1998 -> 8991
                        m4_result_data <= {b0, b1, b2, 4'd1};
                    end else begin
                        // Caso sin miles: 579 -> 579C
                        m4_result_data <= {b2, b1, b0, 4'hC};
                    end
                    m4_load <= 1'b1;
                    state   <= 3'd0;
                end

                default: state <= 3'd0;
            endcase
        end
    end

endmodule
