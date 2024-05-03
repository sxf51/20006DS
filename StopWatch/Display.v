//Display StopWatch
module DisplayStopWatch(
input [6: 0] ms_10, 
input [5: 0] secs, mins, 
output [6: 0] hex0, hex1, hex2, hex3, hex4, hex5);

	wire [3: 0] ms_10_d1;
	wire [3: 0] ms_10_d2;
	
	wire [3: 0] secs_d1;
	wire [2: 0] secs_d2;
	
	wire [3: 0] mins_d1;
	wire [2: 0] mins_d2;

	assign ms_10_d1 = ms_10 % 4'd10;
	assign ms_10_d2 = ms_10 / 4'd10;
	assign secs_d1 = secs % 4'd10;
	assign secs_d2 = secs / 4'd10;
	assign mins_d1 = mins % 4'd10;
	assign mins_d2 = mins / 4'd10;
	
	SSeg ss0(.enable(1'b1), .num(ms_10_d1), .sseg(hex0));
	SSeg ss1(.enable(1'b1), .num(ms_10_d2), .sseg(hex1));
	SSeg ss2(.enable(1'b1), .num(secs_d1), .sseg(hex2));
	SSeg ss3(.enable(1'b1), .num(secs_d2), .sseg(hex3));
	SSeg ss4(.enable(1'b1), .num(mins_d1), .sseg(hex4));
	SSeg ss5(.enable(1'b1), .num(mins_d2), .sseg(hex5));

endmodule