//Display Hour, Minutes, Seconds
module DisplayHMS(input [1: 0] enable,
input [6: 0] num0, num1, num2, 
output [6: 0] hex0, hex1, hex2, hex3, hex4, hex5);

	wire [3: 0] num0_d1;
	wire [3: 0] num0_d2;
	
	wire [3: 0] num1_d1;
	wire [3: 0] num1_d2;
	
	wire [3: 0] num2_d1;
	wire [3: 0] num2_d2;

	assign num0_d1 = num0 % 4'd10;
	assign num0_d2 = num0 / 4'd10;
	assign num1_d1 = num1 % 4'd10;
	assign num1_d2 = num1 / 4'd10;
	assign num2_d1 = num2 % 4'd10;
	assign num2_d2 = num2 / 4'd10;
	
	SSeg ss0(.enable(enable != 2'b01), .num(num0_d1), .sseg(hex0));
	SSeg ss1(.enable(enable != 2'b01), .num(num0_d2), .sseg(hex1));
	SSeg ss2(.enable(enable != 2'b10), .num(num1_d1), .sseg(hex2));
	SSeg ss3(.enable(enable != 2'b10), .num(num1_d2), .sseg(hex3));
	SSeg ss4(.enable(enable != 2'b11), .num(num2_d1), .sseg(hex4));
	SSeg ss5(.enable(enable != 2'b11), .num(num2_d2), .sseg(hex5));

endmodule