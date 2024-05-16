//To do: Mersenne Twister
module Random #(parameter MIN = 0, MAX = 1)(input clk, input in, output reg [31: 0] randi);

	localparam RW = $clog2(MAX - MIN + 1);
	wire [RW - 1: 0] tick;
	
	wire enter;
	
	RisingEdgeDetector red (. clk(clk), .in(in) , .out(enter));
	
	Counter #(.MAX(MAX - MIN), .WIDTH(RW), .UP(1'b1))
		sd(.clk(clk), .enable(1'b1), .reset(1'b0), .plus(1'b0), .minus(1'b0), .cnt(tick));
		
	always @(*)
		randi = enter ? (tick + MIN) : randi;
	
endmodule