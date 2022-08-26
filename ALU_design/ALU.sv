module ALU(
  input [7:0] A,	// A operand
  input [7:0] B,	// B operand
  input [1:0] mode,	// 00=>A-B, 01=>1.5A, 10=>ROR(A), 11=>
  output [7:0] Y
);

  //////////////////////////////////////////////////////////////
  // Any needed defines of internal signals below here.  You //
  // may need more than the two we provided for you.        //
  ///////////////////////////////////////////////////////////
  logic [7:0] Rout;		// 8-bit signal driven by Rout's of ALU cells
  logic [7:0] Lout;		// 8-bit Signal driven by Lout's of ALU cells
  logic Rin;
  logic Lin;

  
  /////////////////////////////////////////////////////////////////////
  // You will possibly need some logic at the MSB and LSB positions //
  // to make the operations work out.  Add that below here.        //
  //////////////////////////////////////////////////////////////////
  assign Rin = mode == 2'b11 ? 1 : 0 ;
  assign Lin = mode == 2'b00 ? B[7] : 0;
  
  //////////////////////////////////////////////////////////
  // Vectored instantiation of 8 copies of your ALU_cell //
  // There are some ??? here that you need to figure.   //
  ///////////////////////////////////////////////////////
  ALU_cell iCell[7:0](.A(A), .B(B), .Rin({Lout[6:0],Rin}), .Lin({Lin,Rout[7:1]}),
                      .mode(mode), .Rout(Rout), .Lout(Lout), .Y(Y));
					  
endmodule