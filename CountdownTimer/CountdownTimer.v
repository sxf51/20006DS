module CountdownTimer(input CLOCK_50, input [3: 0] KEY,
	output [6: 0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, 
	output [0: 0] LEDR);

	wire [5: 0] secs;
	wire [5: 0] mins;
	wire [4: 0] hours;
	
	wire plus;
	wire reset;
	
	wire timeup;
	
	wire led;
	
	assign timeup = (secs == 0 && mins == 0 && hours == 0);
	PressHold #(.FRE1(1), .FRE2(10)) pl(.clk(CLOCK_50), .in(!KEY[1]), .out(plus));
	RisingEdgeDetector red(.clk(CLOCK_50), .in(!KEY[2]), .out(reset));
	CountdownMode cdmk0(.clk(CLOCK_50), 
		.in(!KEY[0]), .reset(timeup), .mode(mode));
	Buzzer buz(.clk(CLOCK_50), .in(timeup), .enable(!KEY[1]), .reset(!KEY[2]), 
		.buzzer(LEDR[0])); //use LEDR[0] instead
	
	//Time
	CountdownTime cdt(.clk(CLOCK_50), .enable(KEY[1] && mode), .reset(reset),
		.plus(plus), .minus(1'b0), .hours(hours), .mins(mins), .secs(secs));
	
	//Display
	DisplayHMS disHMS(.enable(2'b11), .secs(secs), .mins(mins), .hours(hours),
		.hex0(HEX0), .hex1(HEX1), .hex2(HEX2), .hex3(HEX3), .hex4(HEX4), .hex5(HEX5));
	
endmodule