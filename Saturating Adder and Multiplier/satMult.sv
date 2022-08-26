///////////////////////////////////////////////////////
// satMult.sv  Signed 16x16 multiply with divide by //
// 2^15 and saturation logic.                      //
////////////////////////////////////////////////////
module satMult(
  input signed [15:0] coeff,	// signed 16-bit input always is a coefficient from NV_mem
  input signed [15:0] Temp,		// Always from the Temp register
  output 	[15:0]	satProd		// 16-bit saturated product
);

	/////////////////////////////////////////////////
	// Declare any internal signals as type logic //
	///////////////////////////////////////////////
	logic signed [31:0] Prod;		// raw 16x16 signed product
	logic satPos,satNeg;		// result of sat_logic that tells us to saturated
	logic satPos1, satPos2, satNeg1, satNeg2;
	logic P31, P30, P29;
	logic PNot31, PNot30, PNot29;
	logic [15:0] muxOut;

	//////////////////////////////////
	// infer 16x16 signed multiply //
	////////////////////////////////
	assign Prod = coeff*Temp;	// don't touch this

    	///////////////////////////////////////////////
	// Infer sat_logic using structural verilog //
	// (instantiation of primitive gates)      //
	////////////////////////////////////////////
	// instantiate verilog primitives to form satNeg, satPos logic
	assign P31 = Prod[31];
	assign P30 = Prod[30];
	assign P29 = Prod[29];

	not iNOT1(PNot31, P31);
	not iNOT2(PNot30, P30);
	not iNOT3(PNot29, P29);

	and iAND1(satPos1, PNot31, P29);
	and iAND2(satPos2, PNot31, P30);
	or iOR1(satPos, satPos1, satPos2);
	
	and iAND3(satNeg1, P31, PNot30);
	and iAND4(satNeg2, P31, PNot29);
	or iOR2(satNeg, satNeg1, satNeg2);

	////////////////////////////////////////////////////////////////
	// Infer saturation muxes using dataflow (assign statements) //
	// assign MuxOut = sel ? D1 : D0;   // a simple 2:1 mux     //
	/////////////////////////////////////////////////////////////

	assign muxOut = satPos? 16'h7FFF : Prod[29:14];
	assign satProd = satNeg? 16'h8000 : muxOut;

	
endmodule