module control_fsm (
    input  logic clk,
    input  logic rst_n,

    input  logic [3:0] key_code,
    input  logic       key_valid,

    input  logic [9:0] number_in,
    input  logic       number_done,

    output logic [9:0] numA,
    output logic [9:0] numB,
    output logic       start_sum,
    output logic       enable_capture
);

    // DEFINICIÓN DEL ESTADO (DENTRO DEL MÓDULO)
    typedef enum logic [1:0] {
        INPUT_A,
        INPUT_B,
        COMPUTE
    } state_t;

    state_t state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= INPUT_A;
            numA <= 0;
            numB <= 0;
            start_sum <= 0;
            enable_capture <= 1;
        end else begin
            start_sum <= 0;

            case (state)

                INPUT_A: begin
                    enable_capture <= 1;

                    if (number_done)
                        numA <= number_in;

                    if (key_valid && key_code == 4'hA)
                        state <= INPUT_B;
                end

                INPUT_B: begin
                    enable_capture <= 1;

                    if (number_done) begin
                        numB <= number_in;
                        state <= COMPUTE;
                    end
                end

                COMPUTE: begin
                    enable_capture <= 0;
                    start_sum <= 1;
                    state <= INPUT_A;
                end

                default: state <= INPUT_A;

            endcase
        end
    end

endmodule