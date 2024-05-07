//Top-level
module Watch(
input CLOCK_50, 
input [3: 0] KEY,
output [6: 0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0,
output [0: 0] LEDR);

	wire [1: 0] mode;
	reg [5: 0] secs;
	reg [5: 0] mins;
	reg [4: 0] hours;
	
	wire [5: 0] secsclk;
	wire [5: 0] minsclk;
	wire [4: 0] hoursclk;
	wire [1: 0] flashclk;
	
	wire [6: 0] ms_10stw;
	wire [5: 0] secsstw, minsstw;
	
	wire [5: 0] secscdwn;
	wire [5: 0] minscdwn;
	wire [4: 0] hourscdwn;
	
	always @(*)
		case(mode)
			2'b00: begin
				secs = secsclk;
				mins = minsclk;
				hours = hoursclk;
			end
			2'b01: begin
				secs = ms_10stw;
				mins = secsstw;
				hours = minsstw;
			end
			2'b10: begin
				secs = secscdwn;
				mins = minscdwn;
				hours = hourscdwn;
			end
			default: begin
				secs = 0;
				mins = 0;
				hours = 0;
			end
		endcase
	
	Mode modek3(.clk(CLOCK_50), .in(!KEY[3]), .mode(mode));
	
	Clock clock(.clk(CLOCK_50), .in({mode == 2'b00, mode == 2'b00, mode == 2'b00} & ~KEY[2: 0]),
		.secs(secsclk), .mins(minsclk), .hours(hoursclk), .flashmode(flashclk));
		
	StopWatch stw(.clk(CLOCK_50), .in0(mode == 2'b01 && !KEY[0]), .in2(mode == 2'b01 && !KEY[2]), 
		.ms_10(ms_10stw), .secs(secsstw), .mins(minsstw));
		
	CountdownTimer(.clk(CLOCK_50), .in0(mode == 2'b10 && !KEY[0]), 
		.in1(mode == 2'b10 && !KEY[1]), .in2(!KEY[2]), .enable(mode == 2'b10),
		.secs(secscdwn), .mins(minscdwn), .hours(hourscdwn), .buzz(LEDR[0]));
		
	//Display
	DisplayHMS disHMS(.enable({mode == 2'b00, mode == 2'b00} & flashclk), 
		.secs(secs), .mins(mins), .hours(hours),
		.hex0(HEX0), .hex1(HEX1), .hex2(HEX2), .hex3(HEX3), .hex4(HEX4), .hex5(HEX5));
	
endmodule

module Clock(
	input clk, input [2: 0] in,
	output [5: 0] secs, mins, output [4: 0] hours,
	output [1: 0] flashmode);
	
	wire plus;
	wire minus;
	
	wire [1: 0] mode;
	wire pwm;
	
	//ButtonControl
	PressHold #(.FRE1(2), .FRE2(10)) pl(.clk(clk), .in(in[0] && !in[1]), .out(plus));
	PressHold #(.FRE1(2), .FRE2(10)) mi(.clk(clk), .in(in[1] && !in[0]), .out(minus));
	ClockMode keymod2(.clk(clk), .in(in[2]), .mode(mode));
	
	//Time
	Time t(.clk(clk), .enable(!in[0] && !in[1]), .reset(in[0] && in[1]), .mode(mode),
		.plus(plus), .minus(minus), .hours(hours), .mins(mins), .secs(secs));
	
	//FlashControl
	Flash #(.FRE(2), .DC(80))
		fla_80(.clk(clk), .enable(mode != 2'b00), .reset(1'b0), .pwm(pwm));
	
	assign flashmode = (mode & {!pwm, !pwm});
	 
endmodule

module StopWatch(
	input clk,
	input in0, in2,
	output [6: 0] ms_10,
	output [5: 0] secs, mins);

	wire startstop;
	wire reset;
	
	StopWatchMode(.clk(clk), .in(in0), .mode(startstop));
	RisingEdgeDetector editclick(.clk(clk), .in(in2), .out(reset));
	
	StopWatchTime swt(.clk(clk), .enable(startstop), .reset(reset), 
		.ms_10(ms_10), .secs(secs), .mins(mins));

endmodule

module CountdownTimer(input clk, input in0, in1, in2, enable,
	output [5: 0] secs, mins,
	output [4: 0] hours,
	output buzz);
	
	wire plus;
	wire reset;
	
	wire timeup;
	wire [1: 0] mode;
	
	assign timeup = (secs == 0 && mins == 0 && hours == 0);
	PressHold #(.FRE1(1), .FRE2(10)) pl(.clk(clk), .in(in1), .out(plus));
	RisingEdgeDetector red(.clk(clk), .in(enable && in2), .out(reset));
	CountdownMode cdmk0(.clk(clk), 
		.in(in0), .reset(timeup), .mode(mode));
	Buzzer buz(.clk(clk), .in(timeup), .enable(in1), .reset(in2), 
		.buzzer(buzz)); //use LEDR[0] instead
	
	//Time
	CountdownTime cdt(.clk(clk), .enable(!in1 && mode), .reset(reset),
		.plus(plus), .minus(1'b0), .hours(hours), .mins(mins), .secs(secs));
	
endmodule