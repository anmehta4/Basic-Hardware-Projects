module LUT3(
  //////////////////////////////////////////////////////////
  // A 3-input LUT is simply an 8:1 mux where the data    //
  // inputs are SRAM cells "configured" with 1's or 0's   //
  // to implement the truth table of the desired of 3     //
  // inputs.  The inputs are then applied to the selects. //
  // In our case as you instantiate the LUT3 you will ///// 
  // value fix 1'b1 or 1'b0 to the D[] inputs to     //
  // represent the values the SRAM cells would be   //
  // configured to.                                //
  //////////////////////////////////////////////////
  input [7:0] D,	// value fix these to 1'b1 or 1'b0 to "configure" LUT3
  input [2:0] SEL,	// LUT3 is actually just an 8:1 mux
  output LUT_out
);
  

  assign LUT_out = (SEL===3'b000) ? D[0] :
                   (SEL===3'b001) ? D[1] :
			       (SEL===3'b010) ? D[2] :
			       (SEL===3'b011) ? D[3] :
			       (SEL===3'b100) ? D[4] :
			       (SEL===3'b101) ? D[5] :
			       (SEL===3'b110) ? D[6] :
			       (SEL===3'b111) ? D[7] :
			       1'bx;
			 
endmodule			 
  