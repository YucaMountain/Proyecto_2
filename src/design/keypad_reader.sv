module keypad_reader (
    input  logic clk,
    input  logic rst_n,

    input  logic [3:0] rows,   // entradas del teclado
    output logic [3:0] cols,   // salidas (escaneo columnas)

    output logic [3:0] key_code,
    output logic       key_valid
);

    //========================================
    // 🔹 1. Debounce en cada fila
    //========================================
    logic [3:0] rows_db;

    DeBounce db0 (.clk(clk), .n_reset(rst_n), .button_in(rows[0]), .DB_out(rows_db[0]));
    DeBounce db1 (.clk(clk), .n_reset(rst_n), .button_in(rows[1]), .DB_out(rows_db[1]));
    DeBounce db2 (.clk(clk), .n_reset(rst_n), .button_in(rows[2]), .DB_out(rows_db[2]));
    DeBounce db3 (.clk(clk), .n_reset(rst_n), .button_in(rows[3]), .DB_out(rows_db[3]));

    //========================================
    // 🔹 2. Escaneo de columnas
    //========================================
    logic [1:0] col_index;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            col_index <= 0;
        else
            col_index <= col_index + 1;
    end

    always_comb begin
        cols = 4'b1111;
        cols[col_index] = 1'b0; // activa una columna
    end

    //========================================
    // 🔹 3. Detección de tecla
    //========================================
    logic key_pressed;

    assign key_pressed = (rows_db != 4'b0000);

    //========================================
    // 🔹 4. Codificación fila-columna
    //========================================
    always_comb begin
        key_code = 4'h0;

        if (key_pressed) begin
            case ({rows_db, col_index})

                6'b0001_00: key_code = 4'h1;
                6'b0010_00: key_code = 4'h4;
                6'b0100_00: key_code = 4'h7;
                6'b1000_00: key_code = 4'hE;

                6'b0001_01: key_code = 4'h2;
                6'b0010_01: key_code = 4'h5;
                6'b0100_01: key_code = 4'h8;
                6'b1000_01: key_code = 4'h0;

                6'b0001_10: key_code = 4'h3;
                6'b0010_10: key_code = 4'h6;
                6'b0100_10: key_code = 4'h9;
                6'b1000_10: key_code = 4'hF;

                6'b0001_11: key_code = 4'hA;
                6'b0010_11: key_code = 4'hB;
                6'b0100_11: key_code = 4'hC;
                6'b1000_11: key_code = 4'hD;

                default: key_code = 4'h0;
            endcase
        end
    end

    //========================================
    // 🔹 5. Señal de tecla válida
    //========================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            key_valid <= 0;
        else
            key_valid <= key_pressed;
    end

endmodule