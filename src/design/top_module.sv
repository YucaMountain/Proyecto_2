module top (
    input  logic clk,
    input  logic rst_n,

    input  logic [3:0] rows,
    output logic [3:0] cols,

    output logic [6:0] seg,
    output logic [3:0] an
);

    //========================================
    // 🔹 Señales internas
    //========================================
    logic [3:0] key_code;
    logic key_valid;

    logic [9:0] number;
    logic number_done;

    logic [9:0] numA, numB;
    logic start_sum;
    logic enable_capture;

    logic [10:0] result;
    logic sum_done;

    //========================================
    // 🔹 1. Lector de teclado
    //========================================
    keypad_reader keypad (
        .clk(clk),
        .rst_n(rst_n),
        .rows(rows),
        .cols(cols),
        .key_code(key_code),
        .key_valid(key_valid)
    );

    //========================================
    // 🔹 2. Captura de números
    //========================================
    number_capture cap (
        .clk(clk),
        .rst_n(rst_n),
        .key_code(key_code),
        .key_valid(key_valid),
        .enable(enable_capture),
        .number(number),
        .done(number_done)
    );

    //========================================
    // 🔹 3. FSM de control
    //========================================
    control_fsm fsm (
        .clk(clk),
        .rst_n(rst_n),
        .key_code(key_code),
        .key_valid(key_valid),
        .number_in(number),
        .number_done(number_done),
        .numA(numA),
        .numB(numB),
        .start_sum(start_sum),
        .enable_capture(enable_capture)
    );

    //========================================
    // 🔹 4. Sumador
    //========================================
    sumador sumador_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start(start_sum),
        .A(numA),
        .B(numB),
        .result(result),
        .done(sum_done)
    );

    //========================================
    // 🔹 5. Display 7 segmentos
    //========================================
    seven_segment_driver display (
        .clk(clk),
        .rst_n(rst_n),
        .value(result),
        .seg(seg),
        .an(an)
    );

endmodule