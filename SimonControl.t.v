//===============================================================================
// Testbench Module for Simon Controller
//===============================================================================
`timescale 1ns/100ps

`include "SimonControl.v"

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

module SimonControlTest;

	// External inputs
	reg clk = 0;
	reg rst = 0;

	// Datapath Inputs
    reg is_legal;
    reg correct_pattern;
    reg is_last_element;

	// Datapath Control Outputs
    wire scld;
    wire rcld;
    wire rcclr;
    wire srld;
    wire led_sel;

	// External Outputs
    wire [2:0] mode_leds;

	// Error Counts
	reg [7:0] errors = 0;

	// LED Light Parameters
	localparam LED_MODE_INPUT    = 3'b001;
	localparam LED_MODE_PLAYBACK = 3'b010;
	localparam LED_MODE_REPEAT   = 3'b100;
	localparam LED_MODE_DONE     = 3'b111;

	// VCD Dump
	initial begin
		$dumpfile("SimonControlTest.vcd");
		$dumpvars;
	end

	// Simon Control Module
	SimonControl ctrl(
		// External inputs
		.clk (clk),
		.rst (rst),

		// Datapath Inputs
		.is_legal (is_legal),
		.correct_pattern (correct_pattern),
		.is_last_element (is_last_element),

		// Datapath Control Outputs
		.scld (scld), 
		.rcld (rcld),
		.rcclr (rcclr),
		.srld (srld), 
		.led_sel (led_sel),

		// External Outputs
		.mode_leds (mode_leds)
	);

	// Main Test Logic
	initial begin
		// Case 1: Resetting the datapath to hard level
		// Input the values
		`SET(rst, 1);
		`SET(is_legal, 1);
		
		// Check the values
		`ASSERT_EQ(scld, 1'd0, "scld was not reset!");
		`ASSERT_EQ(rcld, 1'd0, "rcld were not reset!");
		`ASSERT_EQ(rcclr, 1'd0, "rcclr was not reset!");
        `ASSERT_EQ(srld, 1'd0, "srld was not reset!");
		`ASSERT_EQ(led_sel, 1'd0, "led_sel was not reset!");
		`ASSERT_EQ(mode_leds, 3'dx, "mode_leds were not reset!");

		// Case 2: Checking input mode
		// Input the values
		`CLOCK;
		`SET(rst, 0);
		`SET(is_legal, 1);
		`SET(correct_pattern, 0);
		`SET(is_last_element, 0);

		// Check the values
		`ASSERT_EQ(scld, 1'd1, "scld should be TRUE!");
		`ASSERT_EQ(rcld, 1'd0, "rcld should not have changed!");
		`ASSERT_EQ(rcclr, 1'd1, "rcclr should be TRUE!");
        `ASSERT_EQ(srld, 1'd1, "srld should be TRUE!");
		`ASSERT_EQ(led_sel, 1'd1, "led_sel should be TRUE!");
		`ASSERT_EQ(mode_leds, 3'b001, "mode_leds should be 001!");
		
		// Case 3: Checking playback mode
		// Input the values
		`CLOCK;
		`SET(is_legal, 1);
		`SET(correct_pattern, 1);
		`SET(is_last_element, 1);

		// Check the values
		`ASSERT_EQ(scld, 1'd0, "scld should be FALSE!");
		`ASSERT_EQ(rcld, 1'd0, "rcld should be FALSE!");
		`ASSERT_EQ(rcclr, 1'd1, "rcclr should be TRUE!");
        `ASSERT_EQ(srld, 1'd0, "srld should be FALSE!");
		`ASSERT_EQ(led_sel, 1'd0, "led_sel should be FALSE!");
		`ASSERT_EQ(mode_leds, 3'b010, "mode_leds should be 010!");

		// Case 4: Checking repeat mode
		// Input the values
		`CLOCK;
		`SET(is_legal, 1);
		`SET(correct_pattern, 0);
		`SET(is_last_element, 0);

		// Check the values
		`ASSERT_EQ(scld, 1'd0, "scld should be FALSE!");
		`ASSERT_EQ(rcld, 1'd0, "rcld should be FALSE!");
		`ASSERT_EQ(rcclr, 1'd1, "rcclr should be TRUE!");
        `ASSERT_EQ(srld, 1'd0, "srld should be FALSE!");
		`ASSERT_EQ(led_sel, 1'd1, "led_sel should be TRUE!");
		`ASSERT_EQ(mode_leds, 3'b100, "mode_leds should be 100!");

		// Case 5: Checking done mode
		// Input the values
		`CLOCK;
		`SET(is_legal, 1);
		`SET(correct_pattern, 0);
		`SET(is_last_element, 1);

		// Check the values
		`ASSERT_EQ(scld, 1'd0, "scld should be FALSE!");
		`ASSERT_EQ(rcld, 1'd0, "rcld should be FALSE!");
		`ASSERT_EQ(rcclr, 1'd1, "rcclr should be TRUE!");
        `ASSERT_EQ(srld, 1'd0, "srld should be FALSE!");
		`ASSERT_EQ(led_sel, 1'd0, "led_sel should be FALSE!");
		`ASSERT_EQ(mode_leds, 3'b111, "mode_leds should be 111!");

		// Case 6: Resetting the datapath to easy level
		// Input the values
		`CLOCK;
		`SET(rst, 1);
		`SET(is_legal, 0);

		// Check the values
		`ASSERT_EQ(scld, 1'd0, "scld should be FALSE!");
		`ASSERT_EQ(rcld, 1'd0, "rcld should be FALSE!");
		`ASSERT_EQ(rcclr, 1'd1, "rcclr should be TRUE!");
        `ASSERT_EQ(srld, 1'd0, "srld should be FALSE!");
		`ASSERT_EQ(led_sel, 1'd0, "led_sel should be FALSE!");
		`ASSERT_EQ(mode_leds, 3'b111, "mode_leds should be 111!");

		$display("\nTESTS COMPLETED (%d FAILURES)", errors);
		$finish;
	end

endmodule
