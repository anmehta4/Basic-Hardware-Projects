///////////////////////////////////////////////////
// FA.sv  This design will take in 3 bits       //
// and add them to produce a sum and carry out //
////////////////////////////////////////////////
module FA(
  input 	A,B,Cin,	// three input bits to be added
  output	S,Cout		// Sum and carry out
);

	/////////////////////////////////////////////////
	// Declare any internal signals as type logic //
	///////////////////////////////////////////////
	logic Soutput1;
	logic Coutput1;
	logic Coutput2;

	/////////////////////////////////////////////////
	// Implement Full Adder as structural verilog //
	///////////////////////////////////////////////
	xor iXOR1(Soutput1,A,B);
	xor iXOR2(S,Soutput1,Cin);

	and iAND1(Coutput1,A,B);
	and iAND2(Coutput2,Soutput1,Cin);
	or iOR1(Cout,Coutput1,Coutput2);
	
endmodule