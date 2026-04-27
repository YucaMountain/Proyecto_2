module sumador (
    input  logic clk,
    input  logic rst_n,
    input  logic start,

    input  logic [9:0] A,
    input  logic [9:0] B,

    output logic [10:0] result, // puede crecer (999+999=1998)
    output logic done
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result <= 0;
            done   <= 0;
        end else begin
            done <= 0;

            if (start) begin
                result <= A + B;
                done   <= 1;
            end
        end
    end

endmodule