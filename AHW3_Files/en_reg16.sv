module en_reg16(
  input clk,				// clock
  input EN,			 	// when high enable flop to capture
  input [15:0] D,			// register 16-bit data input
  output [15:0] Q			// register 16-bit Q output
);

  /////////////////////////////////////////////////////
  // instantiate 16 d_en_ff as a vector to implement //
  ///////////////////////////////////////////////////
  d_en_ff id_en_ff [15:0](.clk(clk), .EN(EN), .D(D), .CLRN(16'b1111111111111111), .Q(Q));
  
endmodule
