//StopWatchTime module
module StopWatchTime(input clk, enable, reset, 
output [6: 0] ms_10,
output [5: 0] secs, mins);
    localparam N = 500_000;
    localparam BW = $clog2(N);
    wire [BW-1: 0] tick;
	 
    Counter #(.MAX(N-1), .WIDTH(BW), .UP(1'b1))
        divider(.clk(clk), .enable(enable),
			.reset(reset), .plus(1'b0), .minus(1'b0), .cnt(tick));
    Counter #(.MAX(99), .WIDTH(7), .UP(1'b1))
        cs(.clk(clk), .enable(tick == (N-1)),
			.reset(reset), .plus(1'b0), .minus(1'b0), .cnt(ms_10));
	 Counter #(.MAX(59), .WIDTH(6), .UP(1'b1))
        cm(.clk(clk), .enable(ms_10 == 99 && tick == (N-1)),
			.reset(reset), .plus(1'b0), .minus(1'b0), .cnt(secs));
	 Counter #(.MAX(59), .WIDTH(6), .UP(1'b1))
        ch(.clk(clk), .enable(secs == 59 && ms_10 == 99 && tick == (N-1)),
			.reset(reset), .plus(1'b0), .minus(1'b0), .cnt(mins));
endmodule

//Counter module
module Counter
    #(parameter MAX = 1, WIDTH = 1, UP = 1)(
        input clk,
        input enable, reset, 
		  input plus, minus,
        output reg [WIDTH-1 : 0] cnt
    );
    
    initial cnt = 0;
    
    reg [WIDTH-1 : 0] next_cnt;
    
	always @(posedge clk) begin
		if(reset) cnt <= 0;
		else if(enable || plus || minus) cnt <= next_cnt;
	end
        
	    always @(*)
		  case(plus)
				1'b0: case(minus)
					 1'b0: case(enable)
						 1'b1: next_cnt = (cnt == MAX) ? 1'd0 : (cnt + UP);
						 default: next_cnt = cnt;
					 endcase
					 1'b1: next_cnt = (cnt == 1'd0) ? MAX : (cnt - 1'd1);
					 default: next_cnt = cnt;
					endcase
				1'b1: case(minus)
					 1'b0: next_cnt = (cnt == MAX) ? 1'd0 : (cnt + 1'd1);
					 1'b1: next_cnt = cnt;
					 default: next_cnt = cnt;
					endcase
				default: next_cnt = cnt;
		  endcase
endmodule