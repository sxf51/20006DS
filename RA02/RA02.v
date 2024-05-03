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
	
	PressHold pl(.clk(CLOCK_50), .in(!KEY[0] && KEY[1]) ,.out(plus));
	PressHold mi(.clk(CLOCK_50), .in(!KEY[1] && KEY[0]) ,.out(minus));
	
	Time t(.clk(CLOCK_50), .enable(KEY[0] && KEY[1]), .reset(!KEY[0] && !KEY[1]), .mode(mode),
		.plus(plus), .minus(minus), .hours(hours), .mins(mins), .secs(secs));
	
	wire [1: 0] mode;
	wire pwm;
	
	
		
	Flash #(.FRE(2), .PER(80))
		fla_80(.clk(CLOCK_50), .enable(mode != 2'b00), .reset(1'b0), .pwm(pwm));
	
	Mode keymod2(.clk(CLOCK_50), .key(KEY[2]), .mode(mode));
		
	DisplayHMS disHMS(.enable(mode & {pwm, pwm}), .secs(secs), .mins(mins), .hours(hours),
		.hex0(HEX0), .hex1(HEX1), .hex2(HEX2), .hex3(HEX3), .hex4(HEX4), .hex5(HEX5));
	 
endmodule


//select
module DisplayHMS(input [1: 0] enable,
input [5: 0] secs, mins, hours, 
output [6: 0] hex0, hex1, hex2, hex3, hex4, hex5);

	wire [3: 0] secs_d1;
	wire [3: 0] secs_d2;
	
	wire [3: 0] mins_d1;
	wire [3: 0] mins_d2;
	
	wire [3: 0] hours_d1;
	wire [3: 0] hours_d2;

	assign secs_d1 = secs % 6'd10;
	assign secs_d2 = secs / 6'd10;
	assign mins_d1 = mins % 6'd10;
	assign mins_d2 = mins / 6'd10;
	assign hours_d1 = hours % 6'd10;
	assign hours_d2 = hours / 6'd10;
	
	SSeg ss0(.enable(enable != 2'b01), .num(secs_d1), .sseg(hex0));
	SSeg ss1(.enable(enable != 2'b01), .num(secs_d2), .sseg(hex1));
	SSeg ss2(.enable(enable != 2'b10), .num(mins_d1), .sseg(hex2));
	SSeg ss3(.enable(enable != 2'b10), .num(mins_d2), .sseg(hex3));
	SSeg ss4(.enable(enable != 2'b11), .num(hours_d1), .sseg(hex4));
	SSeg ss5(.enable(enable != 2'b11), .num(hours_d2), .sseg(hex5));

endmodule

module Flash
	#(parameter FRE = 1, PER = 50)(input clk, 
	input enable, reset,
	output reg [0: 0] pwm);
	
	localparam N = 50_000_000/FRE;
	localparam BW = $clog2(N);
	wire [BW-1: 0] tick;
	
	Counter #(.MAX(N-1), .WIDTH(BW), .UP(1'b1))
		editpress(.clk(clk), .enable(enable),
		.reset(reset), .plus(1'b0), .minus(1'b0), .cnt(tick));
	
	wire [9: 0] msf;
	assign msf = tick/50_000;
	
	always @(posedge clk) begin
		if(msf < 10 * PER/FRE) 
			pwm <= 1'b0;
		else pwm <= 1'b1;
	end
endmodule

//KEY2 Mode
module Mode(input clk, input key, 
	output [1: 0] mode);
	
	reg [2: 0] state, next_state;
	
	localparam N = 50_000_000;
	localparam BW = $clog2(N);
	wire [BW-1: 0] tick;
	
	wire enter;
	
	Counter #(.MAX(N-1), .WIDTH(BW), .UP(1'b1))
		editpress(.clk(clk), .enable(state != 0),
		.reset(enter), .plus(1'b0), .minus(1'b0), .cnt(tick));
		
	RisingEdgeDetector editclick(.clk(clk), .in(!key), .out(enter));
	
	wire [9: 0] ms;
	assign ms = tick/50_000;
	
	always @(posedge clk)
		state <= next_state;
		
	always @(*) begin
		case(state)
			3'd0: next_state = key ? 3'd0: 3'd1;
			3'd1: case(key)
					1'b0: next_state = (tick == (N-1)) ? 3'd2: 3'd1;
					1'b1: next_state = 3'd0;
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
