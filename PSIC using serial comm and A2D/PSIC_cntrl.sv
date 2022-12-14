module PSIC_cntrl(
  input clk, rst_n,			// clock and active low asynch reset
  input cmd_rdy,			// new command ready from serial_comm
  input [2:0] cmd,			// only bits [18:16] of cmd[23:0] form the command
  output logic trmt,		// transmit corrected pressure reading via serial_comm
  output logic WE,			// Write Enable to NV_MEM (calibration coefficient memory)
  output logic [1:0] addr,	// address to NV_MEM, 00=zero, 01=Tco, 10=Offset, 11=Gain
  output logic selA2D,		// select A2D reading vs Temp register for datapath "A"
  output logic selCoeff,	// select A2D reading vs Temp register for datapath "B"
  output logic selMult,		// dst bus of datapath chooses Mult vs Add
  output logic enTmp,		// enable Temp register
  output logic strt_cnv,	// initiate A2D conversion
  output logic chnl,		// selects channel to convert 0=>PTAT, 1=>Pressure
  input cnv_cmplt			// A2D conversion complete
);
    
				 
	//// declare states ////
  	typedef enum reg[5:0] {IDLE=6'h01, A2D=6'h02, PS = 6'h04,
				 TCO = 6'h08, OFFSET = 6'h10, GAIN = 6'h20} state_t;
	
	/////////////////////////////
	// declare nxt_state type //
	///////////////////////////
	state_t nxt_state;
	
	///////////////////////////////
	// declare internal signals //
	/////////////////////////////
	logic [5:0] state;
	
	///////////////////////////////////////////
	// Instantiate state flops (state7_reg) //
	/////////////////////////////////////////
	state6_reg iST(.clk(clk),.CLRN(rst_n),.nxt_state(nxt_state),.state(state));	
	
	//////////////////////////////////////////////
	// State transitions and outputs specified //
	// next as combinational logic with case  //
	///////////////////////////////////////////		
	always_comb begin
		/////////////////////////////////////////
		// Default all SM outputs & nxt_state //
		///////////////////////////////////////
		nxt_state = state_t'(state);
            	trmt = 1'b0;		
  		WE = 1'b0;			
		addr = 2'b00;		
		selA2D = 1'b0;	
		selCoeff = 1'b0;		
		selMult = 1'b0;	
  		enTmp = 1'b0;	
  		strt_cnv = 1'b0;	
  		chnl = 1'b0;	

		case (state)
			IDLE: begin
				if(cmd_rdy) begin
					if(~cmd[2]) begin
						nxt_state = A2D;
						strt_cnv = 1'b1;
						chnl = 1'b0;
					end else begin 
						nxt_state = IDLE;
						WE = 1'b1;
						addr = cmd[1:0];
						trmt = 1'b1;
					end
				end				
			end
			
			A2D: begin
				if(cnv_cmplt) begin
					nxt_state = TCO;
					selA2D = 1'b1;
					selCoeff = 1'b1;
					enTmp = 1'b1;					
				end else begin
					nxt_state = A2D;
				end
			end

			TCO: begin 
					nxt_state = OFFSET;
					addr = 2'b01;
					enTmp = 1'b1;
					selMult = 1'b1;	
			end

			
			OFFSET: begin 
					nxt_state = PS;
					addr = 2'b10;
					selCoeff = 1'b1;
					enTmp = 1'b1;
					strt_cnv = 1'b1;
					chnl = 1'b1;	
			end

			PS: begin 
				if(cnv_cmplt) begin
					nxt_state = GAIN;
					selA2D = 1'b1;
					enTmp = 1'b1;
				end else begin
					nxt_state = PS;
				end				
			end

			GAIN: begin     
					nxt_state = IDLE;
					addr = 2'b11;
					enTmp = 1'b1;
					trmt = 1'b1;	
					selMult = 1'b1;	
			end 					
					
		endcase
	end
		
endmodule	