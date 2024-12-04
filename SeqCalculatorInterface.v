// File Name: SeqCalculatorInterface.v
module SeqCalculator
	(
		input CLOCK_50,
		input [17:0] SW,							// SW[17]: Operation Control, SW[10:0]: signed-magnitude Number
		input [3:0] KEY,							// Operations (along with SW[17])
		output [6:0] HEX7, HEX6, HEX5, HEX4,// Number 
		output [6:0] HEX3, HEX2, HEX1, HEX0,// Result
		output [8:0] LEDG							// Overflow
	);

	

endmodule // SeqCalculator
