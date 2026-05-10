// Testbench for sumador module
// Tests addition with various values, overflow, reset, and start behavior

module sumador_tb;

    // Parameters
    logic clk;
    logic rst_n;
    logic start;
    logic [9:0] A;
    logic [9:0] B;
    logic [10:0] result;
    logic done;

    // Instantiate the module
    sumador uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .A(A),
        .B(B),
        .result(result),
        .done(done)
    );

    // Clock generation: 10ns period (100 MHz)
    always #5 clk = ~clk;

    // Test procedure
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        start = 0;
        A = 0;
        B = 0;
        
        // Reset the module
        @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        
        // Test 1: Basic addition (small numbers)
        $display("Test 1: 5 + 3 = 8");
        start_addition(10'd5, 10'd3);
        check_result(11'd8);
        check_done();
        
        // Test 2: Medium numbers
        $display("Test 2: 100 + 250 = 350");
        start_addition(10'd100, 10'd250);
        check_result(11'd350);
        check_done();
        
        // Test 3: Maximum values (no overflow)
        $display("Test 3: 999 + 0 = 999");
        start_addition(10'd999, 10'd0);
        check_result(11'd999);
        check_done();
        
        // Test 4: Overflow case (result needs 11 bits)
        $display("Test 4: 999 + 999 = 1998 (overflow test)");
        start_addition(10'd999, 10'd999);
        check_result(11'd1998);
        check_done();
        
        // Test 5: Another overflow case
        $display("Test 5: 500 + 500 = 1000");
        start_addition(10'd500, 10'd500);
        check_result(11'd1000);
        check_done();
        
        // Test 6: Zero addition
        $display("Test 6: 0 + 0 = 0");
        start_addition(10'd0, 10'd0);
        check_result(11'd0);
        check_done();
        
        // Test 7: Boundary test (just below max)
        $display("Test 7: 999 + 998 = 1997");
        start_addition(10'd999, 10'd998);
        check_result(11'd1997);
        check_done();
        
        // Test 8: Start signal timing (should only update when start=1)
        $display("Test 8: Verify start edge-triggered behavior");
        A = 10'd123;
        B = 10'd456;
        @(posedge clk);
        #2;
        // Without start, result should remain unchanged
        if (result !== 11'd1997) begin
            $display("ERROR: Result changed without start! Got %0d", result);
            $finish;
        end else begin
            $display("  Result unchanged without start: OK");
        end
        
        // Now assert start
        start = 1;
        @(posedge clk);
        start = 0;
        check_result(11'd579);  // 123 + 456 = 579
        check_done();
        
        // Test 9: Multiple starts (should update each time)
        $display("Test 9: Multiple start pulses");
        start_addition(10'd50, 10'd75);
        check_result(11'd125);
        check_done();
        
        start_addition(10'd200, 10'd300);
        check_result(11'd500);
        check_done();
        
        // Test 10: Reset during operation
        $display("Test 10: Reset test");
        start_addition(10'd100, 10'd200);
        @(posedge clk);
        rst_n = 0;
        @(posedge clk);
        if (result !== 0 || done !== 0) begin
            $display("ERROR: Reset failed - result=%0d, done=%0d", result, done);
            $finish;
        end else begin
            $display("  Reset successful: result=0, done=0");
        end
        
        rst_n = 1;
        @(posedge clk);
        
        // Test 11: Verify done clears after one cycle
        $display("Test 11: Done pulse width verification");
        start_addition(10'd10, 10'd20);
        #2;
        if (done !== 1) begin
            $display("ERROR: Done not asserted after start");
            $finish;
        end
        @(posedge clk);
        #2;
        if (done !== 0) begin
            $display("ERROR: Done did not clear after one cycle");
            $finish;
        end else begin
            $display("  Done pulse width correct: OK");
        end
        
        // Test 12: Consecutive additions without reset
        $display("Test 12: Consecutive additions");
        start_addition(10'd1, 10'd2);
        check_result(11'd3);
        start_addition(10'd10, 10'd20);
        check_result(11'd30);
        start_addition(10'd100, 10'd200);
        check_result(11'd300);
        
        $display("All tests completed successfully!");
        $finish;
    end

    // Helper task to start an addition
    task start_addition(input [9:0] a_val, input [9:0] b_val);
        @(posedge clk);
        A = a_val;
        B = b_val;
        start = 1;
        @(posedge clk);
        start = 0;
        #2;  // Small delay for signal stability
    endtask

    // Helper task to check result
    task check_result(input [10:0] expected);
        if (result !== expected) begin
            $display("ERROR: Expected result = %0d, got %0d", expected, result);
            $finish;
        end else begin
            $display("  Result = %0d OK", result);
        end
    endtask

    // Helper task to check done signal
    task check_done();
        if (done !== 1) begin
            $display("ERROR: Expected done = 1, got %0d", done);
            $finish;
        end else begin
            $display("  Done = 1 OK");
        end
    endtask

endmodule
