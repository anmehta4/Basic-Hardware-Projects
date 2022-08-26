module en_reg8(
  input clk,				// clock
  input EN,			 	// when high enable flop to capture
  input [7:0] D,			// register 8-bit data input
  output [7:0] Q			// register 8-bit Q output
);

  /////////////////////////////////////////////////////
  // instantiate 8 d_en_ff as a vector to implement //
  ///////////////////////////////////////////////////
  d_en_ff id_en_ff [7:0](.clk(clk), .EN(EN), .D(D), .CLRN(8'b11111111), .Q(Q));
  
endmodule