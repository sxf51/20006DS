module StopWatch(
	input CLOCK_50,
	input [3: 0] KEY, 
	output [6: 0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
	
	wire [6: 0] ms_10;
	wire [5: 0] secs, mins;
	
	DisplayStopWatch dsw(.ms_10(ms_10), .secs(secs), .mins(mins), 
		.hex0(HEX0), .hex1(HEX1), .hex2(HEX2), .hex3(HEX3), .hex4(HEX4), .hex5(HEX5));

	wire startstop;
	wire reset;
	
	StopWatchMode(.clk(CLOCK_50), .in(!KEY[0]), .mode(startstop));
	RisingEdgeDetector editclick(.clk(CLOCK_50), .in(!KEY[2]), .out(reset));
	
	StopWatchTime swt(.clk(CLOCK_50), .enable(startstop), .reset(reset), 
		.ms_10(ms_10), .secs(secs), .mins(mins));

endmodule