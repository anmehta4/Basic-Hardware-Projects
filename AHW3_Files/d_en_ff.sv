module d_en_ff(
  input clk,
  input D,			// D input to be flopped
  input CLRN,		// asynch active low clear (reset)
  input EN,			// enable signal
  output logic Q
);

  ////////////////////////////////////////////////////
  // Declare any needed internal sigals below here //
  //////////////////////////////////////////////////
  logic D_EN;
  logic preset;
  logic EN_not;
  logic int_D1,int_D2;
  

  //////////////////////////////////////////////////
  // Form logic that feeds D input to make it an //
  // enable FF.  Instantiate verilog primitives //
  ///////////////////////////////////////////////
  assign preset = 1'b1;
  not iNOT1(EN_not, EN);
  and iAND1(int_D1, EN_not, Q);
  and iAND2(int_D2, EN, D);
  or iOR1(D_EN, int_D1, int_D2);
  
  //////////////////////////////////////////////
  // Instantiate simple d_ff without enable  //
  // and tie PRN inactive.  Connect D input //    
  // to logic you inferred above.          //
  //////////////////////////////////////////
  d_ff id_ff(.D(D_EN),.CLRN(CLRN),.PRN(preset),.clk(clk),.Q(Q));


endmodule
