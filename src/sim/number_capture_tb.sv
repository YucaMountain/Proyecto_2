// Testbench for number_capture module
// Tests 1-digit, 2-digit, 3-digit entries, overflow, reset, and enable behavior

module number_capture_tb;

    // Parameters
    logic clk;
    logic rst_n;
    logic [3:0] key_code;
    logic key_valid;
    logic enable;
    logic [9:0] number;
    logic done;

    // Instantiate the module
    number_capture uut (
        .clk(clk),
        .rst_n(rst_n),
        .key_code(key_code),
        .key_valid(key_valid),
        .enable(enable),
        .number(number),
        .done(done)
    );

    // Clock generation: 10ns period (100 MHz)
    always #5 clk = ~clk;

    // Test procedure
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        key_code = 0;
        key_valid = 0;
        enable = 0;
        
        // Reset the module
        @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        
        // Test 1: Enable off - should not capture keys
        $display("Test 1: Enable = 0, keys should be ignored");
        enable = 0;
        send_key(4'd5);
        send_key(4'd2);
        check_number(0);
        check_not_done();
        
        // Test 2: Single digit entry
        $display("Test 2: Single digit entry");
        enable = 1;
        send_key(4'd7);
        check_number(0);
        check_not_done();
        
        // Test 3: Two digit entry
        $display("Test 3: Two digit entry (should not output yet)");
        send_key(4'd3);
        check_number(0);  // Still no output until 3 digits
        check_not_done();
        
        // Test 4: Three digit entry (should output)
        $display("Test 4: Three digit entry (should output 73x)");
        send_key(4'd8);
        // With digit_count=2 edge condition, number = (prev*10) + key
        // Previous temp_number = 73, number = 730 + 8 = 738
        #10;
        check_number(738);
        check_done();
        
        // Test 5: Extra key after done - should be ignored
        $display("Test 5: Extra key after done");
        send_key(4'd1);
        #20;
        check_number(738);  // Should remain 738
        check_done_cleared(); // Done should clear after one cycle? Check behavior
        
        // Test 6: Reset during operation
        $display("Test 6: Reset during operation");
        enable = 1;
        send_key(4'd4);
        send_key(4'd5);
        @(posedge clk);
        rst_n = 0;
        @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        check_number(0);
        check_not_done();
        
        // Test 7: Enable toggling mid-entry
        $display("Test 7: Enable toggling mid-entry");
        enable = 1;
        send_key(4'd9);
        send_key(4'd2);
        enable = 0;
        send_key(4'd5);  // Should be ignored
        #10;
        check_number(0);
        check_not_done();
        
        // Test 8: Another full sequence
        $display("Test 8: Another full sequence");
        enable = 1;
        send_key(4'd1);
        send_key(4'd0);
        send_key(4'd5);
        #10;
        check_number(105);
        check_done();
        
        // Test 9: Overflow protection
        $display("Test 9: Overflow protection (numbers > 999)");
        enable = 1;
        send_key(4'd9);
        send_key(4'd9);
        send_key(4'd9);
        #10;
        check_number(999);
        send_key(4'd5);  // Should be ignored
        #10;
        check_number(999);
        
        // Test 10: Zero handling
        $display("Test 10: Zero handling");
        enable = 1;
        send_key(4'd0);
        send_key(4'd0);
        send_key(4'd5);
        #10;
        check_number(5);
        
        $display("All tests completed successfully!");
        $finish;
    end

    // Helper task to send a key
    task send_key(input [3:0] key);
        @(posedge clk);
        key_code = key;
        key_valid = 1;
        @(posedge clk);
        key_valid = 0;
        key_code = 0;
    endtask

    // Helper task to check number output
    task check_number(input [9:0] expected);
        #2;  // Small delay for signal propagation
        if (number !== expected) begin
            $display("ERROR: Expected number = %0d, got %0d", expected, number);
            $finish;
        end else begin
            $display("  Number = %0d OK", number);
        end
    endtask

    // Helper task to check done signal
    task check_done();
        #2;
        if (done !== 1) begin
            $display("ERROR: Expected done = 1, got %0d", done);
            $finish;
        end else begin
            $display("  Done = 1 OK");
        end
    endtask

    // Helper task to check done is 0
    task check_not_done();
        #2;
        if (done !== 0) begin
            $display("ERROR: Expected done = 0, got %0d", done);
            $finish;
        end else begin
            $display("  Done = 0 OK");
        end
    endtask

    // Check that done clears after one cycle
    task check_done_cleared();
        // Wait a few cycles
        repeat(3) @(posedge clk);
        if (done !== 0) begin
            $display("ERROR: Expected done to clear, got %0d", done);
            $finish;
        end
    endtask

endmodule