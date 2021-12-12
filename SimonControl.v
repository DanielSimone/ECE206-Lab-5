//==============================================================================
// Control Module for Simon Project
//==============================================================================

module SimonControl(
	// External Inputs
	input        clk,           // Clock
	input        rst,           // Reset

	// Datapath Inputs
    input         is_legal,
    input         correct_pattern,
    input         is_last_element,

	// Datapath Control Outputs
    output        reg scld, 
    output        reg rcld,
    output        reg rcclr,
    output        reg srld, 
    output        reg led_sel,

	// External Outputs
    output reg [2:0] mode_leds
);

	// Declare Local Vars Here
    reg [1:0] state;
    reg [1:0] next_state;

	// LED Light Parameters
    localparam LED_MODE_INPUT    = 3'b001;
    localparam LED_MODE_PLAYBACK = 3'b010;
    localparam LED_MODE_REPEAT   = 3'b100;
    localparam LED_MODE_DONE     = 3'b111;

	// Declare State Names Here
    localparam Input = 2'd0;
    localparam PlayBack = 2'd1;
    localparam Repeat = 2'd2;
    localparam Done = 2'd3;

	// Output Combinational Logic
	always @( * ) begin

        scld = 0; 
        rcld = 0; 
        rcclr = 0;
        srld = 0;
        led_sel = 0;

        case (state)
        // Write your output logic here
            Input: begin 
                if (is_legal) begin
                    srld = 1;
                    rcclr = 1;
                    scld = 1;
                end
                led_sel = 1;
                mode_leds = LED_MODE_INPUT;
            end

            PlayBack: begin 
                led_sel = 0;
                if (is_last_element) 
                    rcclr = 1;
                else 
                    rcld = 1;
                
                mode_leds = LED_MODE_PLAYBACK;
            end

            Repeat: begin 
                led_sel = 1;
                if (correct_pattern)
                    rcld = 1;
                else 
                    rcclr = 1;
                mode_leds = LED_MODE_REPEAT;
            end 

            Done: begin
                led_sel = 0;
                if (is_last_element)
                    rcclr = 1;
                else 
                    rcld = 1;
                mode_leds = LED_MODE_DONE;
            end

            default: begin 
                scld = 0; 
                rcld = 0; 
                rcclr = 0;
                srld = 0;
                led_sel = 0;
            end
        endcase
	end

	// Next State Combinational Logic
	always @( * ) begin
        
        next_state = Input; 
        case (state)

            Input: begin
                if (is_legal)
                    next_state = PlayBack;
                else 
                    next_state = state;
            end

            PlayBack: begin 
                if (is_last_element)
                    next_state = Repeat;
                else 
                    next_state = state;
            end 

            Repeat: begin
                if (correct_pattern && is_last_element)
                    next_state = Input;
                else if (~correct_pattern)
                    next_state = Done;
                else 
                    next_state = state;
            end

            Done: begin
                next_state = state;
            end

            default: begin
                next_state = Input;
            end
        endcase
	end

	// State Update Sequential Logic
	always @(posedge clk) begin
        if (rst) begin
            state <= Input;
        end
        else begin
            state <= next_state;
        end
	end

endmodule
