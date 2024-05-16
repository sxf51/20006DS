//Top-level
module Watch(
	input CLOCK_50, 
	input [3: 0] KEY,
	output [6: 0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0,
	output [9: 0] LEDR);

	wire [1: 0] mode;
	
	wire [5: 0] secsclk;
	wire [5: 0] minsclk;
	wire [4: 0] hoursclk;
	wire [1: 0] flashclk;
	
	wire [6: 0] ms_10stw;
	wire [5: 0] secsstw, minsstw;
	
	wire [5: 0] secscdwn;
	wire [5: 0] minscdwn;
	wire [4: 0] hourscdwn;
	
	wire [6: 0] n0, n1, n2;
	
	wire [6: 0] num0, num1, num2;
	
	wire pwm;
	wire [2: 0] led;
	
	BreathLED breathled(.clk(CLOCK_50), .enable(1'b1), .reset(1'b0), .pwm(pwm));
	
	assign LEDR[5] = pwm && (mode == 2'b11);
	assign LEDR[1] = pwm && (mode == 2'b11);
	
	Mux mux(.mode(mode), .secsclk(secsclk), .minsclk(minsclk), .hoursclk(hoursclk),
		.ms_10stw(ms_10stw), .secsstw(secsstw), .minsstw(minsstw),
		.secscdwn(secscdwn), .minscdwn(minscdwn), .hourscdwn(hourscdwn),
		.n0(n0), .n1(n1), .n2(n2),
		.num0(num0), .num1(num1), .num2(num2));
	
	Mode modek3(.clk(CLOCK_50), .in(!KEY[3]), .mode(mode),
		.clockled(LEDR[9]), .stopled(LEDR[8]), .countled(LEDR[7]), .gameled(LEDR[6]));
	
	Clock clock(.clk(CLOCK_50), .in0(!KEY[0]), .in1(!KEY[1]),
		.in2(!KEY[2]), .enable(mode == 2'b00), 
		.secs(secsclk), .mins(minsclk), .hours(hoursclk), .flashmode(flashclk));
		
	StopWatch stw(.clk(CLOCK_50), .in0(!KEY[0]), .in2(!KEY[2]), 
		.enable(mode == 2'b01), .ms_10(ms_10stw), .secs(secsstw), .mins(minsstw));
		
	CountdownTimer cdt(.clk(CLOCK_50), .in0(!KEY[0]), 
		.in1(!KEY[1]), .in2(!KEY[2]), .enable(mode == 2'b10),
		.secs(secscdwn), .mins(minscdwn), .hours(hourscdwn), .buzz(LEDR[0]));
		
	Game(.clk(CLOCK_50), .enable(mode == 2'b11),
		.in0(!KEY[0]), .in1(!KEY[1]), .in2(!KEY[2]),
		.n0(n0), .n1(n1), .n2(n2),
		.led(led));
		
	assign LEDR[4: 2] = led & {mode == 2'b11, mode == 2'b11, mode == 2'b11};
		
	//Display
	DisplayHMS disHMS(.enable({mode == 2'b00, mode == 2'b00} & flashclk), 
		.num0(num0), .num1(num1), .num2(num2),
		.hex0(HEX0), .hex1(HEX1), .hex2(HEX2), .hex3(HEX3), .hex4(HEX4), .hex5(HEX5));
	
endmodule

module Mux(input [1: 0] mode,
	input [6: 0] secsclk, minsclk, hoursclk,
	input [6: 0] ms_10stw, secsstw, minsstw,
	input [6: 0] secscdwn, minscdwn, hourscdwn,
	input [6: 0] n0, n1, n2,
	output reg [6: 0] num0, num1, num2);
	always @(*)
		case(mode)
			2'b00: begin
				num0 = secsclk;
				num1 = minsclk;
				num2 = hoursclk;
			end
			2'b01: begin
				num0 = ms_10stw;
				num1 = secsstw;
				num2 = minsstw;
			end
			2'b10: begin
				num0 = secscdwn;
				num1 = minscdwn;
				num2 = hourscdwn;
			end
			2'b11: begin
				num0 = n0;
				num1 = n1;
				num2 = n2;
			end
			default: begin
				num0 = 0;
				num1 = 0;
				num2 = 0;
			end
		endcase
endmodule

module Clock(
	input clk, input in0, in1, in2, 
	input enable,
	output [5: 0] secs, mins, output [4: 0] hours,
	output [1: 0] flashmode);
	
	wire plus;
	wire minus;
	
	wire [1: 0] mode;
	wire pwm;
	
	//ButtonControl
	PressHold #(.FRE1(2), .FRE2(10)) pl(.clk(clk), .in(enable && in0 && !in1), .out(plus));
	PressHold #(.FRE1(2), .FRE2(10)) mi(.clk(clk), .in(enable && in1 && !in0), .out(minus));
	ClockMode keymod2(.clk(clk), .in(enable && in2), .mode(mode));
	
	//Time
	Time t(.clk(clk), .enable(!in0 && !in1), .reset(enable && in0 && in1), .mode(mode),
		.plus(plus), .minus(minus), .hours(hours), .mins(mins), .secs(secs));
	
	//FlashControl
	Flash #(.FRE(2), .DC(80))
		fla_80(.clk(clk), .enable(mode != 2'b00), .reset(1'b0), .pwm(pwm));
	
	assign flashmode = (mode & {!pwm, !pwm});
	 
endmodule

module StopWatch(
	input clk,
	input in0, in2, enable, 
	output [6: 0] ms_10,
	output [5: 0] secs, mins);

	wire startstop;
	wire reset;
	
	StopWatchMode swm(.clk(clk), .in(enable && in0), .mode(startstop));
	RisingEdgeDetector editclick(.clk(clk), .in(enable && in2), .out(reset));
	
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
	PressHold #(.FRE1(1), .FRE2(10)) pl(.clk(clk), .in(enable && in1), .out(plus));
	RisingEdgeDetector red(.clk(clk), .in(enable && in2), .out(reset));
	CountdownMode cdmk0(.clk(clk), 
		.in(enable && in0), .reset(timeup), .mode(mode));
	Buzzer buz(.clk(clk), .timeup(timeup), .enable(enable && in1), .reset(in2), 
		.buzzer(buzz)); //use LEDR[0] instead
	
	//Time
	CountdownTime cdt(.clk(clk), .enable(!in1 && mode), .reset(reset),
		.plus(plus), .minus(1'b0), .hours(hours), .mins(mins), .secs(secs));
	
endmodule

module Game(
	input clk, enable,
	input in0, in1, in2,
	output [6: 0] n0, n1, n2,
	output reg [2: 0] led);
	
	wire [1: 0] randi;
	
	wire enter0, enter1, enter2;
	
	RisingEdgeDetector red0 (. clk(clk), .in(enable && in0) , .out(enter0));
	RisingEdgeDetector red1 (. clk(clk), .in(enable && in1) , .out(enter1));
	RisingEdgeDetector red2 (. clk(clk), .in(enable && in2) , .out(enter2));
	
	Random #(.MIN(1), .MAX(3)) random(.clk(clk), .in(enter0 || enter1 || enter2), .randi(randi));

	always @(posedge clk) begin
		case(randi)
			0: led <= 3'b000;
			1: led <= 3'b001;
			2: led <= 3'b010;
			3: led <= 3'b100;
			default: led <= 3'b000;
		endcase
	end
	
	Counter #(.MAX(99), .WIDTH(7), .UP(1'b1))
		cn0(.clk(clk), .enable(1'b0),
		.reset(reset), .plus(plus), .minus(1'b0), .cnt(n0));
	Counter #(.MAX(99), .WIDTH(7), .UP(1'b1))
		cn1(.clk(clk), .enable(1'b0),
		.reset(reset), .plus(n0 == 99 && plus), .minus(1'b0), .cnt(n1));
	Counter #(.MAX(99), .WIDTH(7), .UP(1'b1))
		cn2(.clk(clk), .enable(1'b0),
		.reset(reset), .plus(n0 == 99 && n1 == 99 && plus), .minus(1'b0), .cnt(n2));
	
	reg plus, reset;
	
	always @(*) begin
		case(led)
			3'b001: begin 
				plus = enter0 ? 1'b1 : 1'b0;
				reset = (enter1 || enter2) ? 1'b1 : 1'b0;
			end
			3'b010: begin 
				plus = enter1 ? 1'b1 : 1'b0;
				reset = (enter0 || enter2) ? 1'b1 : 1'b0;
			end
			3'b100: begin 
				plus = enter2 ? 1'b1 : 1'b0;
				reset = (enter0 || enter1) ? 1'b1 : 1'b0;
			end
			default: begin 
				plus = 1'b0;
				reset = 1'b0;
			end
		endcase
	end

endmodule