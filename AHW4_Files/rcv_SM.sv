module rcv_SM(
  input clk, rst_n,			// clock and active low asynch reset
  input rx_rdy,				// byte receieve from serial8
  output logic cmd_rdy,		// indicates to higher level cmd[23:0] ready
  output logic EN_high,		// capture high byte of command in register
  output logic EN_mid		// capture middle byte of command in register
);
    
	//// declare states ////
  	typedef enum reg[2:0] {HIGH=3'b001, MID=3'b010, LOW=3'b100} state_t;
	
	/////////////////////////////
	// declare nxt_state type //
	///////////////////////////
	state_t nxt_state;
	
	///////////////////////////////
	// declare internal signals //
	/////////////////////////////
	logic [2:0] state;
	
	//////////////////////////////
	// Instantiate state flops //
	////////////////////////////
	state3_reg iST(.clk(clk),.CLRN(rst_n),.nxt_state(nxt_state),.state(state));	
	
	//////////////////////////////////////////////
	// State transitions and outputs specified //
	// next as combinational logic with case  //
	///////////////////////////////////////////		
	always_comb begin
		/////////////////////////////////////////
		// Default all SM outputs & nxt_state //
		///////////////////////////////////////
		nxt_state = state_t'(state);
		cmd_rdy = 1'b0;
		EN_high = 1'b0;
		EN_mid = 1'b0;
		
		case (state)
		  HIGH: begin
			if(rx_rdy) begin
			nxt_state = LOW;
			EN_high = 1'b1;
			end
		  end
		  MID : begin
			if(rx_rdy) begin
			nxt_state = HIGH;
			cmd_rdy = 1'b1;
			end
		  end
		  default : begin		// same as LOW
			if(rx_rdy) begin
			nxt_state = MID;
			EN_mid = 1'b1;
		  	end
		  end

 		endcase
	end
		
endmodule	