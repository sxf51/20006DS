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


//Miller FSM, check if KEY is pressed.
module PressHold 
	#(parameter FRE1 = 1, FRE2 = 10)( input clk, input in, output out );
	
	reg [1: 0] prev = 0;
	reg [1: 0] next_prev;
	
	localparam N = 50_000_000/FRE1;
	localparam BWL = $clog2(N);
	wire [BWL-1: 0] tick1;
	localparam M = 50_000_000/FRE2;
	localparam BWP = $clog2(M);
	wire [BWP-1: 0] tick2;
	 
	Counter #(.MAX(N-1), .WIDTH(BWL), .UP(1'b1))
		divider1(.clk(clk), .enable(next_prev == 2'd2),
		.reset(next_prev != 2'd2), .plus(1'b0), .minus(1'b0), .cnt(tick1));
	
	Counter #(.MAX(M-1), .WIDTH(BWP), .UP(1'b1))
		divider2(.clk(clk), .enable(next_prev == 3),
		.reset(next_prev != 3), .plus(1'b0), .minus(1'b0), .cnt(tick2));
	
	always @(posedge clk)
		prev <= next_prev;
		
	always @(*) begin
		case(prev)
			0: next_prev = in;
			1: next_prev = in ? 2'd2: 2'd0;
			2: case(in)
					0: next_prev = 2'd0;
					1: next_prev = (tick1 == (N-1)) ? 2'd3: 2'd2;
					default: next_prev = in;
				endcase
			3: next_prev = in ? 2'd3: 2'd0;
			default next_prev = in;
		endcase
	end
	
	assign out = ((!prev && in) || (prev == 3 && !tick2));

endmodule

//KEY2 ClockMode
module ClockMode(input clk, input in, 
	output [1: 0] mode);
	
	reg [2: 0] state, next_state;
	
	localparam N = 50_000_000;
	localparam BW = $clog2(N);
	wire [BW-1: 0] tick;
	
	wire enter;
	
	Counter #(.MAX(N-1), .WIDTH(BW), .UP(1'b1))
		editpress(.clk(clk), .enable(state != 0),
		.reset(enter), .plus(1'b0), .minus(1'b0), .cnt(tick));
		
	RisingEdgeDetector editclick(.clk(clk), .in(in), .out(enter));
	
	always @(posedge clk)
		state <= next_state;
		
	always @(*) begin
		case(state)
			3'd0: next_state = in ? 3'd1: 3'd0;
			3'd1: case(in)
					1'b1: next_state = (tick == (N-1)) ? 3'd2: 3'd1;
					1'b0: next_state = 3'd0;
					default: next_state = 3'd0;
				endcase
			3'd2: next_state = enter ? 3'd3: 3'd2;
			3'd3: next_state = enter ? 3'd4: 3'd3;
			3'd4: next_state = enter ? 3'd0: 3'd4;
			default: next_state = 3'd0;
		endcase
	end
	
	assign mode = (state == 3'b0) ? 2'b00: state-1;
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

//Countdown KEY0 Mode
module CountdownMode(input clk, input in, reset, 
	output mode);
	
	reg state, next_state;
	wire enter;
		
	RisingEdgeDetector editclick(.clk(clk), .in(in), .out(enter));

	always @(posedge clk)
		if(!reset) state <= next_state;
		else state <= 0;
		
	always @(*) begin
		next_state = enter ? !state: state;
	end
	
	assign mode = state;
endmodule

module Buzzer(input clk, input timeup, enable, reset, 
	output buzzer);
	
	reg [1: 0] state, next_state;
	wire enter1, enter2;
	
	RisingEdgeDetector editclick1(.clk(clk), .in(enable), .out(enter1));
	RisingEdgeDetector editclick2(.clk(clk), .in(timeup), .out(enter2));

	always @(posedge clk)
		state <= next_state;
		
	always @(*) begin
		if(reset) next_state = 2'b01;
		else case(state)
				2'b00: next_state = enter1 ? 2'b01: 2'b00;
				2'b01: next_state = enter2 ? 2'b10: 2'b01;
				2'b10: next_state = timeup ? 2'b11: 2'b01;
				2'b11: next_state = enter1 ? 2'b01: 2'b11;
				default: next_state = 2'b00;
			endcase
	end
	
	assign buzzer = ((state[1] == 1'b1) && !enable);
endmodule

//Key3 Mode, select Clock, StopTimer, CountdownTimer
module Mode(input clk, input in, output [1: 0] mode);

	reg [1: 0] state, next_state;
	wire enter;
	
	RisingEdgeDetector editclick(.clk(clk), .in(in), .out(enter));
	
	always @(posedge clk)
		state <= next_state;
		
	always @(*) begin
		case(state)
			2'b00: next_state = enter ? 2'b01: 2'b00;
			2'b01: next_state = enter ? 2'b10: 2'b01;
			2'b10: next_state = enter ? 2'b11: 2'b10;
			2'b11: next_state = enter ? 2'b00: 2'b11;
			default: next_state = 2'b00;
		endcase
	end
	
	assign mode = state;
	
endmodule
