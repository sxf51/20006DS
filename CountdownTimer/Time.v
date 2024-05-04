//Time module
module CountdownTime(input clk, enable, reset, input plus, minus, 
output [5: 0] hours, mins, secs);
    localparam N = 50_000_000;
    localparam BW = $clog2(N);
    wire [BW-1: 0] tick;
	 
    Counter #(.MAX(N-1), .WIDTH(BW), .UP(1'b1))
        divider(.clk(clk), .enable(enable),
			.reset(reset || (plus || minus)), .plus(1'b0), .minus(1'b0), .cnt(tick));
    Counter #(.MAX(59), .WIDTH(6), .UP(-1))
        cs(.clk(clk), .enable(enable && tick == (N-1)),
			.reset(reset), .plus(plus), .minus(minus), .cnt(secs));
	 Counter #(.MAX(59), .WIDTH(6), .UP(-1))
        cm(.clk(clk), .enable(enable && secs == 0 && tick == (N-1)),
			.reset(reset), .plus(plus && secs == 59), .minus(minus), .cnt(mins));
	 Counter #(.MAX(23), .WIDTH(5), .UP(-1))
        ch(.clk(clk), .enable(enable && mins == 0 && secs == 0 && tick == (N-1)),
			.reset(reset), .plus(plus && mins == 59 && secs == 59), .minus(minus), .cnt(hours));
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
		  case({plus, minus})
				2'b00: case(enable)
					1'b1: if(UP > 0) next_cnt = (cnt == MAX) ? 1'd0 : (cnt + UP);
						else if(UP < 0) next_cnt = (cnt == 1'd0) ? MAX : (cnt + UP);
						else next_cnt = cnt;
					default: next_cnt = cnt;
				endcase
				2'b01: next_cnt = (cnt == 1'd0) ? MAX : (cnt - 1'd1);
				2'b10: next_cnt = (cnt == MAX) ? 1'd0 : (cnt + 1'd1);
				2'b11: next_cnt = cnt;
				default: next_cnt = cnt;
		  endcase
endmodule