module RisingEdgeDetector ( input clk , input in , output out );
//Whether KEY is pressed
//RisingEdgeDetector red (. clk( CLOCK_50 ), .in(! KEY [0]) , .out( enter ));
	reg prev = 0; // State
	wire next_prev ;
	
	// Flip -flop
	always @( posedge clk)
		prev <= next_prev;
		
	// Next - state logic
	assign next_prev = in;
	
	// Output logic
	assign out = (!prev && in);
	
endmodule

//StopWatch KEY0 Mode
module StopWatchMode(input clk, input in, 
	output mode);
	
	reg state, next_state;
	wire enter;
		
	RisingEdgeDetector editclick(.clk(clk), .in(in), .out(enter));

	always @(posedge clk)
		state <= next_state;
		
	always @(*) begin
		next_state = enter ? !state: state;
	end
	
	assign mode = state;
endmodule
