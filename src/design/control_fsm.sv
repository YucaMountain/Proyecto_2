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

    typedef enum logic [1:0] {
        INPUT_A,
        INPUT_B,
        COMPUTE
    } state_t;

    state_t state;

    // Mantener COMPUTE varios ciclos para que el testbench lo vea
    logic [3:0] compute_count;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state          <= INPUT_A;
            numA           <= 10'd0;
            numB           <= 10'd0;
            start_sum      <= 1'b0;
            enable_capture <= 1'b1;
            compute_count  <= 4'd0;
        end else begin
            case (state)

                INPUT_A: begin
                    start_sum      <= 1'b0;
                    enable_capture <= 1'b1;
                    compute_count  <= 4'd0;

                    if (number_done)
                        numA <= number_in;

                    if (key_valid && key_code == 4'hA)
                        state <= INPUT_B;
                end

                INPUT_B: begin
                    start_sum      <= 1'b0;
                    enable_capture <= 1'b1;
                    compute_count  <= 4'd0;

                    if (number_done) begin
                        numB  <= number_in;
                        state <= COMPUTE;
                    end
                end

                COMPUTE: begin
                    start_sum      <= 1'b1;
                    enable_capture <= 1'b0;

                    if (compute_count < 4'd7) begin
                        compute_count <= compute_count + 1'b1;
                    end else begin
                        compute_count  <= 4'd0;
                        start_sum      <= 1'b0;
                        enable_capture <= 1'b1;
                        state          <= INPUT_A;
                    end
                end

                default: begin
                    state          <= INPUT_A;
                    numA           <= 10'd0;
                    numB           <= 10'd0;
                    start_sum      <= 1'b0;
                    enable_capture <= 1'b1;
                    compute_count  <= 4'd0;
                end

            endcase
        end
    end

endmodule
