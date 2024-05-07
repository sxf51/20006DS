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