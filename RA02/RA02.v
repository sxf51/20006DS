//Top-level
module RA02(
input CLOCK_50, 
input [3: 0] KEY,
output [6: 0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);

	wire [5: 0] secs;
	wire [5: 0] mins;
	wire [5: 0] hours;
	
	wire plus;
	wire minus;
	
	wire [1: 0] mode;
	wire pwm;
	
	//ButtonControl
	ButtonControl ButtCon(.clk(CLOCK_50), .key(KEY), .mode(mode), .plus(plus), .minus(minus));
	
	//Time
	Time t(.clk(CLOCK_50), .enable(KEY[0] && KEY[1]), .reset(!KEY[0] && !KEY[1]), .mode(mode),
		.plus(plus), .minus(minus), .hours(hours), .mins(mins), .secs(secs));
	
	//FlashControl
	Flash #(.FRE(2), .DC(80))
		fla_80(.clk(CLOCK_50), .enable(mode != 2'b00), .reset(1'b0), .pwm(pwm));
	
	//Display
	DisplayHMS disHMS(.enable(mode & {pwm, pwm}), .secs(secs), .mins(mins), .hours(hours),
		.hex0(HEX0), .hex1(HEX1), .hex2(HEX2), .hex3(HEX3), .hex4(HEX4), .hex5(HEX5));
	 
endmodule