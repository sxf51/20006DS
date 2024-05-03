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
module PressHold ( input clk, input in, output out );
	
	reg [1: 0] prev = 0;
	reg [1: 0] next_prev;
	
	localparam N = 25_000_000;
	localparam BWL = $clog2(N);
	wire [BWL-1: 0] tick1;
	localparam M = 5_000_000;
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