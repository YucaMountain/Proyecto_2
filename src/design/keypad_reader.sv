module keypad_reader (
    input  logic clk,
    input  logic rst_n,
    input  logic [3:0] rows,
    output logic [3:0] cols,
    output logic [3:0] key_code,
    output logic       key_valid
);

    //==================================================
    // Parámetros
    //==================================================
    localparam integer SCAN_DELAY = 10000;
    localparam integer COUNTER_WIDTH = $clog2(SCAN_DELAY);

    //==================================================
    // Señales internas
    //==================================================
    logic [3:0] rows_db;
    logic [1:0] col_index;
    logic [COUNTER_WIDTH-1:0] scan_counter;

    logic key_pressed;
    logic key_pressed_prev;
    logic valid_row;
    logic [3:0] key_code_comb;

    //==================================================
    // 1. Debounce en filas
    //==================================================
    DeBounce db0 (.clk(clk), .n_reset(rst_n), .button_in(rows[0]), .DB_out(rows_db[0]));
    DeBounce db1 (.clk(clk), .n_reset(rst_n), .button_in(rows[1]), .DB_out(rows_db[1]));
    DeBounce db2 (.clk(clk), .n_reset(rst_n), .button_in(rows[2]), .DB_out(rows_db[2]));
    DeBounce db3 (.clk(clk), .n_reset(rst_n), .button_in(rows[3]), .DB_out(rows_db[3]));

    //==================================================
    // 2. Escaneo de columnas
    //==================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            scan_counter <= '0;
            col_index    <= 2'd0;
        end else begin
            if (scan_counter >= SCAN_DELAY-1) begin
                scan_counter <= '0;
                col_index    <= col_index + 1'b1;
            end else begin
                scan_counter <= scan_counter + 1'b1;
            end
        end
    end

    always_comb begin
        cols = 4'b1111;
        cols[col_index] = 1'b0;
    end

    //==================================================
    // 3. Validación de fila
    // Solo una fila activa es válida
    //==================================================
    always_comb begin
        case (rows_db)
            4'b0001,
            4'b0010,
            4'b0100,
            4'b1000: valid_row = 1'b1;
            default: valid_row = 1'b0;
        endcase
    end

    assign key_pressed = valid_row;

    //==================================================
    // 4. Codificación de tecla
    //==================================================
    always_comb begin
        key_code_comb = 4'h0;

        case ({rows_db, col_index})
            6'b0001_00: key_code_comb = 4'h1;
            6'b0010_00: key_code_comb = 4'h4;
            6'b0100_00: key_code_comb = 4'h7;
            6'b1000_00: key_code_comb = 4'hE;

            6'b0001_01: key_code_comb = 4'h2;
            6'b0010_01: key_code_comb = 4'h5;
            6'b0100_01: key_code_comb = 4'h8;
            6'b1000_01: key_code_comb = 4'h0;

            6'b0001_10: key_code_comb = 4'h3;
            6'b0010_10: key_code_comb = 4'h6;
            6'b0100_10: key_code_comb = 4'h9;
            6'b1000_10: key_code_comb = 4'hF;

            6'b0001_11: key_code_comb = 4'hA;
            6'b0010_11: key_code_comb = 4'hB;
            6'b0100_11: key_code_comb = 4'hC;
            6'b1000_11: key_code_comb = 4'hD;

            default:    key_code_comb = 4'h0;
        endcase
    end

    //==================================================
    // 5. Generación de pulso key_valid
    //==================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            key_pressed_prev <= 1'b0;
            key_valid        <= 1'b0;
            key_code         <= 4'd0;
        end else begin
            key_pressed_prev <= key_pressed;
            key_valid        <= key_pressed && !key_pressed_prev;

            if (key_pressed && !key_pressed_prev)
                key_code <= key_code_comb;
        end
    end

endmodule
