//===============================================================================
// Testbench Module for Simon Datapath
//===============================================================================
`timescale 1ns/100ps

`include "SimonDatapath.v"

// Print an error message (MSG) if value ONE is not equal
// to value TWO.
`define ASSERT_EQ(ONE, TWO, MSG)               \
	begin                                      \
		if ((ONE) !== (TWO)) begin             \
			$display("\t[FAILURE]:%s", (MSG)); \
			errors = errors + 1;               \
		end                                    \
	end #0

// Set the variable VAR to the value VALUE, printing a notification
// to the screen indicating the variable's update.
// The setting of the variable is preceeded and followed by
// a 1-timestep delay.
`define SET(VAR, VALUE) $display("Setting %s to %s...", "VAR", "VALUE"); #1; VAR = (VALUE); #1

// Cycle the clock up and then down, simulating
// a button press.
`define CLOCK $display("Pressing uclk..."); #1; clk = 1; #1; clk = 0; #1

module SimonDatapathTest;

	// External inputs
	reg clk = 0;
	reg level = 0;
	reg [3:0] pattern = 4'b0000;

	// Datapath Control Signals
	reg reset;
    reg scld;
    reg rcld;
    reg rcclr;
    reg srld;
    reg led_sel;

	// Datapath Outputs to Control
	wire is_legal;
    wire correct_pattern;
    wire is_last_element;

	// External Outputs
	wire [3:0] pattern_leds;

	// Error Counts
	reg [7:0] errors = 0;

	// LED Light Parameters
	localparam LED_MODE_INPUT    = 3'b001;
	localparam LED_MODE_PLAYBACK = 3'b010;
	localparam LED_MODE_REPEAT   = 3'b100;
	localparam LED_MODE_DONE     = 3'b111;

	// VCD Dump
	integer idx;
	initial begin
		$dumpfile("SimonDatapathTest.vcd");
		$dumpvars;
		for (idx = 0; idx < 64; idx = idx + 1) begin
			$dumpvars(0, dpath.mem.mem[idx]);
		end
	end

	// Simon Control Module
	SimonDatapath dpath(
		// External inputs
		.clk            (clk),
		.level          (level),
		.pattern        (pattern),

		// Datapath Control Signals
		.reset	        (reset),
        .scld           (scld),
        .rcld           (rcld),
        .rcclr          (rcclr),
        .srld           (srld), 
        .led_sel        (led_sel),
	
		// Datapath Outputs to Control
	    .is_legal       (is_legal),
        .correct_pattern(correct_pattern),
        .is_last_element(is_last_element),

		// External Outputs
        .pattern_leds   (pattern_leds)
	);

	// Main Test Logic
	initial begin
		// Case 1: Resetting the datapath to hard level
		// Input the values
		`SET(level, 1);
		`SET(reset, 1);
		`CLOCK;

		// Check values
		`ASSERT_EQ(is_legal, 1'd1, "is_legal was not set for hard!");
		`ASSERT_EQ(pattern_leds, 4'dx, "pattern_leds were not reset!");
		`ASSERT_EQ(correct_pattern, 1'dx, "correct_pattern was not reset!");
        `ASSERT_EQ(is_last_element, 1'dx, "is_last_element was not reset!");

		// Case 2: Checking input mode
		
		// Input the values
		`SET(reset, 0);
		`SET(pattern, 4'b1111);
		`SET(led_sel, 1);
		`SET(srld, 1);
		`SET(scld, 1);
		`SET(rcclr, 1);

		// Check values
		`ASSERT_EQ(is_legal, 1'd1, "is_legal should be TRUE!");
        `ASSERT_EQ(pattern_leds, 4'b1111, "pattern_leds were not set correctly!");
		`ASSERT_EQ(correct_pattern, 1'dx, "correct_pattern should not have changed!");
        `ASSERT_EQ(is_last_element, 1'dx, "is_last_element should not have changed!");

		// Case 3: Checking playback mode

		// Input the values
		`CLOCK;
		`SET(rcclr, 1);
		`SET(led_sel, 0);

		// Check values
		`ASSERT_EQ(is_legal, 1'd1, "is_legal should be TRUE!");
        `ASSERT_EQ(pattern_leds, 4'b1111, "pattern_leds were not set correctly!");
		`ASSERT_EQ(correct_pattern, 1'd1, "correct_pattern is true!");
        `ASSERT_EQ(is_last_element, 1'd1, "is_last_element is true!");

		// Case 4: Checking repeat mode

		// Input the values
		`CLOCK;
		`SET(rcclr, 1);
		`SET(led_sel, 1);
		`SET(pattern, 4'b0000);

		// Check values
		`ASSERT_EQ(is_legal, 1'd1, "is_legal should be TRUE!");
        `ASSERT_EQ(pattern_leds, 4'b0000, "pattern_leds were not set correctly!");
		`ASSERT_EQ(correct_pattern, 1'd0, "correct_pattern is not true!");
        `ASSERT_EQ(is_last_element, 1'd0, "is_last_element is not true!");

		// Case 5: Checking done mode

		// Input the values
		`CLOCK;
		`SET(rcclr, 1);
		`SET(led_sel, 0);

		// Check values
		`ASSERT_EQ(is_legal, 1'd1, "is_legal should be TRUE!");
        `ASSERT_EQ(pattern_leds, 4'b1111, "pattern_leds were not set correctly!");
		`ASSERT_EQ(correct_pattern, 1'd0, "correct_pattern is not true!");
        `ASSERT_EQ(is_last_element, 1'd1, "is_last_element is true!");

		// Case 6: Resetting the datapath to easy level
		// Input the values
		`SET(level, 0);
		`SET(reset, 1);
		`CLOCK;
		
		// Check values
		`ASSERT_EQ(is_legal, 1'd0, "is_legal was not set for easy!");
		`ASSERT_EQ(pattern_leds, 4'd0, "pattern_leds were not reset!");
		`ASSERT_EQ(correct_pattern, 1'd1, "correct_pattern was not reset!");
        `ASSERT_EQ(is_last_element, 1'd0, "is_last_element was not reset!");

		$display("\nTESTS COMPLETED (%d FAILURES)", errors);
		$finish;
	end

endmodule
