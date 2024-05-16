//Flash
//FRE: frequence; DC: Duty cycle; 
module Flash
	#(parameter FRE = 1, DC = 50)(input clk, 
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
		if(msf > 10 * DC/FRE) 
			pwm <= 1'b0;
		else pwm <= 1'b1;
	end
endmodule

module BreathLED
	#(parameter FRE = 2)(input clk, 
	input enable, reset,
	output reg [0: 0] pwm);
	
	localparam N = 25_000_000*FRE;
	localparam BW = $clog2(N);
	wire [BW-1: 0] tick;
	
	Counter #(.MAX(N-1), .WIDTH(BW), .UP(1'b1))
		editpress(.clk(clk), .enable(enable),
		.reset(reset), .plus(1'b0), .minus(1'b0), .cnt(tick));
	
	wire [9: 0] ms;
	wire [9: 0] t;
	assign ms = tick/(25_000*FRE);
	assign t = tick%(1000);
	
	reg state, next_state;
	
	always @(*) begin
		state <= next_state;
	end
	
	always @(posedge clk) begin
		case (state)
			0: begin
				next_state = (tick == (N-1)) ? 1'b1: 1'b0;
				pwm = (t > ms) ? 1'b0: 1'b1;
			end
			1: begin
				next_state = (tick == (N-1)) ? 1'b0: 1'b1;
				pwm = (t > ms) ? 1'b1: 1'b0;
			end
		endcase
	end
endmodule