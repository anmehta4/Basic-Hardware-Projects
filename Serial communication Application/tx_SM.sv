module tx_SM(clk,rst_n,trmt,byte_sent,sel_low,send_byte);

  input clk,rst_n;		// clock and active low asynch reset
  input trmt;			// asserted with transmit commences
  input byte_sent;		// indicates tranmission of byte is complete
  output reg sel_low;		// selects tx_data[7:0] for tranmission
  output reg send_byte;		// kick off tranmission by serial8
  
  /// define custom state for state ///
  typedef enum reg[1:0] {IDLE=2'b01, LOW_BYTE=2'b10} state_t;
  
  /// declare state flops and nxt_state ///
  state_t nxt_state;
  
  ///////////////////////////////
  // declare internal signals //
  /////////////////////////////
  logic [1:0] state;
  
  //////////////////////////////
  // Instantiate state flops //
  ////////////////////////////
  state2_reg iST(.clk(clk),.CLRN(rst_n),.nxt_state(nxt_state),.state(state));	 
	  
  //////////////////////////////////////////////
  // State transitions and outputs specified //
  // next as combinational logic with case  //
  ///////////////////////////////////////////	
  always_comb begin
    /// default outputs and nxt_state ////
	nxt_state = state_t'(state);
	sel_low = 1'b0; 
	send_byte = 1'b0;

	
	case (state)
	  IDLE : begin
		if(trmt) begin
		nxt_state = LOW_BYTE;
		send_byte = 1'b1;
		end
	  end

	  default : begin 	// same as LOW_BYTE
		if(byte_sent) begin
		nxt_state = IDLE;
		sel_low = 1'b1;
		send_byte = 1'b1;
		end
	  end

	endcase
	
  end
  
endmodule
	  

  