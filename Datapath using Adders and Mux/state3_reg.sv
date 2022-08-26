/////////////////////////////////////////////////////////
// Forms a 3-bit state register that will be one hot. //
// Meaning it needs to aynchronously reset to 6'h01  //
//////////////////////////////////////////////////////
module state3_reg(
  input clk,				// clock
  input CLRN,				// asynchronous active low reset
  input [2:0] nxt_state,	// forms next state (i.e. goes to D input of FFs)
  output [2:0] state		// output (current state)
);
  
  ////////////////////////////////////////////////////
  // Declare any needed internal signals.  Due to  //
  // all bits except LSB needed to reset, and the //
  // LSB needing to preset you will need to form //
  // two 3-bit vectors to hook to CLRN and PRN  //
  ///////////////////////////////////////////////
  logic [2:0] reset;
  logic [2:0] preset;
  
  ///////////////////////////////////////////////////////////
  // The two 3-bit vectors for CLRN & PRN are formed with //
  // vector concatenation of a mix of CLRN and 1'b1      //
  ////////////////////////////////////////////////////////
  assign reset = {{2{CLRN}},1'b1};
  assign preset = {{2{1'b1}},CLRN};
  
  ////////////////////////////////////////////////////////
  // instantiate 6 d_ff as a vector to implement state //
  //////////////////////////////////////////////////////
  d_ff id_ff1[2:0](.clk(clk), .D(nxt_state), .CLRN(reset), .PRN(preset), .Q(state)); 
  
endmodule
