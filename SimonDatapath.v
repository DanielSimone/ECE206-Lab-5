//==============================================================================
// Datapath for Simon Project
//==============================================================================

`include "Memory.v"

module SimonDatapath(
	// External Inputs
	input        clk,           // Clock
	input        level,         // Switch for setting level
	input  [3:0] pattern,       // Switches for creating pattern

	// Datapath Control Signals
    input         reset,
    input         scld, 
    input         rcld,
    input         rcclr,
    input         srld, 
    input         led_sel,

	// Datapath Outputs to Control
    output        reg is_legal,
    output        correct_pattern,
    output        is_last_element,

	// External Outputs
    output reg [3:0] pattern_leds // LED outputs for pattern
);

	// Declare Local Vars Here
    wire one_one, last_pos;

    // Additional Registers
    reg [5:0] seq_count;
    reg [5:0] reg_count; 
    reg hard; 

	// Wires connecting to registers
    wire [3:0] mem_out; 

    // Continous Assignment Statements 
    // Checking if the entered pattern is correct 
    assign correct_pattern = (pattern == mem_out);

    // Compare the register address with last sequence position
    assign last_pos = seq_count - 1;
    assign is_last_element = (last_pos == reg_count);

    // Calculate the number of 1's in the pattern
    wire [2:0] ones_counter;
    assign ones_counter = pattern[3] + pattern[2] + pattern[1] + pattern[0];
    assign one_one = (ones_counter == 1);

	//----------------------------------------------------------------------
	// Internal Logic -- Manipulate Registers, ALU's, Memories Local to
	// the Datapath
	//----------------------------------------------------------------------

	always @(posedge clk) begin
        // Sequential Internal Logic Here
        // Increment reg_count 
        if (rcld)
            reg_count <= reg_count + 1;
        // Increment seq_count 
        if (scld)
            seq_count <= seq_count + 1; 
        // Clear reg_count
        if (rcclr)
            reg_count <= 6'd0; 

        // Resetting Other Registers
        if (reset) begin 
            seq_count <= 6'd0; 
            hard <= level; 
        end
	end

	// 64-entry 4-bit memory (from Memory.v) -- Fill in Ports!
	Memory mem(
        .clk     (clk),
        .rst     (reset),
        .r_addr  (reg_count),
        .w_addr  (seq_count),
        .w_data  (pattern),
        .w_en    (srld),
        .r_data  (mem_out)
	);

	//----------------------------------------------------------------------
	// Output Logic -- Set Datapath Outputs
	//----------------------------------------------------------------------

	always @( * ) begin
        // Initial Conditions
        pattern_leds = mem_out;

        //Assigning the pattern leds output
        if (led_sel) pattern_leds = pattern;

        // Computing is_legal 
        if (hard) is_legal = hard;
        else is_legal = one_one;
	end

endmodule
