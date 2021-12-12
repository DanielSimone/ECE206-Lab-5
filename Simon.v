//==============================================================================
// Simon Module for Simon Project
//==============================================================================

`include "SimonControl.v"
`include "SimonDatapath.v"

module Simon(
	input        pclk,
	input        rst,
	input        level,
	input  [3:0] pattern,
	output [3:0] pattern_leds,
	output [2:0] mode_leds
);

	// Declare local connections here
    wire seq_countld;
    wire seq_regld;
    wire reg_countld;
    wire reg_countclr;
    wire led_select;
    wire legality;
    wire correctness;
    wire full_check;

	//--------------------------------------------
	// IMPORTANT!!!! If simulating, use this line:
	//--------------------------------------------
	wire uclk = pclk;

	// Datapath -- Add port connections
	SimonDatapath dpath(

        // External Inputs 
        .clk            (uclk),
        .level          (level),
        .pattern        (pattern),
        .reset            (rst),

        // Inputs from Controller
        .scld            (seq_countld),
        .srld            (seq_regld),
        .rcld            (reg_countld),
        .rcclr            (reg_countclr),
        .led_sel        (led_select),

        // Datapath Outputs to Controller
        .is_legal        (legality),
        .correct_pattern (correctness),
        .is_last_element (full_check),

        // External Output
        .pattern_leds(pattern_leds)

        // ...
	);

	// Control -- Add port connections
	SimonControl ctrl(

        // External inputs
        .clk            (uclk),
        .rst            (rst),

        // Inputs from Datapath
        .is_legal        (legality),
        .is_last_element (full_check),
        .correct_pattern (correctness),

        // Outputs to Datapath
        .scld            (seq_countld),
        .srld            (seq_regld),
        .rcld            (reg_countld),
        .rcclr           (reg_countclr),
        .led_sel         (led_select),    

        // External Output
        .mode_leds       (mode_leds)
	);

endmodule
