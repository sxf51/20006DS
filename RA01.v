//Top-level
module RA01(
input CLOCK_50, 
input [2: 0] KEY,
output [6: 0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);

	wire [5: 0] secs;
	wire [5: 0] mins;
	wire [5: 0] hours;
	
	wire plus;
	wire minus;
	
	PressHold pl(.clk(CLOCK_50), .in(!KEY[0] && KEY[1]) ,.out(plus));
	PressHold mi(.clk(CLOCK_50), .in(!KEY[1] && KEY[0]) ,.out(minus));
	
	Time t(.clk(CLOCK_50), .enable(KEY[0] && KEY[1]), .reset(1'b0), .select(select),
		.plus(plus), .minus(minus), .hours(hours), .mins(mins), .secs(secs));
		
	wire [2: 0] enable, select;
		
	DisplayHMS(.enable(enable), .secs(secs), .mins(mins), .hours(hours),
		.hex0(HEX0), .hex1(HEX1), .hex2(HEX2), .hex3(HEX3), .hex4(HEX4), .hex5(HEX5));
		
	Flash(.clk(CLOCK_50), .key2(KEY[2]), .out(enable), .select(select));
	 
endmodule


//select
module DisplayHMS(input [2: 0] enable,
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
	
	SSeg ss0(.enable(enable[0]), .num(secs_d1), .sseg(hex0));
	SSeg ss1(.enable(enable[0]), .num(secs_d2), .sseg(hex1));
	SSeg ss2(.enable(enable[1]), .num(mins_d1), .sseg(hex2));
	SSeg ss3(.enable(enable[1]), .num(mins_d2), .sseg(hex3));
	SSeg ss4(.enable(enable[2]), .num(hours_d1), .sseg(hex4));
	SSeg ss5(.enable(enable[2]), .num(hours_d2), .sseg(hex5));

endmodule

module Flash(input clk, input key2,
output reg [2: 0] out, select);

	reg [2: 0] skey2, next_skey2;
	
	localparam N = 50_000_000;
	localparam BW = $clog2(N);
	wire [BW-1: 0] tick;
	
	wire enter;
	
	Counter #(.MAX(N-1), .WIDTH(BW), .UP(1'b1))
		editpress(.clk(clk), .enable(skey2 != 0),
		.reset(enter), .plus(1'b0), .minus(1'b0), .cnt(tick));
		
	RisingEdgeDetector editclick(.clk(clk), .in(!key2), .out(enter));
	
	wire [9: 0] ms;
	assign ms = tick/50_000;
	
	always @(posedge clk) begin
		skey2 <= next_skey2;
		case(skey2)
			0: begin 
				out <= 3'b111;
				select <= 3'b001;
			end
			1: begin 
				out <= 3'b111;
				select <= 3'b000;
			end
			2: begin 
				if(ms < 200) 
					out <= 3'b110;
				else out <= 3'b111;
				select <= 3'b001;
			end
			3: begin 
				if(ms < 200) 
					out <= 3'b101;
				else out <= 3'b111;
				select <= 3'b010;
			end
			4: begin 
				if(ms < 200) 
					out <= 3'b011;
				else out <= 3'b111;
				select <= 3'b100;
			end
			default: begin 
				out <= 3'b000;
				select <= 3'b000;
			end
		endcase
	end
		
	always @(*) begin
		case(skey2)
			0: next_skey2 = key2 ? 0: 1;
			1: case(key2)
					0: next_skey2 = (tick == (N-1)) ? 2: 1;
					1: next_skey2 = 0;
				endcase
			2: next_skey2 = enter ? 3: 2;
			3: next_skey2 = enter ? 4: 3;
			4: next_skey2 = enter ? 0: 4;
			default: next_skey2 = 0;
		endcase
	end
endmodule
