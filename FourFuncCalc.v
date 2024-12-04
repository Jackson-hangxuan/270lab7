module FourFuncCalc
  #(parameter W = 11)             // Default bit width
  (
    input Clock,
    input Clear,                   // C button
    input Equals,                  // = button: displays result so far
    input Add,                     // + button
    input Subtract,                // - button
    input Multiply,                // x button (times)
    input Divide,                  // / button (division quotient)
    input [W-1:0] Number,          // Must be entered in signed-magnitude on SW[W-1:0]
    output signed [W-1:0] Result,  // Calculation result in two's complement
    output Overflow                // Indicates result can't be represented in W bits 
  );
  localparam WW = 2 * W;           // Double width for Booth multiplier
  localparam BoothIter = $clog2(W);// Width of Booth Counter

  
//****************************************************************************************************
// Datapath Components
//****************************************************************************************************


//----------------------------------------------------------------------------------------------------
// Registers
// For each register, declare it along with the controller commands that
// are used to update its state following the example for register A
//----------------------------------------------------------------------------------------------------
	
	reg signed [W-1:0] A;			// Accumulator
	wire CLR_A, LD_A;			// CLR_A: A <= 0; LD_A: A <= Q

  
//----------------------------------------------------------------------------------------------------
// Number Converters
// Instantiate the three number converters following the example of SM2TC1
//----------------------------------------------------------------------------------------------------

	wire signed [W-1:0] NumberTC;	// Two's complement of Number
	SM2TC #(.width(W)) SM2TC1(Number, NumberTC);


//----------------------------------------------------------------------------------------------------
// MUXes
// Use conditional assignments to create the various MUXes
// following the example for MUX Y1
//----------------------------------------------------------------------------------------------------
	
	// left
	wire SEL_D;
	assign SEL_D = 0;
	wire signed [W-1:0] Y3;
	assign Y3 = SEL_D ?A :A ;

	wire SEL_P;
	wire signed [W-1:0] Y1;			
	assign SEL_P = 0;		
	assign Y1 = SEL_P? PM[WW:W+1] : Y3;	// 1: Y1 = P; 0: Y1 = Y3

	// right
	wire signed [W-1:0] Y2;
	assign Y2 = SEL_D ?NumberTC :NumberTC ;
  
//----------------------------------------------------------------------------------------------------
// Adder/Subtractor 
//----------------------------------------------------------------------------------------------------

	wire c0;					// 0: Add, 1: Subtract

	assign c0 = Subtract;

	wire ovf;					// Overflow
	AddSub #(.W(W)) AddSub1(Y1, Y2, c0, R, ovf);
	wire PSgn = R[W-1] ^ ovf;		// Corrected P Sign on Adder/Subtractor overflow


//****************************************************************************************************
/* Datapath Controller
   Suggested Naming Convention for Controller States:
     All names start with X (since the tradtional Q connotes quotient in this project)
     XAdd, XSub, XMul, and XDiv label the start of these operations
     XA: Prefix for addition states (that follow XAdd)
     XS: Prefix for subtraction states (that follow XSub)
     XM: Prefix for multiplication states (that follow XMul)
     XD: Prefix for division states (that follow XDiv)
*/
//****************************************************************************************************


//----------------------------------------------------------------------------------------------------
// Controller State and State Labels
// Replace ? with the size of the state registers X and X_Next after
// you know how many controller states are needed.
// Use localparam declarations to assign labels to numeric states.
// Here are a few "common" states to get you started.
//----------------------------------------------------------------------------------------------------

	reg [?:0] X, X_Next;

	localparam XInit		= 'd0;	// Power-on state (A == 0)
	localparam XClear	= ;		// Pick numeric assignments
	localparam XLoadA	= ;
	localparam XResult	= ;
	

//----------------------------------------------------------------------------------------------------
// Controller State Transitions
// This is the part of the project that you need to figure out.
// It's best to use ModelSim to simulate and debug the design as it evolves.
// Check the hints in the lab write-up about good practices for using
// ModelSim to make this "chore" manageable.
// The transitions from XInit are given to get you started.
//----------------------------------------------------------------------------------------------------

	always @*
	case (X)
		XInit:
			if (Clear)
				X_Next <= XInit;
			else if (Equals)
				X_Next <= XLoadA;
			else if (Add)
				X_Next <= XAdd;
			else if (Subtract)
				X_Next <= XSub;
			else if (Multiply)
				X_Next <= XMul;
			else if (Divide)
				X_Next <= XDiv;
			else
				X_Next <= XInit;
	endcase
  
  
//----------------------------------------------------------------------------------------------------
// Initial state on power-on
// Here's a freebie!
//----------------------------------------------------------------------------------------------------

	initial begin
		X <= XClear;
		A <= 'd0;
		N_TC <= 'd0;
		N_SM <= 'd0;
		MCounter <= W;		//BoothIter'dW;
		PM <= 'd0;      			//WW+1'd0;
	end


//----------------------------------------------------------------------------------------------------
// Controller Commands to Datapath
// No freebies here!
// Using assign statements, you need to figure when the various controller
// commands are asserted in order to properly implement the datapath
// operations.
//----------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------  
// Controller State Update
//----------------------------------------------------------------------------------------------------

	always @(posedge Clock)
		if (Clear)
			X <= XClear;
		else
			X <= X_Next;


//----------------------------------------------------------------------------------------------------
// Datapath State Update
// This part too is your responsibility to figure out.
// But there is a hint to get you started.
//----------------------------------------------------------------------------------------------------

	always @(posedge Clock)
	begin
		N_TC <= LD_N ? NumberTC : N_TC;

		
		Result <= R;
		Overflow <= ovf;
	end99

 
//---------------------------------------------------------------------------------------------------- 
// Calculator Outputs
// The two outputs are Result and Overflow, get it?
//----------------------------------------------------------------------------------------------------

endmodule // FourFuncCalc