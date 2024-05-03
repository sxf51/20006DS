//7-segments display
module SSeg(
	input enable,
	input [3: 0] num,
	output reg [6: 0] sseg);
//CA 7-segments display;
//input: 4-bit wire [4'h0, 4'hF];
//output: connect to the pins of 7-seg;

	always @(*)
		if(enable)
			case (num)
				0: sseg <= 7'h40;
				1: sseg <= 7'h79;
				2: sseg <= 7'h24;
				3: sseg <= 7'h30;
				4: sseg <= 7'h19;
				5: sseg <= 7'h12;
				6: sseg <= 7'h02;
				7: sseg <= 7'h78;
				8: sseg <= 7'h00;
				9: sseg <= 7'h10;
				10: sseg <= 7'h08;
				11: sseg <= 7'h03;
				12: sseg <= 7'h46;
				13: sseg <= 7'h21;
				14: sseg <= 7'h06;
				15: sseg <= 7'h0E;
				default: sseg <= 7'h7F;
			endcase
		else sseg <= 7'h7F;
endmodule